import json
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
stores_table = dynamodb.Table("store")  # Table storing store details


def lambda_handler(event, context):
    try:
        # Extract request body
        body = json.loads(event.get('body', '{}'))
        fromStoreId = body.get("fromStoreId")
        toStoreId = body.get("toStoreId")
        itemId = body.get("itemId")
        quantity = body.get("quantity")

        if quantity is None or quantity <= 0:
            return http_utils.generate_response(400, "Invalid quantity for transfer")

        # Fetch source store from DynamoDB
        source_response = stores_table.get_item(Key={'id': fromStoreId})
        if 'Item' not in source_response:
            return http_utils.generate_response(404, "Source store not found")
        source_store = source_response['Item']

        # Fetch destination store from DynamoDB
        destination_response = stores_table.get_item(Key={'id': toStoreId})
        if 'Item' not in destination_response:
            return http_utils.generate_response(404, "Destination store not found")
        destination_store = destination_response['Item']

        # Get stock items from both stores
        source_stock_items = source_store.get("stockItems", [])
        destination_stock_items = destination_store.get("stockItems", [])

        # Find item in source store
        source_item = next((item for item in source_stock_items if item["itemId"] == itemId), None)
        if not source_item:
            return http_utils.generate_response(404, "Item not found in source store")

        if source_item["quantity"] < quantity:
            return http_utils.generate_response(400, "Not enough stock available")

        # Deduct quantity from source store
        source_item["quantity"] -= quantity
        if source_item["quantity"] == 0:
            source_stock_items.remove(source_item)

        # Find item in destination store
        destination_item = next((item for item in destination_stock_items if item["itemId"] == itemId), None)

        if destination_item:
            destination_item["quantity"] += quantity
        else:
            destination_stock_items.append(source_item)

        # Update both stores in DynamoDB
        stores_table.update_item(
            Key={'id': fromStoreId},
            UpdateExpression="SET stockItems = :stockItems",
            ExpressionAttributeValues={":stockItems": source_stock_items}
        )

        stores_table.update_item(
            Key={'id': toStoreId},
            UpdateExpression="SET stockItems = :stockItems",
            ExpressionAttributeValues={":stockItems": destination_stock_items}
        )

        return http_utils.generate_response(200, {"message": "Stock moved successfully"})

    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except json.JSONDecodeError:
        return http_utils.generate_response(400, "Invalid JSON format")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
