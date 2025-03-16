import json
import boto3
import modules.http_utils as http_utils

dynamodb = boto3.resource("dynamodb")
store_table = dynamodb.Table("store")


def lambda_handler(event, context):
    store_id = event['pathParameters']['storeId']
    item_id = event['pathParameters']['itemId']

    try:
        response = store_table.delete_item(
            Key={'id': store_id, 'itemId': item_id},
            ReturnValues='ALL_OLD'
        )
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    # If the item was not found, the response will not contain the 'Attributes' key
    if 'Attributes' not in response:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, response['Attributes'])
