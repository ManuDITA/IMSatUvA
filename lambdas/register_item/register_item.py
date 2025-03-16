import json
import uuid
import boto3
from decimal import Decimal
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    body = json.loads(event['body'])

    # Validate required fields
    if 'name' not in body:
        return http_utils.generate_response(400, f'Missing required fields: {[].join([field for field in ["name"] if field not in body])}')

    if 'price' not in body:
        return http_utils.generate_response(400, f'Missing required fields: {[].join([field for field in ["price"] if field not in body])}')

    item = {
        "id": body.get('id', str(uuid.uuid4())), # DynamoDB doesn't support raw UUIDs
        "name": body['name'],
        "price": Decimal(str(body['price']))
    }

    table.put_item(Item=item)
    return http_utils.generate_response(200, item)
