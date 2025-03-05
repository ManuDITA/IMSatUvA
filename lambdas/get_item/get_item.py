import json
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['id']

    item = {}
    try:
        item = table.get_item(item_id, ReturnValues='ALL_OLD')['Item']
    except KeyError:
        return 400, 'Resource not found'

    body = json.dumps(item)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
