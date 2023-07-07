"""lambda function to handle the confirmation of the forgot password request"""
import os
import logging
import hmac
import base64
import hashlib
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def _secret_hash(username):
    key = os.environ['client_secret'].encode()
    msg = bytes(username + os.environ['client_id'], 'utf-8')
    secret_hash = base64.b64encode(
        hmac.new(key, msg, digestmod=hashlib.sha256).digest()).decode()
    return secret_hash

def confirm_forgot_password(cognito_idp_client, **kwargs) -> str:
    """
    This method is in charge of change the user password on the user pool
    """
    kargs = {
        'ClientId': os.environ['client_id'],
        'Username': kwargs["kwargs"]["Username"],
        'Password': kwargs["kwargs"]["Password"],
        'ConfirmationCode': kwargs["kwargs"]["Code"]
    }
    if os.environ['client_secret']:
        kargs['SecretHash'] = _secret_hash(kwargs["kwargs"]["Username"])
    response = cognito_idp_client.confirm_forgot_password(**kargs)
    return response

def lambda_handler(event, context):
    """
    An AWS lambda handler that receives events from the Access API GW to
    confirm the new password. The lambda receives the confirmation code and
    the new password.

    :param username [str]: username of the user to change the password
    :param confirmation_code [str]: the confirmation code for the password change
    :param new_password [str]: the new password of the user
    """
    status_code = 200
    client = boto3.client('cognito-idp', os.environ['region_name'])
    try:
        confirm_forgot_password(client, kwargs=event)
        logger.info("Confirmed new password for user %s", event["Username"])
    except ClientError:
        logger.exception("Couldn't change password for user %s", event["Username"])
        status_code = 503
    return {"statusCode": str(status_code)}
