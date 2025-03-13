import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['pathParameters']['itemId']

    item = {}
    try:
        item = table.get_item(Key={'id': item_id})['Item']
    except KeyError:
        return 404, 'Resource not found'

    body = json.dumps(item)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
