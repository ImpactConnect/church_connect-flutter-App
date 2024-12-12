from flask import Blueprint

auth_bp = Blueprint('auth', __name__)
events_bp = Blueprint('events', __name__)
sermons_bp = Blueprint('sermons', __name__)
main_bp = Blueprint('main', __name__)

from . import auth, events, sermons, main 