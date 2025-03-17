import boto3
import modules.http_utils as http_utils
import modules.converters as cv

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table('store')


def lambda_handler(event, context):
    # This has a 1MB limit and is not sequentially consistent
    stores = table.scan()['Items']
    stores = cv.convert_decimal(stores)
    return http_utils.generate_response(200, stores)
