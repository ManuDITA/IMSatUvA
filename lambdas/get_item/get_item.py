import json
import boto3
import modules.http_utils as http_utils

# AWS X-Ray tracing for invoked resources
# Source: https://github.com/aws/aws-xray-sdk-python/blob/master/docs/thirdparty.rst
from aws_xray_sdk.core import patch_all
patch_all()

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['pathParameters']['itemId']

    item = {}
    try:
        item = table.get_item(Key={'id': item_id})['Item']
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, item)
