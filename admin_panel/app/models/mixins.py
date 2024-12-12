from datetime import datetime
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import validates
from app.extensions import db
import re

class TimestampMixin:
    @declared_attr
    def created_at(cls):
        return db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    @declared_attr
    def updated_at(cls):
        return db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

class ValidationMixin:
    @validates('email')
    def validate_email(self, key, email):
        if not email:
            raise ValueError('Email is required')
        if not re.match(r"[^@]+@[^@]+\.[^@]+", email):
            raise ValueError('Invalid email format')
        return email

    @validates('username')
    def validate_username(self, key, username):
        if not username:
            raise ValueError('Username is required')
        if len(username) < 3:
            raise ValueError('Username must be at least 3 characters long')
        if not re.match(r'^[a-zA-Z0-9_]+$', username):
            raise ValueError('Username can only contain letters, numbers, and underscores')
        return username

    @validates('password_hash')
    def validate_password(self, key, password):
        if not password:
            raise ValueError('Password is required')
        if len(password) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return password