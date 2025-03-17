import json
import uuid
import boto3
from decimal import Decimal
import modules.http_utils as http_utils


dynamodb = boto3.resource("dynamodb")
store_table = dynamodb.Table('store')
cart_table = dynamodb.Table('cart')
item_table = dynamodb.Table('item')


def lambda_handler(event, context):
    # Extract the caller's user ID from cognitoAuthenticationProvider
    auth_provider = event['requestContext']['identity']['cognitoAuthenticationProvider']
    userId = auth_provider.split(':')[-1]  # Extract the user ID (last part of the string)
    
    if not userId:
        return http_utils.generate_response(401, 'Not authorized')
    
    try:
        store_id = event['pathParameters']['storeId']
        item_id = event['pathParameters']['itemId']
        
        store_information = store_table.get_item(Key={'id': store_id})
        
        if 'Item' not in store_information:
            return http_utils.generate_response(404,f"store doesnt exist")
        
        user_cart = cart_table.get_item(Key={'userId': userId, 'storeId': store_id})
        
        if 'Item' not in user_cart:
            return http_utils.generate_response(400,f'Cart does not exist')
        
        existing_cart = user_cart['Item']
        print(existing_cart)
        cart_items = existing_cart.get("cartItems", [])
        print(cart_items)
        item_exists = False
        
        for cart_item in cart_items:
            if cart_item["itemId"] == item_id:
                item_exists = True
                quantity = cart_item["quantity"]
                cart_items = [prod for prod in cart_items if prod["itemId"] != item_id] #filtering out the item id
                break
        
        if not item_exists:
            return http_utils.generate_response(404, f'Item doesnt not exist in the cart')
        
        #re-calculating the total price of the cart
        existing_cart["cartItems"] = cart_items
        existing_cart["totalCartPrice"] = str(sum(Decimal(item["totalItemPrice"]) for item in cart_items))
        
        cart_table.update_item(
            Key={'userId': userId, 'storeId': store_id},
            UpdateExpression="SET cartItems = :cartItems, totalCartPrice = :totalCartPrice",
            ExpressionAttributeValues={
                    ':cartItems': existing_cart["cartItems"],
                    ':totalCartPrice': str(sum(Decimal(item["totalItemPrice"]) for item in existing_cart["cartItems"]))
                }
            )
        
        #increase the stock in the store since item is removed from the cart
        store_items = store_information.get("Item", {}).get("stockItems", [])
        for stored_item in store_items:
            if stored_item["itemId"] == item_id:
                stored_item["quantity"] += quantity
                break
        
        store_table.update_item(
                    Key={"id": store_id},
                    UpdateExpression="SET stockItems = :stockItems",
                    ExpressionAttributeValues={":stockItems": store_items}
                )
        
        return http_utils.generate_response(200,f"item successfully removed from cart")
    
    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
    