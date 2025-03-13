import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['pathParameters']['itemId']
    
    response = {}
    try:
        response = table.delete_item(Key={'id': item_id}, ReturnValues='ALL_OLD')
    except KeyError:
        return 404, 'Resource not found'

    # If the item was not found, the response will not contain the 'Attributes' key
    if 'Attributes' not in response:
        return 404, 'Resource not found'

    body = json.dumps(response['Attributes'])

    res = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }

    return res
