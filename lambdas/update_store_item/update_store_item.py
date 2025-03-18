import json
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
stores_table = dynamodb.Table("store")  # Table storing store details


def lambda_handler(event, context):
    try:
        #Extract path parameters
        store_id = event['pathParameters']['storeId']
        item_id = event['pathParameters']['itemId']

        #Fetch store from DynamoDB
        store_response = stores_table.get_item(Key={'storeId': store_id})
        if 'Item' not in store_response:
            return http_utils.generate_response(404, "Store not found")
        store = store_response['Item']

        #Extract request body
        body = json.loads(event.get('body', '{}'))
        updated_quantity = body.get("quantity")

        if updated_quantity is None:
            return http_utils.generate_response(400, "No valid update fields provided. Please provide a quantity")

        # Get store's item list
        store_items = store.get("stockItems", [])
        item_found = False

        # Update item in the store's item list
        for item in store_items:
            if item["itemId"] == item_id:
                if updated_quantity is not None:
                    item["quantity"] = updated_quantity
                item_found = True
                break

        if not item_found:
            return http_utils.generate_response(404, "Item not found in store")

        # Update store record in DynamoDB
        stores_table.update_item(
            Key={'id': store_id},
            UpdateExpression="SET stockItems = :stockItems",
            ExpressionAttributeValues={":stockItems": store_items}
        )

        return http_utils.generate_response(200, {"message": "Item updated successfully"})

    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except json.JSONDecodeError:
        return http_utils.generate_response(400, "Invalid JSON format")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
