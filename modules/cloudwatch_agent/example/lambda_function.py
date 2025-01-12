# Forward CloudWatch Logs and Metrics to Azure Sentinel
#Once AWS CloudWatch collects the logs and metrics, you need to forward them to Azure Sentinel via Azure 
#Monitor’s HTTP Data Collector API. This is where the cross-cloud integration occurs.
#Option A: AWS Lambda to Forward Data to Azure Sentinel
#You can create an AWS Lambda function that listens to CloudWatch logs and forwards them to Azure Sentinel.
#Lambda Function will be triggered whenever new logs/metrics are available in AWS CloudWatch Logs.
#The Lambda function will use the Azure Monitor HTTP Data Collector API to send data to Azure Sentinel (Log Analytics Workspace).
############################################################################################################################################
import requests
import json
import base64
import time
from datetime import datetime

# Define Azure Sentinel workspace details
WORKSPACE_ID = "your-sentinel-workspace-id"
WORKSPACE_KEY = "your-sentinel-workspace-key"

# Function to send log data to Azure Sentinel
def send_to_sentinel(log_data):
    url = f'https://{WORKSPACE_ID}.ods.opinsights.azure.com/api/logs?api-version=2016-04-01'
    
    # Construct the authorization header
    x_ms_date = datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')
    signature = generate_signature(x_ms_date, log_data)
    
    headers = {
        'Content-Type': 'application/json',
        'Log-Type': 'CloudWatchLogs',  # Custom log type
        'x-ms-date': x_ms_date,
        'Authorization': f"SharedKey {WORKSPACE_KEY}:{signature}",
    }

    response = requests.post(url, headers=headers, data=json.dumps(log_data))
    return response.status_code

# Function to generate signature for authorization header
def generate_signature(x_ms_date, log_data):
    # Generate the log signature based on Azure Monitor authentication requirements
    # Use your Azure Monitor Workspace key for the signature generation
    return 'signature-placeholder'

# Main Lambda handler
def lambda_handler(event, context):
    # Extract logs from CloudWatch event
    log_data = extract_logs_from_event(event)
    
    # Send the logs to Azure Sentinel
    status_code = send_to_sentinel(log_data)
    
    if status_code == 200:
        print("Log data successfully sent to Azure Sentinel")
    else:
        print(f"Failed to send data to Azure Sentinel: {status_code}")
        
# Function to extract logs from the CloudWatch event
def extract_logs_from_event(event):
    # Extract and parse log data from CloudWatch event
    # Example parsing logic; adapt according to the actual event format
    log_data = {
        "timestamp": time.time(),
        "message": event['Records'][0]['Sns']['Message'],
        "severity": "INFO"
    }
    return log_data
