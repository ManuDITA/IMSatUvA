import boto3
import os

dynamodb = boto3.resource("dynamodb")
reservation_table = dynamodb.Table('user-stock-reserve')
sns_client = boto3.client('sns', region_name="eu-west-3")
cognito_client = boto3.client('cognito-idp')

SNS_TOPIC_ARN = 'arn:aws:sns:eu-west-3:225989358926:lowstock'
USER_POOL_ID = os.environ['USER_POOL_ID']

def lambda_handler(event, context):
    low_stock_list = {}  
    for record in event['Records']:
        if record['eventName'] == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            
            # Safely retrieve stockItems if it exists
            store_id = new_image['id']['S']

            # Check if stock actually  exists
            if 'stockItems' in new_image: 
                new_stock_items = {item['M']['itemId']['S']: int(item['M']['quantity']['N']) for item in new_image['stockItems']['L']}

                # Check for items with a quantity less than 3
                for item_id, quantity in new_stock_items.items():
                    if quantity < 3:
                        if store_id not in low_stock_list:
                            low_stock_list[store_id] = []
                        low_stock_list[store_id].append(item_id)
            else:
                continue  # Skip this record if stockItems is not present

    if low_stock_list:
        for store_id, items in low_stock_list.items():
            email_message = f"The following items in store {store_id} are now below 3:\n" + "\n".join(items)
            try:
                response = cognito_client.list_users_in_group(
                    UserPoolId=USER_POOL_ID,
                    GroupName='Admins'
                )
                
                #send email to all subscribed admins
                for user in response['Users']:
                    email = None
                    for attr in user['Attributes']:
                        if attr['Name'] == 'email':
                            email = attr['Value']
                            break
                    
                    if email:
                        # Check if the user email is subscribed to the topic
                        subscriptions = sns_client.list_subscriptions_by_topic(TopicArn=SNS_TOPIC_ARN)
                        is_subscribed = any(sub['Endpoint'] == email for sub in subscriptions['Subscriptions'])
                        
                        if is_subscribed:     
                            sns_client.publish(
                                TopicArn=SNS_TOPIC_ARN,
                                Message=email_message,
                                Subject="Items Below Stock Notification",
                                MessageAttributes={
                                    "email": {
                                        "DataType": "String",
                                        "StringValue": email  
                                    }
                                }
                            )
            except Exception as e:
                print(f"Error sending notification for store {store_id}: {e}")

    return
