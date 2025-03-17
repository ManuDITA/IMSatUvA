import json
import boto3

dynamodb = boto3.resource("dynamodb")
reservation_table = dynamodb.Table('user-stock-reserve')
sns_client = boto3.client('sns', region_name="eu-west-3")
SNS_TOPIC_ARN = 'arn:aws:sns:eu-west-3:225989358926:lowstock'
cognito_client = boto3.client('cognito-idp')
USER_POOL_ID = os.environ['USER_POOL_ID']

def lambda_handler(event, context):
    low_stock_list = {}  
    for record in event['Records']:
        if record['eventName'] == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            
            # Safely retrieve stockItems
            store_id = new_image['id']['S']
            new_stock_items = {item['M']['itemId']['S']: int(item['M']['quantity']['N']) for item in new_image['stockItems']['L']}
            
            # Check for items with a quantity less than 5
            for item_id, quantity in new_stock_items.items():
                if quantity < 5:
                    # Collect notifications for this store
                    if store_id not in low_stock_list:
                        low_stock_list[store_id] = []
                    low_stock_list[store_id].append(item_id)

    if low_stock_list:
        for store_id, items in low_stock_list.items():
            email_message = f"The following items in store {store_id} are now below 5:\n" + "\n".join(items)
            try:
                response = cognito_client.list_users_in_group(
                    UserPoolId=USER_POOL_ID,
                    GroupName ='admin'
                    
                )
                
                for user in response['Users']:
                    email = None
                    for attr in user['Attributes']:
                        if attr['Name'] == 'email':
                            email = attr['Value']
                            break
                    if email:
                        #we need to check if the user email is subscribed to the topic (done on the console) else it wont work.
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