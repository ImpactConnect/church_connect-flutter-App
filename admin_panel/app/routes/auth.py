from flask import jsonify, request, current_app
from app.extensions import db
from app.models.models import Admin
from . import auth_bp
import jwt
from datetime import datetime

@auth_bp.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return jsonify({'error': 'Missing credentials'}), 400

        admin = Admin.query.filter_by(username=username).first()

        if not admin or not admin.check_password(password):
            return jsonify({'error': 'Invalid credentials'}), 401

        if not admin.is_active:
            return jsonify({'error': 'Account is disabled'}), 401

        # Update last login
        admin.last_login = datetime.utcnow()
        db.session.commit()

        # Generate token
        token = jwt.encode({
            'user_id': admin.id,
            'username': admin.username,
            'exp': datetime.utcnow() + current_app.config['JWT_EXPIRATION_DELTA']
        }, current_app.config['SECRET_KEY'])

        return jsonify({
            'token': token,
            'user': admin.to_dict()
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500 