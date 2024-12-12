from flask import jsonify
from . import events_bp
from app.models.models import Event
from datetime import datetime

@events_bp.route('/api/events')
def get_events():
    return jsonify([]) 

@events_bp.route('/api/events/upcoming')
def upcoming_events():
    upcoming_events = Event.query.filter(Event.start_date > datetime.utcnow()).order_by(Event.start_date).limit(5).all()
    return jsonify([event.to_dict() for event in upcoming_events]) 