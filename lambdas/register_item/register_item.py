import json
import uuid
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    body = json.loads(event['body'])

    item = {
        "id": body.get('id', str(uuid.uuid4())), # DynamoDB doesn't support raw UUIDs
        "name": body['name']
    }

    table.put_item(Item=item)
    body = json.dumps(item)

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
