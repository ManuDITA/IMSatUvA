import boto3
import modules.http_utils as http_utils
import modules.converters as cv

# AWS X-Ray tracing for invoked resources
# Source: https://github.com/aws/aws-xray-sdk-python/blob/master/docs/thirdparty.rst
from aws_xray_sdk.core import patch_all
patch_all()

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    # This has a 1MB limit and is not sequentially consistent
    stores = table.scan()['Items']
    stores = cv.convert_decimal(stores)
    return http_utils.generate_response(200, stores)
