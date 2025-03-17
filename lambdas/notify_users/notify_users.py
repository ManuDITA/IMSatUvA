import json
import uuid
import boto3
from decimal import Decimal
import modules.http_utils as http_utils



dynamodb = boto3.resource("dynamodb")
store_table = dynamodb.Table('store')
cart_table = dynamodb.Table('cart')
reservation_table = dynamodb.Table('user-stock-reserve')
sns_client = boto3.client('sns', region_name= "eu-west-3")
SNS_TOPIC_ARN = 'arn:aws:sns:eu-west-3:225989358926:stockAvailable'

def lambda_handler(event, context):
    
    for record in event['Records']:
        if record['eventName'] in ['MODIFY']:
            
           # Get the new image
            new_image = record['dynamodb']['NewImage']
            old_image = record['dynamodb']['OldImage']
            
            store_id = new_image['id']
            new_stock_items = {item['itemId']: item['quantity'] for item in new_image['stockItems']}
            old_stock_items = {item['itemId']: item['quantity']  for item in old_image['stockItems']}
            
            # Check which items have changed
            updated_items = [item_id for item_id in new_stock_items if new_stock_items[item_id] > old_stock_items.get(item_id, 0)]
        
            if not updated_items:
                continue  # No items restocked
            
            
            # Fetch reservations(itemId and storeID are also GSI)
            for item_id in updated_items:
                reservations = reservation_table.scan(
                    FilterExpression="storeId = :store_id AND itemId = :item_id",
                    ExpressionAttributeValues={
                        ":store_id":  store_id,
                        ":item_id": item_id
                    }
                )
            
            for userReservation in reservations.get('Items',[]):
                userId = userReservation['userId']
                email = userReservation['email']
                item_list = userReservation['reserveItems',[]]
                
                if item_id in item_list:  # Only proceed if the itemId exists in the reservation
                    # Send email notification
                    message = f"The item {item_id} in store {store_id} is now back in stock!"
                    sns_client.publish(
                        TopicArn=SNS_TOPIC_ARN,
                        Message=message,
                        Subject="Item Back in Stock Notification",
                        MessageAttributes={
                            "email": {
                                "DataType": "String",
                                "StringValue": email
                            }
                        }
                    )

                    # Remove the itemId from the reservation
                    updated_item_list = [item for item in item_list if item != item_id]

                    if updated_item_list:  # If other items remain, update reservation
                        reservation_table.update_item(
                            Key={'userId': userId, 'storeId': store_id},
                            UpdateExpression="SET itemIds = :updated_item_list",
                            ExpressionAttributeValues={":updated_item_list": {"L": [{'S': i} for i in updated_item_list]}}
                        )
                    else:  # If no items left, delete reservation entry
                        reservation_table.delete_item(
                            Key={'userId': userId, 'storeId': store_id}
                        )
    return