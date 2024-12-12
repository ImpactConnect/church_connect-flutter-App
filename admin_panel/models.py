from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from .mixins import TimestampMixin, ValidationMixin
from sqlalchemy.orm import validates
import re

db = SQLAlchemy()

# Association table for sermon topics (many-to-many)
sermon_topics = db.Table('sermon_topics',
    db.Column('sermon_id', db.Integer, db.ForeignKey('sermons.id'), primary_key=True),
    db.Column('topic_id', db.Integer, db.ForeignKey('topics.id'), primary_key=True)
)

class Sermon(db.Model, TimestampMixin):
    __tablename__ = 'sermons'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    preacher = db.Column(db.String(100), nullable=False)
    category = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    audio_url = db.Column(db.String(255), nullable=False)
    is_local = db.Column(db.Boolean, default=False)
    date = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    duration = db.Column(db.Integer, nullable=False)  # Duration in seconds

    # Relationships
    topics = db.relationship('Topic', secondary=sermon_topics, backref='sermons')

    @validates('title')
    def validate_title(self, key, title):
        if not title:
            raise ValueError('Title is required')
        if len(title) < 3:
            raise ValueError('Title must be at least 3 characters long')
        if len(title) > 255:
            raise ValueError('Title must be less than 255 characters')
        return title

    @validates('preacher')
    def validate_preacher(self, key, preacher):
        if not preacher:
            raise ValueError('Preacher name is required')
        if len(preacher) < 2:
            raise ValueError('Preacher name must be at least 2 characters long')
        return preacher

    @validates('duration')
    def validate_duration(self, key, duration):
        if not isinstance(duration, int):
            raise ValueError('Duration must be an integer')
        if duration <= 0:
            raise ValueError('Duration must be greater than 0')
        return duration

    @validates('audio_url')
    def validate_audio_url(self, key, url):
        if not url:
            raise ValueError('Audio URL is required')
        allowed_extensions = {'.mp3', '.wav', '.m4a'}
        if not any(url.lower().endswith(ext) for ext in allowed_extensions):
            raise ValueError('Invalid audio file format')
        return url

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'preacher': self.preacher,
            'category': self.category,
            'description': self.description,
            'audioUrl': self.audio_url,
            'isLocal': self.is_local,
            'date': self.date.isoformat(),
            'duration': self.duration,
            'topics': [topic.name for topic in self.topics],
            'createdAt': self.created_at.isoformat(),
            'updatedAt': self.updated_at.isoformat()
        }

class Topic(db.Model, TimestampMixin):
    __tablename__ = 'topics'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)

    @validates('name')
    def validate_name(self, key, name):
        if not name:
            raise ValueError('Topic name is required')
        if len(name) < 2:
            raise ValueError('Topic name must be at least 2 characters long')
        if len(name) > 100:
            raise ValueError('Topic name must be less than 100 characters')
        return name.strip()

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'sermonCount': len(self.sermons)
        }

class Event(db.Model, TimestampMixin):
    __tablename__ = 'events'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    start_date = db.Column(db.DateTime, nullable=False)
    end_date = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(255), nullable=False)
    image_url = db.Column(db.String(255))
    category = db.Column(db.String(100), nullable=False)
    is_recurring = db.Column(db.Boolean, default=False)
    recurrence_rule = db.Column(db.String(255))
    requires_registration = db.Column(db.Boolean, default=False)
    max_attendees = db.Column(db.Integer)
    current_attendees = db.Column(db.Integer, default=0)

    @validates('title')
    def validate_title(self, key, title):
        if not title:
            raise ValueError('Event title is required')
        if len(title) < 3:
            raise ValueError('Event title must be at least 3 characters long')
        return title

    @validates('start_date', 'end_date')
    def validate_dates(self, key, date):
        if not date:
            raise ValueError(f'{key} is required')
        if key == 'end_date' and hasattr(self, 'start_date'):
            if date < self.start_date:
                raise ValueError('End date must be after start date')
        return date

    @validates('max_attendees')
    def validate_max_attendees(self, key, value):
        if value is not None and value < 0:
            raise ValueError('Maximum attendees cannot be negative')
        return value

    @validates('current_attendees')
    def validate_current_attendees(self, key, value):
        if value < 0:
            raise ValueError('Current attendees cannot be negative')
        if hasattr(self, 'max_attendees') and self.max_attendees:
            if value > self.max_attendees:
                raise ValueError('Current attendees cannot exceed maximum attendees')
        return value

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'startDate': self.start_date.isoformat(),
            'endDate': self.end_date.isoformat(),
            'location': self.location,
            'imageUrl': self.image_url,
            'category': self.category,
            'isRecurring': self.is_recurring,
            'recurrenceRule': self.recurrence_rule,
            'requiresRegistration': self.requires_registration,
            'maxAttendees': self.max_attendees,
            'currentAttendees': self.current_attendees,
            'isFull': self.max_attendees and self.current_attendees >= self.max_attendees,
            'createdAt': self.created_at.isoformat(),
            'updatedAt': self.updated_at.isoformat()
        }

class Admin(db.Model, TimestampMixin, ValidationMixin):
    __tablename__ = 'admins'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    last_login = db.Column(db.DateTime)

    def __init__(self, **kwargs):
        super(Admin, self).__init__(**kwargs)
        if 'password' in kwargs:
            self.set_password(kwargs['password'])

    def set_password(self, password):
        from werkzeug.security import generate_password_hash
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        from werkzeug.security import check_password_hash
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'isActive': self.is_active,
            'lastLogin': self.last_login.isoformat() if self.last_login else None,
            'createdAt': self.created_at.isoformat()
        } 