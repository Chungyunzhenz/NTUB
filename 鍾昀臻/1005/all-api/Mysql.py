# Student review API using mysql.connector and Flask
from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Database configuration
db_config = {
    'host': '140.131.114.242',  # 虛擬機上的 MySQL 伺服器
    'user': 'ntub_finalProject',
    'password': 'ntub_finalProject',
    'database': 'ntub_113205db'
}

@app.route('/getStudentReviews', methods=['GET'])
def get_student_reviews():
    review_status = request.args.get('review_status')

    # Validate the review_status parameter
    valid_statuses = ["審查中", "退回", "完成"]
    if review_status and review_status not in valid_statuses:
        return jsonify({'error': f'Invalid review_status parameter. Allowed values are {valid_statuses}'}), 400

    connection = None

    try:
        # Connect to the database
        print("Attempting to connect to the database...")
        connection = mysql.connector.connect(**db_config)
        
        if not connection.is_connected():
            print("Failed to connect to the database")
            return jsonify({'error': 'Failed to connect to the database'}), 500

        cursor = connection.cursor(dictionary=True)
        print("Successfully connected to the database")

        # Query to get student reviews, filter by review status if provided
        if review_status:
            query = "SELECT * FROM reviewprogress WHERE review_status = %s"
            print(f"Executing query: {query} with parameter: {review_status}")
            cursor.execute(query, (review_status,))
        else:
            query = "SELECT * FROM reviewprogress"
            print(f"Executing query: {query}")
            cursor.execute(query)

        result = cursor.fetchall()
        print(f"Query successful, fetched {len(result)} records")

        return jsonify(result)

    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        return jsonify({'error': str(err)}), 500
    except Exception as e:
        print(f"Unexpected error: {e}")
        return jsonify({'error': 'An unexpected error occurred'}), 500

    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            print("Database connection closed")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)
