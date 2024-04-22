import mysql.connector
from mysql.connector import Error
import os
import tempfile

def retrieve_word_from_db(word_id):
    try:
        connection = mysql.connector.connect(
            host='127.0.0.1',
            database='schooldb',
            user='root',
            password='--pass--'
        )

        if connection.is_connected():
            cursor = connection.cursor()
            query = "SELECT Document FROM worduploads WHERE ID = %s"
            cursor.execute(query, (word_id,))
            word_data = cursor.fetchone()[0]
            return word_data
    except Error as e:
        print("Error reading Word document from MySQL database:", e)
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def save_word_to_file(word_data):
    try:
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.docx')
        temp_file.write(word_data)
        temp_file.close()
        return temp_file.name
    except Exception as e:
        print("Error saving Word document to file:", e)
        return None

def display_word_file(file_path):
    try:
        os.system('start "" "' + file_path + '"')
    except Exception as e:
        print("Error opening Word document:", e)

def main():
    word_id = input("Enter Word document ID: ")
    word_data = retrieve_word_from_db(word_id)
    if word_data:
        file_path = save_word_to_file(word_data)
        if file_path:
            display_word_file(file_path)
        else:
            print("Failed to save Word document to file.")
    else:
        print("Word document not found in database.")

if __name__ == "__main__":
    main()
