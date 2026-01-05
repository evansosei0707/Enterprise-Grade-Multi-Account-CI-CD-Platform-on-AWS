import json
import os
import logging
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_metadata() -> Dict[str, Any]:
    """
    Retrieve release metadata from environment variables.
    These variables are injected by Terraform at deployment time.
    """
    return {
        "service": os.environ.get("SERVICE_NAME", "unknown-service"),
        "environment": os.environ.get("ENVIRONMENT", "unknown-env"),
        "version": os.environ.get("RELEASE_VERSION", "0.0.0"),
        "git_commit": os.environ.get("GIT_COMMIT", "unknown-commit"),
        "build_id": os.environ.get("BUILD_ID", "unknown-build"),
        "deployed_at": os.environ.get("DEPLOYED_AT", "unknown-time"),
        "aws_region": os.environ.get("AWS_REGION", "us-east-1"),
    }

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler for the Release Metadata API.
    Handles /health and /release endpoints.
    """
    path = event.get("path", "")
    http_method = event.get("httpMethod", "")
    
    logger.info(f"Received request: {http_method} {path}")
    
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*", # CORS support
        "Access-Control-Allow-Methods": "GET,OPTIONS",
        "Cache-Control": "no-cache"
    }
    
    try:
        if path.endswith("/health"):
            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({"status": "healthy"})
            }
            
        elif path.endswith("/release"):
            metadata = get_metadata()
            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps(metadata, indent=2)
            }
            
        else:
            return {
                "statusCode": 404,
                "headers": headers,
                "body": json.dumps({"error": "Not Found", "path": path})
            }
            
    except Exception as e:
        logger.error(f"Error handling request: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": "Internal Server Error"})
        }
