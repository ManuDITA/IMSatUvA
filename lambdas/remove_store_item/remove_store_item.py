import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
store_table = dynamodb.Table('store')

def lambda_handler(event, context):
    # Extract path parameters from the event
    store_id = event['pathParameters']['storeId']
    stock_id = event['pathParameters']['stockId']
    
    deleteAttributes = store_table.delete_item(store_id, ReturnValues='ALL_OLD')
    if len(deleteAttributes.keys() == 0):
        return 400, 'Store not found'
    
    # Extract body parameters from the event
    body = json.dumps(deleteAttributes)
    
    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res

