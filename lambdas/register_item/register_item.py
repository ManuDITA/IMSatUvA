import json
import uuid
import boto3
import modules.http_utils as http_utils

# AWS X-Ray tracing for invoked resources
# Source: https://github.com/aws/aws-xray-sdk-python/blob/master/docs/thirdparty.rst
from aws_xray_sdk.core import patch_all
patch_all()

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    body = json.loads(event['body'])

    # Validate required fields
    if "name" not in body or "price" not in body:
        missing_fields = [field for field in ["name", "price"] if field not in body]
        return http_utils.generate_response(400, f"Missing required fields: {', '.join(missing_fields)}")


    item = {
        "id"   : body.get('id', str(uuid.uuid4())), # DynamoDB doesn't support raw UUIDs
        "name" : body['name'],
        "price": body['price']
    }

    table.put_item(Item=item)
    return http_utils.generate_response(200, item)
