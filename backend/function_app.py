import json
import os
import azure.functions as func
from azure.cosmos import CosmosClient, exceptions
from azure.identity import DefaultAzureCredential

app = func.FunctionApp()

# Lazy initialization vars
container = None

def get_container():
    global container
    if container:
        return container
        
    # 1. Fetch variables set in Terraform app_settings
    COSMOS_ENDPOINT = os.environ.get('COSMOS_ENDPOINT')
    DATABASE_NAME = os.environ.get('DATABASE_NAME', "resume-challenge-db")
    CONTAINER_NAME = os.environ.get('CONTAINER_NAME', "visitor-counter")
    
    if not COSMOS_ENDPOINT:
        raise ValueError("COSMOS_ENDPOINT environment variable is missing")

    # 2. Use Managed Identity (DefaultAzureCredential)
    credential = DefaultAzureCredential()
    client = CosmosClient(COSMOS_ENDPOINT, credential=credential)
    database = client.get_database_client(DATABASE_NAME)
    container = database.get_container_client(CONTAINER_NAME)
    return container

@app.route(route="visitors", auth_level=func.AuthLevel.ANONYMOUS)
def visitor_counter(req: func.HttpRequest) -> func.HttpResponse:
    try:
        item_id = 'visitors'
        partition_key = 'visitors'

        # Atomic increment using Patch
        operations = [
            {'op': 'incr', 'path': '/views', 'value': 1}
        ]

        # 3. Perform the patch
        updated_item = get_container().patch_item(
            item=item_id,
            partition_key=partition_key,
            patch_operations=operations
        )

        new_count = updated_item.get('views', 0)

        return func.HttpResponse(
            json.dumps({'count': int(new_count)}),
            status_code=200,
            mimetype="application/json"
        )

    except exceptions.CosmosResourceNotFoundError:
        # If the item doesn't exist, create it
        # Note: You need a partition key in your create payload if your container requires it
        get_container().create_item({
            'id': item_id,
            'visitors': 'visitors', # Assuming partition key is 'visitors' based on previous logic
            'views': 1
        })
        return func.HttpResponse(
            json.dumps({'count': 1}),
            status_code=200,
            mimetype="application/json"
        )
    except Exception as e:
        return func.HttpResponse(f"Error: {str(e)}", status_code=500)