#Forwarding CloudWatch Logs to Azure Sentinel: We’ll modify the Lambda function that forwards logs to Azure Sentinel to 
#handle the sensitive data findings from Macie, allowing these logs to be integrated into Sentinel.

import json
import requests
import base64
import gzip
from datetime import datetime

def lambda_handler(event, context):
    # Extract logs from CloudWatch event
    compressed_data = base64.b64decode(event['awslogs']['data'])
    data = gzip.decompress(compressed_data)
    logs = json.loads(data.decode('utf-8'))

    # Azure Sentinel HTTP Data Collector API details
    sentinel_url = "<Azure_Sentinel_Endpoint>"
    workspace_id = "<Workspace_ID>"
    shared_key = "<Shared_Key>"

    # Prepare the log data in the required format for Sentinel
    log_data = {
        "records": []
    }

    for log_event in logs['logEvents']:
        log_data['records'].append({
            "Time": log_event['timestamp'],
            "Message": log_event['message']
        })

    # Send data to Azure Sentinel
    headers = {
        'Content-Type': 'application/json',
        'Log-Type': 'AWSMacieFindings',
        'x-ms-date': datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT'),
        'Authorization': f"SharedKey {workspace_id}:{shared_key}"
    }

    response = requests.post(sentinel_url, headers=headers, json=log_data)

    if response.status_code == 200:
        print("Log successfully ingested into Azure Sentinel")
    else:
        print(f"Failed to ingest log into Azure Sentinel: {response.text}")

    return {
        'statusCode': 200,
        'body': json.dumps('Log processing completed')
    }
