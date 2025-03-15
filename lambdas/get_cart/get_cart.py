import json
import uuid
import boto3
import modules.http_utils as http_utils
import modules.getSubId as getSubId

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('cart')

def lambda_handler(event, context):
  
    userId = getSubId(event)
    if not userId:
        return http_utils.generate_response(401, 'Not authorized')
    
    
    
    store = {}
    try:
        store = table.get_item(Key={'id': store_id})['Item']
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, store)


