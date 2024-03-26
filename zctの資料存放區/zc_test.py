
from google.api_core.client_options import ClientOptions
from google.cloud import documentai  # type: ignore

project_id = "zc-1-417715"
location = "us" # Format is "us" or "eu"
processor_id = "3b047912900fc8f2" # Create processor before running sample
processor_version = "pretrained-ocr-v2.0-2023-06-02" # Refer to https://cloud.google.com/document-ai/docs/manage-processor-versions for more information
file_path = "G:/test.jpg"
mime_type = "image/jpeg" # Refer to https://cloud.google.com/document-ai/docs/file-types for supported file types
processor_display_name = "zc-87"



    # You must set the `api_endpoint`if you use a location other than "us".
opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
print("5")
client = documentai.DocumentProcessorServiceClient(client_options=opts)

    # The full resource name of the location, e.g.:
    # `projects/{project_id}/locations/{location}`
parent = client.common_location_path(project_id, location)
print("5")
    # Create a Processor
processor = client.create_processor(
        parent=parent,
        processor=documentai.Processor(
            type_="OCR_PROCESSOR",  # Refer to https://cloud.google.com/document-ai/docs/create-processor for how to get available processor types
            display_name=processor_display_name,
        ),
    )
print("5")
    # Print the processor information
print(f"Processor Name: {processor.name}")

    # Read the file into memory
with open(file_path, "rb") as image:
        image_content = image.read()
print("5")
    # Load binary data
raw_document = documentai.RawDocument(
        content=image_content,
        mime_type="image/jpeg",  # Refer to https://cloud.google.com/document-ai/docs/file-types for supported file types
    )
print("5")
    # Configure the process request
    # `processor.name` is the full resource name of the processor, e.g.:
    # `projects/{project_id}/locations/{location}/processors/{processor_id}`
request = documentai.ProcessRequest(name=processor.name, raw_document=raw_document)

result = client.process_document(request=request)
print("5")
    # For a full list of `Document` object attributes, reference this page:
    # https://cloud.google.com/document-ai/docs/reference/rest/v1/Document
document = result.document

    # Read the text recognition output from the processor
print("The document contains the following text:")
print(document.text)
print("5")