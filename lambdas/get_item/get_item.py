import boto3
import modules.http_utils as http_utils
import modules.converters as cv

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['pathParameters']['itemId']

    item = {}
    try:
        item = table.get_item(Key={'id': item_id})['Item']
        item = cv.convert_decimal(item)
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, item)
