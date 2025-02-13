# Multi-Function Lambda Deployment

## Functions
I have created two lambda functions; `func1` that encapsulates the code to run a translation of PDF documents uploaded to an S3 bucket and `func2` that is a simple "Hello world" output.

_Note that the functions are deployed in AWS with the following nomenclature: `lambda-deployment-func1` and `lambda-deployment-func2`._

I spent a significant amount of time on the translation function. The idea behind this was, Epoq is a legal tech firm, you are already international and there may be cases where you need to translate foreign documents. The function code is a Python script that requires many dependencies to ensure the translation works correctly:
- pdfplumber
- deep-translator
- reportlab
- PyPDF2
- fpdf

I tackled this by way of a lambda layer to reduce the size of the function code that is zipped and uploaded to the S3 bucket. Currently, the function only translates Spanish text to English, but the code can easily be configured to accommodate other languages.

## Terraform
I have created two modules:
- lambda function
- lambda shared

### Lambda Function
This outlines the creation of the lambda function by way of variables.

### Lambda Shared
This outlines the IAM policies and roles needed to ensure the lambda functions are accessible, and the translation function is able to scan, extract, and upload outputs to the S3 bucket.

## CI Workflow

**Trigger:** It runs either when you manually start it (after confirming by typing "yes") or automatically whenever code is pushed to the main branch.

**Setup:** It checks out the code, sets up Python 3.9, and installs the AWS CLI.

**Detect Changes:** It examines the lambda functions directories for any changes. If none are detected, it packages all lambda functions.

**Package & Upload:** For each changed (or all) lambda function, it creates a ZIP file (containing main.py) and uploads it to a specified S3 bucket.

**Terraform Deployment:** Finally, it sets up Terraform and then runs the initialise, plan, and apply commands to update the infrastructure.

## Issues Faced and Resolutions

- Issues with translation function via Terraform, decided to deploy using clickops first for better understanding:
    - Encountered issues with getting the translation Python script to run.
    - Required more dependencies than I had originally thought.
    - Packaged them all into a ZIP folder and uploaded to lambda layer.
    - This did not work either though:
        - Due to compatibility issues when building my Lambda layer on my Windows laptop because native dependencies compiled on Windows don’t work on AWS Lambda’s Amazon Linux environment. To fix this, I used Docker with an Amazon Linux container to install the Python dependencies, ensuring they were built correctly. Then, I packaged the layer and deployed it successfully to AWS Lambda.
- Encountered issues with uploading the function code ZIP file, it was getting corrupted when being used by the lambda functions.
- Tried using 7z ZIP filing approach; this also was not compatible.
- I then used AI assistance to amend my CI.yml pipeline to mirror the command to ZIP the function code at file explorer level and this corrected the issue.
- I was unable to automate all aspects of the lambda function upon creation, e.g.:
    - Layer and right version.
    - Timeout.
    - Test event.
    - Event notification.
    - Automating timestamps (unique identifier) for modified function.zip files uploaded to S3 bucket - kept affecting the S3 key (bucket path).
- The function was not extracting the .zip file from S3 because I did not set up an automated env variable `LAMBDA_S3_BUCKET = var.lambda_s3_bucket` for the lambda functions.
