from flask import Flask
from flask_cors import CORS
from app.extensions import db
from config import Config
import os

# Create the Flask application instance
flask_app = Flask(__name__, 
    static_url_path='',  # This removes /static from URLs
    static_folder='../static'  # Relative path to static folder from app directory
)

def init_app():
    # Configure app
    flask_app.config.from_object(Config)
    
    # Initialize extensions
    CORS(flask_app)
    db.init_app(flask_app)

    # Register blueprints
    from app.routes import auth_bp, events_bp, sermons_bp, main_bp

    flask_app.register_blueprint(auth_bp)
    flask_app.register_blueprint(events_bp)
    flask_app.register_blueprint(sermons_bp)
    flask_app.register_blueprint(main_bp)

    # Create tables and default admin
    with flask_app.app_context():
        import app.models.models
        db.create_all()
        create_default_admin()

def create_default_admin():
    try:
        from app.models.models import Admin
        if not Admin.query.filter_by(username='admin').first():
            admin = Admin(
                username='admin',
                email='admin@example.com',
                is_active=True
            )
            admin.set_password('admin123')
            db.session.add(admin)
            db.session.commit()
            print("Default admin user created successfully!")
    except Exception as e:
        print(f"Error creating default admin: {e}")

# Initialize the application
init_app() 