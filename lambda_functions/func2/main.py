def lambda_handler(event, context):
    # Print "Hello, World!" to CloudWatch Logs
    print("Hello, World from func 2")
    
    # Return "Hello, World!" as the response
    return {
        "statusCode": 200,
        "body": "Hellooooo, World!"
    }

## call function
lambda_handler(None, None)