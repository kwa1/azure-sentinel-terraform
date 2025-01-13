# Create an S3 Bucket for Storing Logs: We'll create an S3 bucket that will store sensitive data detection logs from Macie and will be integrated with CloudWatch.

resource "aws_s3_bucket" "macie_s3_bucket" {
  bucket = var.macie_s3_bucket_name

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Enable Amazon Macie: Amazon Macie is used for discovering, classifying, and protecting sensitive data stored in S3. We'll enable Macie to monitor data in your S3 bucket.

resource "aws_macie2_classification_job" "macie_classification_job" {
  name         = "macie-sensitive-data-detection"
  description  = "Job to detect sensitive data in S3"
  job_type     = "ONE_TIME"
  data_source {
    s3_job_definition {
      bucket_arn = aws_s3_bucket.macie_s3_bucket.arn
    }
  }

  custom_data_identifier {
    name     = "PII Data Identifier"
    regex    = "(\\b(?:\\d{3}-\\d{2}-\\d{4}|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2})\\b)"
    criteria = ["SSN"]
  }

  schedule {
    frequency = "ONE_TIME"
  }
}
#In this configuration, we’re creating a Macie classification job to detect sensitive data (such as Social Security Numbers) in the S3 bucket.

#Enable Macie Data Findings and Log to CloudWatch: Macie generates findings based on detected sensitive data. We'll set up Macie to send these findings to CloudWatch for easier integration with other services like Azure Sentinel.

resource "aws_macie2_findings_filter" "macie_findings_filter" {
  name        = "sensitive-data-detection-filter"
  description = "Filter to send sensitive data findings to CloudWatch"
  action      = "ARCHIVE"  # Archive findings that don’t require immediate attention
  finding_criteria {
    criterion = {
      "sensitiveData" = {
        "eq" = ["true"]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "macie_logs" {
  name = "/aws/macie/findings"
}

resource "aws_cloudwatch_log_stream" "macie_log_stream" {
  log_group_name = aws_cloudwatch_log_group.macie_logs.name
  name           = "macie-findings-stream"
}
