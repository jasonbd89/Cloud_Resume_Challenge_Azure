import json
import boto3
import os
from decimal import Decimal

# 1. Initialize outside the handler for better performance (Warm Starts)
dynamodb = boto3.resource('dynamodb')

# 2. Use the environment variable we defined in lambda.tf
TABLE_NAME = os.environ.get('TABLE_NAME')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        # Atomic update: increments 'views' by 1
        # 'id': 'visitors' matches the initial item we created in dynamodb.tf
        response = table.update_item(
            Key={'id': 'visitors'}, 
            UpdateExpression="SET #v = if_not_exists(#v, :zero) + :incr",
            ExpressionAttributeNames={'#v': 'views'},
            ExpressionAttributeValues={
                ':incr': 1,
                ':zero': 0
            },
            ReturnValues="UPDATED_NEW"
        )
        
        new_count = response['Attributes']['views']
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # Necessary for CORS
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'count': int(new_count)})
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal Server Error'})
        }