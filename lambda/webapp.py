import json
import boto3
import os
import base64
from botocore.client import Config

s3_client = boto3.client('s3', region_name='eu-central-1', config=Config(signature_version='s3v4'))

def lambda_handler(event, context):
    try:
        bucket_name = event['queryStringParameters']['bucket']
        object_key = event['queryStringParameters']['file']
    except (KeyError, TypeError):
        return {"statusCode": 400, "body": json.dumps({"error": "Bad Request: 'bucket' and 'file' query string parameters are required."})}
    
    try:
        s3_object = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        
        image_content = s3_object['Body'].read()
        
        return {
            "statusCode": 200,
            "headers": { "Content-Type": "image/jpeg" }, # Or image/png
            "body": base64.b64encode(image_content).decode('utf-8'),
            "isBase64Encoded": True 
        }
    except Exception as e:
        print(f"Error getting object from S3: {e}")
        return {"statusCode": 404, "body": json.dumps({"error": f"Object '{object_key}' not found in bucket '{bucket_name}'."})}

