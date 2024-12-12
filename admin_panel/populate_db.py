from app import flask_app
from app.models.models import Sermon, Event
from app.extensions import db
from datetime import datetime, timedelta

def populate_sermons():
    sermons = [
        Sermon(
            title='Sermon 1',
            preacher='Pastor John',
            category='Sunday Service',
            date=datetime(2023, 1, 1),
            duration=3600,
            audio_url='https://example.com/sermon1.mp3'
        ),
        Sermon(
            title='Sermon 2',
            preacher='Pastor Jane',
            category='Wednesday Service',
            date=datetime(2023, 2, 1),
            duration=2700,
            audio_url='https://example.com/sermon2.mp3'
        ),
        # Add more sample sermons...
    ]

    with flask_app.app_context():
        db.session.add_all(sermons)
        db.session.commit()
        print(f'Added {len(sermons)} sample sermons to the database.')

def populate_events():
    events = [
        Event(
            title='Event 1',
            description='This is the first event',
            start_date=datetime(2023, 6, 1, 10, 0),
            end_date=datetime(2023, 6, 1, 12, 0),
            location='Church Hall',
            category='Seminar'
        ),
        Event(
            title='Event 2',
            description='This is the second event',
            start_date=datetime(2023, 7, 15, 14, 0),
            end_date=datetime(2023, 7, 15, 16, 0),
            location='Conference Room',
            category='Workshop'
        ),
        # Add more sample events...
    ]

    with flask_app.app_context():
        db.session.add_all(events)
        db.session.commit()
        print(f'Added {len(events)} sample events to the database.')

if __name__ == '__main__':
    populate_sermons()
    populate_events() 