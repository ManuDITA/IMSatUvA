import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
store_items_table = dynamodb.Table('InventoryItem')

def lambda_handler(event, context):
    # Extract path parameters from the event
    store_id = event['pathParameters']['storeId']
    stock_id = event['pathParameters']['stockId']
    
    # Extract body parameters from the event
    body = json.loads(event['body'])
    quantity = body['quantity']
    to_store = body['toStore']

    try:
        # Step 1: Retrieve the current quantity from the source store
        response_source = store_items_table.get_item(
            Key={
                'storeId': store_id,
                'stockId': stock_id
            }
        )
        
        # Check if the item exists in the source store
        if 'Item' not in response_source:
            return {
                'statusCode': 404,
                'body': json.dumps({
                    'message': 'Item not found in the source store.'
                })
            }
        
        current_quantity = response_source['Item']['quantity']
        
        # Step 2: Check if sufficient quantity is available
        if current_quantity < quantity:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'message': 'Insufficient quantity in the source store.'
                })
            }
        
        # Step 3: Update the quantity in the source store
        store_items_table.update_item(
            Key={
                'storeId': store_id,
                'stockId': stock_id
            },
            UpdateExpression='SET quantity = quantity - :quantity',
            ExpressionAttributeValues={
                ':quantity': quantity
            }
        )
        
        # Step 4: Update the quantity in the target store
        store_items_table.update_item(
            Key={
                'storeId': to_store,
                'stockId': stock_id
            },
            UpdateExpression='ADD quantity :quantity',
            ExpressionAttributeValues={
                ':quantity': quantity
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Item moved successfully.'
            })
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'message': 'Error moving item.',
                'error': str(e)
            })
        }
