from datetime import datetime
from app.extensions import db
from app.models.mixins import TimestampMixin, ValidationMixin
from werkzeug.security import generate_password_hash, check_password_hash

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
    date = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    duration = db.Column(db.Integer, nullable=False)

    # Relationships
    topics = db.relationship('Topic', secondary=sermon_topics, backref='sermons')

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'preacher': self.preacher,
            'category': self.category,
            'description': self.description,
            'audioUrl': self.audio_url,
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

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
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