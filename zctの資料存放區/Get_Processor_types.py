
from google.api_core.client_options import ClientOptions
from google.cloud import documentai  # type: ignore

# TODO(developer): Uncomment these variables before running the sample.
project_id = 'zc-1-417715'
location = 'us' # Format is 'us' or 'eu'
print("1")


    # You must set the api_endpoint if you use a location other than 'us'.
opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
print("2")
client = documentai.DocumentProcessorServiceClient(client_options=opts)
print("3")

    # The full resource name of the location
    # e.g.: projects/project_id/locations/location
parent = client.common_location_path(project_id, location)
print("4")
    # Make ListProcessors request
processor_list = client.list_processors(parent=parent)
print("5")
    # Print the processor information
for processor in processor_list:
        print(f"Processor Name: {processor.name}")
        print(f"Processor Display Name: {processor.display_name}")
        print(f"Processor Type: {processor.type_}")
        print("")
        print("6")
print("7")