Azure Function to Integrate AWS CloudWatch Logs with Azure Sentinel
Overview
This project contains an Azure Function that fetches logs from AWS CloudWatch and sends them to Azure Sentinel for monitoring and security insights. The function retrieves logs from AWS CloudWatch Log Groups, formats them for Azure Sentinel, and pushes them to a Log Analytics workspace within Azure Sentinel.

Architecture
AWS CloudWatch: Collects logs from your AWS infrastructure.
Azure Function: Pulls logs from AWS CloudWatch, formats them, and sends them to Azure Sentinel using the Log Analytics API.
Azure Sentinel: Collects and analyzes the logs sent from AWS CloudWatch for security and monitoring.
Components
1. Azure Function
The function pulls AWS CloudWatch logs using the Boto3 AWS SDK.
It then formats the logs into a JSON payload and sends them to an Azure Sentinel workspace via the Azure Monitor HTTP Data Collector API.
2. AWS CloudWatch Logs
The function fetches logs from a specific AWS CloudWatch Log Group and Log Stream.
It retrieves logs from CloudWatch Logs and forwards them to Azure Sentinel.
3. Azure Sentinel & Log Analytics Workspace
Logs from AWS CloudWatch are sent to a Log Analytics Workspace in Azure Sentinel.
The logs are processed and used for further analysis and monitoring in Azure Sentinel.
Prerequisites
Azure Subscription: To create and manage resources in Azure Sentinel.
AWS Account: To fetch logs from AWS CloudWatch.
AWS CLI: Installed and configured with proper credentials to access CloudWatch Logs.
Azure CLI: Installed and configured to manage Azure Sentinel and Log Analytics.
Azure Function App: To deploy and run the function in Azure.
Getting Started
Step 1: Clone the Repository
Clone the repository to your local machine to access the Azure Function code.

bash
Copy code
git clone https://github.com/your-repository/azure-cloudwatch-sentinel-integration.git
cd azure-cloudwatch-sentinel-integration
Step 2: Set up AWS Credentials
Make sure your AWS credentials are set up correctly to access the AWS CloudWatch service.

bash
Copy code
aws configure
Step 3: Set up Azure Function App
Install Required Packages: Ensure you have the required Python libraries installed. Navigate to the function_app directory and install the dependencies.

bash
Copy code
cd function_app
pip install -r requirements.txt
Configure Azure Function:

Set your Azure Sentinel Workspace ID and Workspace Key in the function code.
Set your AWS CloudWatch Log Group Name and Log Stream Name in the __init__.py script.
Deploy the Azure Function: Deploy the function to Azure by following these steps:

Open Azure Portal and navigate to Azure Functions.
Create a new Function App.
In the Function App, create a new Function with a Timer Trigger.
Deploy the __init__.py code to the function.
Step 4: Set up Timer Trigger
The function is designed to run at regular intervals (every 5 minutes by default). You can modify the schedule in the function.json file if needed.

json
Copy code
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "name": "timerTrigger",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "*/5 * * * *"  // Runs every 5 minutes
    }
  ]
}
Step 5: Monitor Logs in Azure Sentinel
Once the function is deployed and running, you can view the incoming logs in Azure Sentinel. The logs should appear in the Log Analytics Workspace linked with your Azure Sentinel instance.

You can query the logs in Azure Sentinel using the Kusto Query Language (KQL) to analyze and visualize the logs.

Step 6: Modify Log Source (Optional)
You can modify the AWS CloudWatch Log Group and Log Stream names in the function code to match the specific log sources you wish to pull from CloudWatch.

python
Copy code
log_group_name = 'your-log-group-name'  # Specify the CloudWatch Log Group
log_stream_name = 'your-log-stream-name'  # Specify the CloudWatch Log Stream
Configuration
Below are the key configuration variables used in the Azure Function:

WORKSPACE_ID: The Azure Sentinel Workspace ID where the logs will be sent.
WORKSPACE_KEY: The Azure Sentinel Workspace Key (used for authentication).
LOG_TYPE: The custom log type used for the logs in Azure Sentinel (e.g., CloudWatchLogs).
AWS_REGION: The AWS region where CloudWatch logs are stored.
log_group_name: The name of the AWS CloudWatch Log Group.
log_stream_name: The name of the AWS CloudWatch Log Stream.
Environment Variables
Set the following environment variables in your Azure Function App:

WORKSPACE_ID: Azure Sentinel Workspace ID
WORKSPACE_KEY: Azure Sentinel Workspace Key
AWS_REGION: AWS region where CloudWatch logs are stored
AWS_ACCESS_KEY_ID: AWS access key for authentication
AWS_SECRET_ACCESS_KEY: AWS secret access key for authentication
Troubleshooting
Function Fails to Retrieve CloudWatch Logs: Check if the correct AWS credentials are provided and that the specified log group and stream exist.
Logs Not Appearing in Sentinel: Verify the Azure Sentinel Workspace ID and Workspace Key are correctly configured in the function.
Azure Function Execution Issues: Ensure that the timer trigger is correctly configured and that the function has appropriate permissions to run in your Azure subscription.
License
This project is licensed under the MIT License - see the LICENSE file for details.

Conclusion
By deploying this Azure Function, you can automate the process of fetching CloudWatch logs from AWS and sending them to Azure Sentinel, enabling you to use Azure Sentinel for cross-cloud monitoring and security analysis.






