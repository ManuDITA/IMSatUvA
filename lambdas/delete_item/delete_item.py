import boto3
import modules.http_utils as http_utils
import modules.converters as cv

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('item')


def lambda_handler(event, context):
    item_id = event['pathParameters']['itemId']
    
    response = {}
    try:
        response = table.delete_item(Key={'id': item_id}, ReturnValues='ALL_OLD')
        response = cv.convert_decimal(response)
    except KeyError:
        return http_utils.generate_response(404, 'Resource not found')

    # If the item was not found, the response will not contain the 'Attributes' key
    if 'Attributes' not in response:
        return http_utils.generate_response(404, 'Resource not found')

    return http_utils.generate_response(200, response['Attributes'])
