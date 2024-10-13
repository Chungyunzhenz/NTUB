# Student review API using mysql.connector and Flask
from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Database configuration
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

@app.route('/getStudentReviews', methods=['GET'])
def get_student_reviews():
    review_status = request.args.get('review_status')

    # Validate the review_status parameter
    valid_statuses = ["審查中", "退回", "通過"]
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
            query = "SELECT * FROM ReviewProgress WHERE review_status = %s"
            print(f"Executing query: {query} with parameter: {review_status}")
            cursor.execute(query, (review_status,))
        else:
            query = "SELECT * FROM ReviewProgress"
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

@app.route('/withdrawReview', methods=['POST'])
def withdraw_review():
    data = request.get_json()
    review_id = data.get('review_id')

    if not review_id:
        return jsonify({'error': 'Missing review_id parameter'}), 400

    connection = None

    try:
        # Connect to the database
        print("Attempting to connect to the database...")
        connection = mysql.connector.connect(**db_config)
        
        if not connection.is_connected():
            print("Failed to connect to the database")
            return jsonify({'error': 'Failed to connect to the database'}), 500

        cursor = connection.cursor()
        print("Successfully connected to the database")

        # Update the review status to "退回"
        update_query = "UPDATE ReviewProgress SET review_status = %s WHERE id = %s"
        cursor.execute(update_query, ("退回", review_id))
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': 'No review found with the given review_id'}), 404

        print("Review status updated to '退回'")
        return jsonify({'message': 'Review status updated to 退回 successfully'})

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