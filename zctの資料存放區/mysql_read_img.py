import pymysql
from PIL import Image
from io import BytesIO
import tkinter as tk
from tkinter import Label, Tk
from tkinter.ttk import Frame
from PIL import ImageTk
from cryptography.fernet import Fernet
encrypted = b'gAAAAABmJ-HH5iD3By1yKBym9ARKdpobie__uEu_57jlQwSRXu6f35xknPafR_A3n4oB3339jyV-966ZhBvmBUPj6dmm2Ff8tA=='
encryptedd = b'gAAAAABmJ-Pjw431d8bK-U2YbKVsS3tM3ZoIi8hWaz6zBzF8tY5NAZt7EVDuDAxhi743NIDssyMdyItivSp45h2CxAkVta-q0A=='
key = b'Q5ocFlVNMmukhZ7c0qtk9LyCsZ5gpVn438JNRHoKifk='

def decrypt_message(encrypted_message, key):
    f = Fernet(key)
    decrypted_message = f.decrypt(encrypted_message).decode()
    return decrypted_message

decrypted = decrypt_message(encrypted, key)
decryptedd = decrypt_message(encryptedd, key)

def retrieve_image_from_db(image_id):
    try:
        connection = pymysql.connect(
            host='34.80.115.127',
            database='zc_sql1',
            user=decrypted,
            password=decryptedd
        )

        cursor = connection.cursor()
        query = "SELECT Image FROM ImageUploads WHERE ID = %s"
        cursor.execute(query, (image_id,))
        image_data = cursor.fetchone()[0]
        return image_data
    except pymysql.MySQLError as e:
        print("Error reading image from MySQL database:", e)
    finally:
        cursor.close()
        connection.close()


def display_image(image_data):
    root = Tk()
    root.title("Image Viewer")

    image = Image.open(BytesIO(image_data))
    width, height = image.size
    max_width = 800
    max_height = 600

    if width > max_width or height > max_height:
        if width / max_width > height / max_height:
            width = max_width
            height = int(width * height / width)
        else:
            height = max_height
            width = int(height * width / height)

    image.thumbnail((width, height))

    label = Label(root)
    label.pack()

    photo_image = ImageTk.PhotoImage(image)
    label.config(image=photo_image)
    label.image = photo_image

    root.mainloop()


def main():
    image_id = input("Enter image ID: ")
    image_data = retrieve_image_from_db(image_id)
    if image_data:
        display_image(image_data)
    else:
        print("Image not found in database.")


if __name__ == "__main__":
    main()
