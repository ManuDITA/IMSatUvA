import json
import boto3
from botocore.exceptions import ClientError

# AWS X-Ray tracing for invoked resources
# Source: https://github.com/aws/aws-xray-sdk-python/blob/master/docs/thirdparty.rst
from aws_xray_sdk.core import patch_all
patch_all()

dynamodb = boto3.resource('dynamodb')
store_items_table = dynamodb.Table('InventoryItem')

def lambda_handler(event, context):
    # Extract path parameters from the event
    store_id = event['pathParameters']['storeId']
    stock_id = event['pathParameters']['stockId']
    
    # Extract body parameters from the event
    body = json.loads(event['body'])
    quantity = body['quantity']
    to_store = body['toStore']

    try:
        {
        }
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'message': 'Error moving item.',
                'error': str(e)
            })
        }
