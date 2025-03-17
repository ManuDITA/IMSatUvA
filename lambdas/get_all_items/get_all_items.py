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
    # This has a 1MB limit and is not sequentially consistent
    return http_utils.generate_response(200, table.scan()['Items'])
