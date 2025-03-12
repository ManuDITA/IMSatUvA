import json
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    store_name = event['name']
    store_address = event['address']

    store = {
        "id": uuid.uuid4(),
        "name": store_name,
        "address": store_address
    }

    table.put_item(store)
    body = json.dumps(store)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
