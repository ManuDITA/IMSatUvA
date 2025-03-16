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
        body = json.loads(event['body'])
        
        # Validate required fields
        if 'quantity' not in body:
            return http_utils.generate_response(400, f'Missing required fields: {[].join([field for field in ["quantity"] if field not in body])}')
        
        quantity = body['quantity']
        
        existing_cart = get_cart(userId, store_id)
        store = get_store(store_id)
        
        if not store:
            return http_utils.generate_response(404, f"Store doesn't exist")
        
        # Check if store has any items
        store_items = store.get("Item", {}).get("stockItems", [])
        if not store_items:
            return http_utils.generate_response(404, "No items found in the store")
        
        #Process the item in the store
        for stored_item in store_items:
            if stored_item["itemId"] == item_id:
                
                # if stock is less than asked, return error and ask for reserving instead
                if stored_item["quantity"] < quantity:
                    return http_utils.generate_response(400, f"Not enough quantity available in the store. Available: {stored_item['quantity']}, you can reserve if required.")
                
                # reduce stock quantity in the store
                stored_item["quantity"] -= quantity
                
                #get the necessary item
                item_record = get_item(item_id)
                
                if not item_record:
                    return http_utils.generate_response(400, "Item doesn't exist")
                
                price_per_item = Decimal(item_record['Item']['price'])
                cart_items = existing_cart.get("cartItems", [])
                
                #Add or update cart item
                item_exists = update_cart_items(cart_items, item_id, quantity, price_per_item)
                    
                if not item_exists:
                    cart_items.append({
                        "itemId" : item_id,
                        "name": item_record['Item']["name"],
                        "quantity": quantity,
                        "totalItemPrice": str(quantity * price_per_item)
                    })    
                    
                existing_cart["cartItems"] = cart_items
                
                existing_cart["totalCartPrice"] = str(sum(Decimal(item["totalItemPrice"]) for item in existing_cart["cartItems"]))
                
                cart_table.put_item(Item=existing_cart)
                
                store_table.update_item(
                    Key={"id": store_id},
                    UpdateExpression="SET stockItems = :stockItems",
                    ExpressionAttributeValues={":stockItems": store_items}
                )
                return http_utils.generate_response(200, f"Item successfully added to cart")
        return http_utils.generate_response(404, "item not found in the store")
    
    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
    

def get_cart(userId, store_id):
    user_cart = cart_table.get_item(Key={'userId': userId, 'storeId': store_id})
    if 'Item' not in user_cart:
        new_cart = {
            'userId' : userId,
            'storeId' : store_id,
            'cartItems' : [],
            'totalCartPrice' : 0
        }
        
        cart_table.put_item(Item=new_cart)
        return new_cart
    return user_cart['Item']

def get_store(store_id):
    store_information = store_table.get_item(Key={'id': store_id})
    return store_information.get('Item') if 'Item' in store_information else None

def get_item(item_id):
    item_record = item_table.get_item(Key={'id': item_id})
    return item_record.get('Item') if 'Item' in item_record else None

def update_cart_items(cart_items, item_id, quantity, price_per_item):
    for cart_item in cart_items:
        if cart_item["itemId"] == item_id:
            cart_item["quantity"] += quantity
            cart_item["totalItemPrice"] = str(Decimal(cart_item["quantity"]) * price_per_item)
            return True
    return False