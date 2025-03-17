import json
import uuid
import boto3
import modules.http_utils as http_utils

# AWS X-Ray tracing for invoked resources
# Source: https://github.com/aws/aws-xray-sdk-python/blob/master/docs/thirdparty.rst
from aws_xray_sdk.core import patch_all
patch_all()

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    body = json.loads(event['body'])
    
    # Validate required fields
    if 'name' not in body or 'address' not in body:
        return http_utils.generate_response(400, f'Missing required fields: {[].join([field for field in ["name", "address"] if field not in body])}')

    store = {
        "id": body.get('id', str(uuid.uuid4())), # DynamoDB doesn't support raw UUIDs
        "name": body['name'],
        "address": body['address']
    }

    table.put_item(Item=store)
    return http_utils.generate_response(200, store)
