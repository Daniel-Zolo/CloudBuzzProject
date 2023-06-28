import json
import boto3

def lambda_handler(event, context):
    query_params = event.get('queryStringParameters')
    value1 = None
    value2 = None
    total = None
    
    if query_params is not None:
        value1 = query_params.get('key1')
        value2 = query_params.get('key2')
        
        if value1 is not None and value2 is not None:
            value1 = int(value1)
            value2 = int(value2)
            total = value1 + value2
    
    sns = boto3.client('sns')
    topic_arn = 'arn:aws:sns:eu-north-1:069301198269:SumSNS'
    message = f"The sum of {value1} and {value2} is {total}" if total is not None else "Invalid numbers"
    sns.publish(TopicArn=topic_arn, Message=message)
    
    return {
        'statusCode': 200,
        'body': json.dumps({'value1': value1, 'value2': value2, 'total': total})
    }
