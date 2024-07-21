import pymysql
from pymysql import Error
import datetime
from cryptography.fernet import Fernet
encrypted = b'gAAAAABmJ-HH5iD3By1yKBym9ARKdpobie__uEu_57jlQwSRXu6f35xknPafR_A3n4oB3339jyV-966ZhBvmBUPj6dmm2Ff8tA=='
encryptedd = b'gAAAAABmJ-Pjw431d8bK-U2YbKVsS3tM3ZoIi8hWaz6zBzF8tY5NAZt7EVDuDAxhi743NIDssyMdyItivSp45h2CxAkVta-q0A=='
key=b'Q5ocFlVNMmukhZ7c0qtk9LyCsZ5gpVn438JNRHoKifk='
def decrypt_message(encrypted_message, key):
    f = Fernet(key)
    decrypted_message = f.decrypt(encrypted_message).decode()
    return decrypted_message
decrypted = decrypt_message(encrypted, key)
decryptedd = decrypt_message(encryptedd, key)
def connect_to_db():
    """ Create a database connection to a MySQL server. """
    try:
        connection = pymysql.connect(host='34.80.115.127',
            database='zc_sql1',
            user=decrypted,
            password=decryptedd)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL Platform: {e}")
        return None

def upload_image(file_path, uploaded_by):
    """ Upload an image to the database. """
    # Convert image to binary format
    try:
        with open(file_path, 'rb') as file:
            binary_data = file.read()
    except IOError as e:
        print(f"Error reading file {file_path}: {e}")
        return
    
    # Connect to database
    connection = connect_to_db()
    if connection is None:
        return

    try:
        # Prepare a query to insert a record
        query = """INSERT INTO ImageUploads (Image, UploadDate, UploadedBy) 
                   VALUES (%s, %s, %s)"""
        # Current date
        current_date = datetime.datetime.now().date()
        # Execute the query
        with connection.cursor() as cursor:
            cursor.execute(query, (binary_data, current_date, uploaded_by))
            connection.commit()
            print("Image uploaded successfully.")
    except Error as e:
        print(f"Error inserting data into MySQL table: {e}")
    finally:
        if connection:
            connection.close()

# Usage example
upload_image('cropped_table.jpg', '00000000001')
