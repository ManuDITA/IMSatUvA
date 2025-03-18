import json
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
stores_table = dynamodb.Table("store")  # Table storing store details
items_table = dynamodb.Table("item")    # Table storing item details


def lambda_handler(event, context):
    try:
        store_id = event['pathParameters']['storeId']
        item_id = event['pathParameters']['itemId']

        store_response = stores_table.get_item(Key={'id': store_id})
        if 'Item' not in store_response:
            return http_utils.generate_response(404, "Store not found")
        store = store_response['Item']

        # Get item from item table (id of the item: id)
        item_response = items_table.get_item(Key={'id': item_id})
        if 'Item' not in item_response:
            return http_utils.generate_response(404, "Item not found")
        item = item_response['Item']

        # Extract optional request body
        body = json.loads(event.get('body', '{}'))
        new_item = {
            "itemId": item_id,
            "quantity": body.get("quantity", 1),  # Default quantity = 1
        }

        # Check if items array exists in store, else create it
        stock_items = store.get("stockItems", [])

        # Check if item already exists in store
        for stored_item in stock_items:
            if stored_item["itemId"] == item_id:
                # Update quantity of existing item
                stored_item["quantity"] += new_item["quantity"]  
                break
        else:
            # Add new item since no existing item found
            stock_items.append(new_item)

        # Update store with modified items list
        stores_table.update_item(
            Key={'id': store_id},
            UpdateExpression="SET stockItems = :stockItems",
            ExpressionAttributeValues={":stockItems": stock_items}
        )

        return http_utils.generate_response(201, {"message": "Item added to store"})

    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
