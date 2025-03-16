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
        user_cart = cart_table.get_item(Key={'userId': userId, 'storeId': store_id})
        
        #create new cart if cart for userId and StoreId dont exist
        if 'Item' not in user_cart:
            return http_utils.generate_response(404, f"No cart for this user")
        
        existing_cart = user_cart['Item']
        
        for cart_item in existing_cart:
            