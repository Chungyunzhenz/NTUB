import mysql.connector
from mysql.connector import Error
from PIL import Image
from io import BytesIO
import tkinter as tk
from tkinter import Label, Tk
from tkinter.ttk import Frame


def retrieve_image_from_db(image_id):
    try:
        connection = mysql.connector.connect(
            host='127.0.0.1',
            database='schooldb',
            user='',
            password=''
        )

        if connection.is_connected():
            cursor = connection.cursor()
            query = "SELECT Image FROM imageuploads WHERE ID = A12345678-20000101-WQeuzdb92xsw4DMSTDkCXMQK0E38prQI-IMG"
            cursor.execute(query, (image_id,))
            image_data = cursor.fetchone()[0]
            return image_data
    except Error as e:
        print("Error reading image from MySQL database:", e)
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()


def display_image(image_data):
    root = Tk()
    root.title("Image Viewer")

    # Convert binary data to image
    image = Image.open(BytesIO(image_data))

    # Display image using tkinter
    photo = tk.PhotoImage(master=root, data=image.tobytes())
    label = Label(root, image=photo)
    label.image = photo
    label.pack()

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
