import requests
import json
import time
import base64
from datetime import datetime
import boto3
from botocore.exceptions import NoCredentialsError

# Define Azure Sentinel workspace details
WORKSPACE_ID = "your-sentinel-workspace-id"  # Replace with your Sentinel Workspace ID
WORKSPACE_KEY = "your-sentinel-workspace-key"  # Replace with your Sentinel Workspace Key
LOG_TYPE = "CloudWatchLogs"  # Custom log type for Azure Sentinel

# Initialize AWS CloudWatch client
cloudwatch_logs = boto3.client('logs', region_name='us-east-1')  # Replace with your region

# Function to send log data to Azure Sentinel
def send_to_sentinel(log_data):
    url = f'https://{WORKSPACE_ID}.ods.opinsights.azure.com/api/logs?api-version=2016-04-01'
    
    # Construct the authorization header
    x_ms_date = datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
    signature = generate_signature(x_ms_date, log_data)
    
    headers = {
        'Content-Type': 'application/json',
        'Log-Type': LOG_TYPE,  # Custom log type
        'x-ms-date': x_ms_date,
        'Authorization': f"SharedKey {WORKSPACE_KEY}:{signature}",
    }

    response = requests.post(url, headers=headers, data=json.dumps(log_data))
    return response.status_code

# Function to generate signature for authorization header
def generate_signature(x_ms_date, log_data):
    # Create the string to sign
    signature_string = f"POST\n{len(json.dumps(log_data))}\napplication/json\nx-ms-date:{x_ms_date}\n/api/logs"
    
    # Sign with the Workspace Key
    signature_bytes = base64.b64decode(WORKSPACE_KEY)
    return base64.b64encode(signature_bytes).decode()

# Fetch CloudWatch logs from AWS CloudWatch
def fetch_cloudwatch_logs():
    # Replace with the Log Group and Stream you want to pull logs from
    log_group_name = 'your-log-group-name'  # Specify the CloudWatch Log Group
    log_stream_name = 'your-log-stream-name'  # Specify the CloudWatch Log Stream
    
    try:
        response = cloudwatch_logs.get_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            startFromHead=True
        )
        logs = response['events']
        log_data = []
        
        # Format logs for Azure Sentinel
        for log in logs:
            log_data.append({
                "timestamp": log['timestamp'],
                "message": log['message'],
                "severity": "INFO"  # You can map severity based on your needs
            })
        
        return log_data
    
    except NoCredentialsError:
        print("AWS credentials not found.")
        return None
    except Exception as e:
        print(f"Error fetching logs from CloudWatch: {e}")
        return None

# Main function to pull logs and send them to Azure Sentinel
def main():
    log_data = fetch_cloudwatch_logs()
    if log_data:
        status_code = send_to_sentinel(log_data)
        if status_code == 200:
            print("Logs successfully sent to Azure Sentinel")
        else:
            print(f"Failed to send logs to Azure Sentinel: {status_code}")
    else:
        print("No logs to send to Azure Sentinel")

# Entry point for the Azure Function
if __name__ == "__main__":
    main()
