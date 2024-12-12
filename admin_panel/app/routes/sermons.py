from flask import jsonify, request
from werkzeug.utils import secure_filename
import os
from . import sermons_bp
from ..models.models import Sermon, Topic
from .. import db
from datetime import datetime

@sermons_bp.route('/api/sermons/recent')
def recent_sermons():
    recent_sermons = Sermon.query.order_by(Sermon.date.desc()).limit(5).all()
    return jsonify([sermon.to_dict() for sermon in recent_sermons])

@sermons_bp.route('/api/sermons')
def get_sermons():
    sermons = Sermon.query.order_by(Sermon.date.desc()).all()
    return jsonify([sermon.to_dict() for sermon in sermons])

@sermons_bp.route('/api/sermons', methods=['POST'])
def add_sermon():
    print("Received request data:", request.form)

    title = request.form.get('title')
    preacher = request.form.get('preacher')
    category = request.form.get('category')
    description = request.form.get('description')
    audio_url = request.form.get('audioUrl')
    date_str = request.form.get('date')
    date = datetime.strptime(date_str, '%Y-%m-%d')
    duration = int(request.form.get('duration'))
    topics = request.form.get('topics').split(',') if request.form.get('topics') else []

    print("Extracted data:")
    print("Title:", title)
    print("Preacher:", preacher)
    print("Category:", category)
    print("Description:", description)
    print("Audio URL:", audio_url)
    print("Date:", date)
    print("Duration:", duration)
    print("Topics:", topics)

    if not title or not preacher or not category or not audio_url or not date:
        print("Missing required fields")
        return jsonify({'error': 'Missing required fields'}), 400

    sermon = Sermon(
        title=title,
        preacher=preacher,
        category=category,
        description=description,
        audio_url=audio_url,
        date=date,
        duration=duration,
        topics=[Topic(name=topic.strip()) for topic in topics]
    )
    db.session.add(sermon)
    db.session.commit()

    return jsonify(sermon.to_dict()), 201 