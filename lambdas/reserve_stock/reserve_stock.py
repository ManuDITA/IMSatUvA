import json
import boto3
import modules.http_utils as http_utils


dynamodb = boto3.resource("dynamodb")
reservation_table = dynamodb.Table('user-stock-reserve')
sns_client = boto3.client('sns', region_name= "eu-west-3")
SNS_TOPIC_ARN = 'arn:aws:sns:eu-west-3:225989358926:stockAvailable'


def lambda_handler(event, context):
    # Extract the caller's user ID from cognitoAuthenticationProvider
    auth_provider = event['requestContext']['identity']['cognitoAuthenticationProvider']
    userId = auth_provider.split(':')[-1]  # Extract the user ID (last part of the string)
    
    if not userId:
        return http_utils.generate_response(401, 'Not authorized')
    
    try:
        store_id = event['pathParameters']['storeId']
        item_id = event['pathParameters']['itemId']
        body = json.loads(event['body'])
        
        
        # Validate required fields
        if "email" not in body or "quantity" not in body:
            missing_fields = [field for field in ["email", "quantity"] if field not in body]
            return http_utils.generate_response(400, f"Missing required fields: {', '.join(missing_fields)}")

        email = body['email']
        quantity = body['quantity']
        
        #store reservation 
        existing_reservations = reservation_table.get_item(Key={'userId': userId, 'storeId': store_id})
        
        if 'Item' in existing_reservations:
            existing_items = existing_reservations['Item'].get('reserveItems', [])
            
            existing_items.append(item_id)
            
            reservation_table.update_item(Key={
                'userId': userId,
                'storeId': store_id
            },
                                        
            UpdateExpression ='SET reserveItems = :reserveItems',
            ExpressionAttributeValues={
                ':reserveItems': existing_items
            })
            
            return http_utils.generate_response(200, 'More items added for reservation, you will be notified when in stock')
        
        reservation = {
            'userId' : userId,
            'storeId' : store_id,
            'email': email,
            'reserveItems': [item_id]
        }
        # Subscribe user to SNS topic
        subscribe_user_to_sns(email)
        reservation_table.put_item(Item=reservation)
        
        return http_utils.generate_response(200, 'Item reserved successfully, you will be notified when in stock')

    except KeyError as e:
        return http_utils.generate_response(400, f"Missing required parameter: {str(e)}")
    except Exception as e:
        return http_utils.generate_response(500, f"Internal server error: {str(e)}")


def subscribe_user_to_sns(email):
    try:
        response = sns_client.subscribe(
        TopicArn=SNS_TOPIC_ARN,
        Protocol='email',
        Endpoint=email
        )
        print(f'Subscription response: {response}')
    except Exception as e:
        print(f'Error subscribing user to SNS: {str(e)}')