# Import necessary modules from Flask and other Python libraries
from flask import Flask, request, jsonify
import os
import json

# Create a Flask web application
app = Flask(__name__)

# Define the folder where uploaded files and messages will be stored
UPLOAD_FOLDER = 'uploads'

# Create the UPLOAD_FOLDER directory if it doesn't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Function to create a folder for a specific client to store their messages or files
def create_client_folder(client_name, fileString):
    client_folder = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages')
    if not os.path.exists(client_folder):
        os.makedirs(client_folder)

    elif fileString.lower().endswith(('.jpeg', '.png', '.jpg')):
        client_images = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages/images/')
        if not os.path.exists(client_images):
            os.makedirs(f'{client_images}')
        return client_images

    elif fileString.lower().endswith(('.mp3', '.m4a', '.wav')):
        client_audio = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages/audio files/')
        if not os.path.exists(client_audio):
            os.makedirs(f'{client_audio}')
        return client_audio
    elif fileString.lower().endswith(('.mp4', '.avi', '.mkv')):
        client_video = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages/videos/')
        if not os.path.exists(client_video):
            os.makedirs(f'{client_video}')
        return client_video

    return client_folder

# Function to create a folder for messages due to a bug
def create_message_folder(client_name):
    client_folder = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages')
    if not os.path.exists(client_folder):
        os.makedirs(client_folder)
    return client_folder

# Function to load messages from a JSON file
def load_messages(client_folder):
    messages_file = os.path.join(client_folder, 'messages.json')
    try:
        with open(messages_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        data = {"name": "", "messages": []}
    return data

# Function to save messages to a JSON file
def save_messages(client_folder, data):
    messages_file = os.path.join(client_folder, 'messages.json')
    with open(messages_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

# Define a route to handle file uploads or text messages
@app.route('/upload', methods=['POST'])
def upload():
    try:
        # Check if a file is included in the request
        if 'file' in request.files:
            file = request.files['file']
            client_name = request.form.get('name', 'default_client')

            # Create a folder for the client and save the uploaded file in it
            client_folder = create_client_folder(client_name, file.filename)
            file.save(os.path.join(client_folder, file.filename))
            return jsonify({'message': 'File uploaded successfully'})

        # Check if a text message is included in the request
        elif 'text' in request.form:
            client_name = request.form['name']
            text = request.form['text']

            # Create a folder for the client, load existing messages, add the new text message, and save
            client_folder = create_message_folder(client_name)
            data = load_messages(client_folder)
            data["name"] = client_name
            data["messages"].append({'type': 'text', 'content': text})
            save_messages(client_folder, data)

            return jsonify({'message': 'Text data received successfully'})
        
        elif 'link' in request.form:
            client_name = request.form['name']
            link = request.form['link']

            # Create a folder for the client, load existing messages, add the new text message, and save
            client_folder = create_message_folder(client_name)
            data = load_messages(client_folder)
            data["name"] = client_name
            data["messages"].append({'type': 'link', 'content': link})
            save_messages(client_folder, data)

            return jsonify({'message': 'Text data received successfully'})


        # Check if a client name is included in the request
        elif 'name' in request.form:
            client_name = request.form['name']

            # Create a folder for the client and load existing messages
            client_folder = create_message_folder(client_name)
            data = load_messages(client_folder)

            # Check if a message of type 'name' with the same content already exists
            if any(message['type'] == 'name' and message['content'] == client_name for message in data["messages"]):
                return jsonify({'error': f'Client with name {client_name} already exists'})

            # Add a new message of type 'name' to represent the client name
            data["name"] = client_name
            data["messages"].append({'type': 'name', 'content': client_name})
            save_messages(client_folder, data)

            return jsonify({'message': 'Text data received successfully'})

        # If none of the expected data is present, return an error
        else:
            return jsonify({'error': 'Invalid request'})

    # Catch and handle any exceptions that might occur
    except Exception as e:
        return jsonify({'error': f'Error: {e}'})

# Define a route to retrieve messages for a specific client
@app.route('/get_messages', methods=['GET'])
def get_messages():
    # Get the client name from the request or use a default client name
    client_name = request.args.get('name', 'default_client')
    # Create the path to the client's folder
    client_folder = os.path.join(UPLOAD_FOLDER, f'{client_name}_messages')
    # Load and return the messages for the client
    data = load_messages(client_folder)
    return jsonify({'name': data["name"], 'messages': data["messages"]})

# Run the Flask application if the script is executed directly
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3172)
    
