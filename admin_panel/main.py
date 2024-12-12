from flask import Flask, send_from_directory
from app import create_app

flask_app = create_app()

@flask_app.route('/')
def serve_spa():
    return send_from_directory('static', 'index.html')

@flask_app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('static', path) 