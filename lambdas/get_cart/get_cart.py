import json
import uuid
import boto3
import modules.http_utils as http_utils

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
        if not user_cart :
            return http_utils.generate_response(400, f"Cart doesn't exist for this user in this store, call add item to cart to create new")
        
        return http_utils.generate_response(200, user_cart)
    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")
    



