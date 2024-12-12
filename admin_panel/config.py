import os
from datetime import timedelta

basedir = os.path.abspath(os.path.dirname(__file__))

class Config:
    SECRET_KEY = 'your-secret-key-here'  # Change this in production
    SQLALCHEMY_DATABASE_URI = f'sqlite:///{os.path.join(basedir, "church_connect.db")}'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_EXPIRATION_DELTA = timedelta(days=1)
    UPLOAD_FOLDER = os.path.join(basedir, 'uploads')
    MAX_CONTENT_LENGTH = 100 * 1024 * 1024  # 100MB 