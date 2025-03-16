import json
import uuid
import boto3
import modules.http_utils as http_utils
import modules.getSubId as getSubId


dynamodb = boto3.resource("dynamodb")
store_table = dynamodb.Table('store')
cart_table = dynamodb.Table('cart')
item_table = dynamodb.Table('item')


def lambda_handler(event, context):
    userId = getSubId(event)
    
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
        user_cart = cart_table.get_item(Key={'userId': userId, 'storeId': store_id})
        
        #create new cart if cart for userId and StoreId dont exist
        if 'Item' not in user_cart:
            new_cart = {
                'userId' : userId,
                'storeId' : store_id,
                'items' : [],
                'totalPrice' : 0
            }
            
            cart_table.put_item(Item=new_cart)
        else:
            #fetch the cart that exists
            new_cart = user_cart['Item']

        #Retrieve store details
        store_information = store_table.get_item(Key={'storeId': store_id})
        if 'Item' not in store_information:
            return http_utils.generate_response(404, f"Store doesn't exist")
        
        #Check if store has any items
        store_items = store_information.get("items")
        if not store_items:
            return http_utils.generate_response(404, "No items found in the store")
        
            
        for stored_item in store_items:
            if stored_item["itemId"] == item_id:
                # if stock is less than asked, return error and ask for reserving instead
                if stored_item["quantity"] < quantity:
                    return http_utils.generate_response(400, f"Not enough quantity available in the store. Available: {stored_item['quantity']}, you can reserve if required.")
                
                # reduce stock quantity in the store
                stored_item["quantity"] -= quantity
                
                #get the item from the item table
                item_record = item_table.get_item(Key={'id': item_id})
                if 'Item' not in item_record:
                    return http_utils.generate_response(400, f"Item doesn't exist")
                
                price_per_item = item_record["price"]
                
                cart_items = new_cart.get("items", [])
                item_exists = False
                
                for cart_item in cart_items:
                    if cart_item["itemId"] == item_id:
                        cart_item["quantity"] += quantity
                        cart_item["totalPrice"] = cart_item["quantity"] * price_per_item
                        item_exists = True
                        break
                    
                if not item_exists:
                    cart_items.append({
                        "item_id" : item_id,
                        "name": item_record["name"],
                        "quantity": quantity,
                        "totalPrice": quantity * price_per_item
                    })    
                    
                new_cart["items"] = cart_items
                
                new_cart["totalPrice"] = sum(item["totalPrice"] for item in new_cart["items"])
                
                cart_table.put_item(Item=new_cart)
                
                store_table.update_item(
                    Key={"storeId": store_id},
                    UpdateExpression="SET items = :items",
                    ExpressionAttributeValues={":items": store_items}
                )
                return http_utils.generate_response(200, f"Item successfully added to cart")
        return http_utils.generate_response(404, "item not found in the store")
    
    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
         return http_utils.generate_response(500, f"Internal server error: {str(e)}")
    
    