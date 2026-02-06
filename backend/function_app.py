import json
import os
import azure.functions as func
from azure.cosmos import CosmosClient, exceptions
from azure.identity import DefaultAzureCredential

app = func.FunctionApp()

# Lazy initialization to prevent startup crashes
container = None

def get_container():
    global container
    if container:
        return container
        
    COSMOS_ENDPOINT = os.environ.get('COSMOS_ENDPOINT')
    DATABASE_NAME = "resume-challenge-db"
    CONTAINER_NAME = "visitor-counter"
    
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
        get_container().create_item({
            'id': item_id,
            'views': 1
        })
        return func.HttpResponse(
            json.dumps({'count': 1}),
            status_code=200,
            mimetype="application/json"
        )
    except Exception as e:
        return func.HttpResponse(f"Error: {str(e)}", status_code=500)