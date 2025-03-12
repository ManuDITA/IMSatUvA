import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    store_id = event['id']

    store = {}
    try:
        store = table.get_item(store_id, ReturnValues='ALL_OLD')['Item']
    except KeyError:
        return 404, 'Resource not found'

    body = json.dumps(store)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
