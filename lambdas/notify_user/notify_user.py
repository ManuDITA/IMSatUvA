import json
import boto3

dynamodb = boto3.resource("dynamodb")
reservation_table = dynamodb.Table('user-stock-reserve')
sns_client = boto3.client('sns', region_name="eu-west-3")
SNS_TOPIC_ARN = 'arn:aws:sns:eu-west-3:225989358926:stockAvailable'

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            old_image = record['dynamodb']['OldImage']
            print(f"This is new: {json.dumps(new_image)}")
            print(f"This is old: {json.dumps(old_image)}")
            
            # Safely retrieve stockItems
            store_id = new_image['id']['S']
            new_stock_items = {item['M']['itemId']['S']: int(item['M']['quantity']['N']) for item in new_image['stockItems']['L']}
            old_stock_items = {item['M']['itemId']['S']: int(item['M']['quantity']['N']) for item in old_image['stockItems']['L']}
            
            # Check which items have changed
            updated_items = [item_id for item_id in new_stock_items if new_stock_items[item_id] > old_stock_items.get(item_id, 0)]
            print(f"Updated items: {updated_items}")
            if not updated_items:
                continue  # No items restocked
            try:
                # Fetch reservations(itemId and storeID are also GSI)
                for item_id in updated_items:
                    reservations = reservation_table.query(
                        IndexName='storeId-index',
                        KeyConditionExpression="storeId = :store_id",
                        ExpressionAttributeValues={
                            ":store_id": store_id
                    }
                    )
                    
                    print(f"Reservations: {json.dumps(reservations)}")
                    for userReservation in reservations.get('Items', []):
                        print(f"User reservation: {json.dumps(userReservation)}")
                        userId = userReservation['userId']
                        email = userReservation['email']
                        item_list = userReservation['reserveItems']
                        print(f"Item list: {item_list}")
                        # Check if there's any intersection between item_list and updated_items
                        matching_items = set(item_list).intersection(updated_items)
                        print(f"Matching items: {matching_items}")
                        if matching_items:
                            print(f"Matching items 2: {matching_items}")
                            for item_id in matching_items:  # Only proceed if the itemId exists in the reservation
                                # Send email notification
                                message = f"The item you reserved is back in stock!"
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
                                        UpdateExpression="SET reserveItems = :updated_item_list",
                                        ExpressionAttributeValues={":updated_item_list": {"L": [{'S': i} for i in updated_item_list]}}
                                    )
                                else:  # If no items left, delete reservation entry
                                    reservation_table.delete_item(
                                        Key={'userId': userId, 'storeId': store_id}
                                    )
            except Exception as e:
                print(f"An error occurred: {e}")
    return
