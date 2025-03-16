import boto3
import modules.http_utils as http_utils
import decimal

dynamodb = boto3.resource("dynamodb")
cart_table = dynamodb.Table('cart')

def lambda_handler(event, context):
     # Extract the caller's user ID from cognitoAuthenticationProvider
    auth_provider = event['requestContext']['identity']['cognitoAuthenticationProvider']
    userId = auth_provider.split(':')[-1]  # Extract the user ID (last part of the string)
    
    if not userId:
        return http_utils.generate_response(401, 'Not authorized')
    
    try:
        store_id = event['pathParameters']['storeId']
        
        user_cart = cart_table.get_item(Key={'userId': userId, 'storeId': store_id})
    
        #create new empty cart if cart for UserId and StoreId dont exist
        if 'Item' not in user_cart:
            print(f"Item wasn't find so we will add one")
            new_cart = {
                'userId' : userId,
                'storeId' : store_id,
                'cartItems' : [],
                'totalCartPrice' : 0
            }
            cart_table.put_item(Item=new_cart)
            existing_cart = new_cart
            
        else:
            print(f"Ended up here because cart does exist")
            #fetch the cart that exists
            existing_cart = user_cart['Item']
        
        
        return http_utils.generate_response(200, convert_decimal(existing_cart))
    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
    

def convert_decimal(obj):
    # Recursively convert Decimal from dynamoDb to int as json doesn't accept otherwise.
    
    if isinstance(obj, list):
        return [convert_decimal(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: convert_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, decimal.Decimal):
        return int(obj) 
    return obj


