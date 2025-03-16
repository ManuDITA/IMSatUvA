import json
import uuid
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('cart')

def lambda_handler(event, context):
    
    store = {}
    try:
        store = table.get_item(Key={'id': store_id})['Item']
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, store)


