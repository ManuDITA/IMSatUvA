import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    store_id = event['id']

    deleteAttributes = table.delete_item(store_id, ReturnValues='ALL_OLD')
    if len(deleteAttributes.keys() == 0):
        return 400, 'Resource not found'

    body = json.dumps(deleteAttributes)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
