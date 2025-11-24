import json
import boto3
import os
import base64
import re
import urllib.parse
from botocore.client import Config


s3_client = boto3.client(
    's3',
    region_name='eu-central-1',
    config=Config(signature_version='s3v4')
)

def lambda_handler(event, context):

    bucket_name = os.environ.get("BUCKET_NAME")
    regex = re.compile(r"^[a-zA-Z0-9!@#$%&]*$")

    try:
        file_key_input = event['queryStringParameters']['file']
    except (KeyError, TypeError):
        return {"statusCode": 400, "body": json.dumps({"error": "Missing file parameter."})}

    if not regex.match(file_key_input):
        return {"statusCode": 400, "body": json.dumps({"error": "Invalid characters in filename."})}

    filename = urllib.parse.unquote(file_key_input)
    
    raw_path = "public/" + filename + ".png"

    final_s3_key = os.path.normpath(raw_path)

    try:
        s3_object = s3_client.get_object(Bucket=bucket_name, Key=final_s3_key)
        content_bytes = s3_object['Body'].read()
        content_type = s3_object.get('ContentType', 'application/octet-stream')

        if 'text' in content_type:
             return {
                "statusCode": 200,
                "headers": { "Content-Type": content_type },
                "body": content_bytes.decode('utf-8')
            }
        else:
            return {
                "statusCode": 200,
                "headers": { "Content-Type": content_type },
                "body": base64.b64encode(content_bytes).decode('utf-8'),
                "isBase64Encoded": True 
            }
    except Exception as e:
        return {"statusCode": 404, "body": json.dumps({"error": f"File {final_s3_key} not found (Raw path was: {raw_path})."})}
