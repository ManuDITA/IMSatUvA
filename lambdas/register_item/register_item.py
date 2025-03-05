import json
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_name = event['name']

    item = {
        "id": uuid.uuid4(),
        "name": item_name
    }

    table.put_item(item)
    body = json.dumps(item)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
