import json
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
store_table = dynamodb.Table("store")

def lambda_handler(event, context):


    try:
        store_id = event['pathParameters']['storeId']
        item_id = event['pathParameters']['itemId']
        # Retrieve the store from the table
        response = store_table.get_item(Key={'id': store_id})
        if 'Item' not in response:
            return http_utils.generate_response(404, 'Store not found')
        
        store = response['Item']
        stock_items = store.get('stockItems', [])

        # Find the item in the store's stockItems array by itemId
        item_to_delete = next((item for item in stock_items if item['itemId'] == item_id), None)

        if item_to_delete is None:
            return http_utils.generate_response(404, 'Item not found in store')

        # Remove the item from the stockItems array
        stock_items = [item for item in stock_items if item['itemId'] != item_id]

        # Update the store with the new stockItems list
        store_table.update_item(
            Key={'id': store_id},
            UpdateExpression="SET stockItems = :stockItems",
            ExpressionAttributeValues={":stockItems": stock_items}
        )

        return http_utils.generate_response(200, {"message": "Item deleted successfully", "updatedItems": stock_items})

    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
