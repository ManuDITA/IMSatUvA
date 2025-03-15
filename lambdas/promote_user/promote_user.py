import json
import boto3
import modules.http_utils as http_utils
import os

cognito_client = boto3.client('cognito-idp')
USER_POOL_ID = os.environ['USER_POOL_ID']

def lambda_handler(event, context):
    username = event['pathParameters']['username']
    body = json.loads(event['body'])
    group_name = body['groupName']

    try:
        # Add the user to the specified group
        cognito_client.admin_add_user_to_group(
            UserPoolId=USER_POOL_ID,
            Username=username,
            GroupName=group_name
        )

        return http_utils.generate_response(200, f"User '{username}' added to group '{group_name}'")
    except cognito_client.exceptions.ResourceNotFoundException:
        return http_utils.generate_response(404, f"User or group not found")
    except Exception as e:
        return http_utils.generate_response(500, f"Error adding user to group: {str(e)}")