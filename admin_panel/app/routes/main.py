from flask import current_app, abort, jsonify
from . import main_bp

@main_bp.route('/')
def index():
    return current_app.send_static_file('index.html')

@main_bp.route('/favicon.ico')
def favicon():
    return current_app.send_static_file('favicon.ico')

@main_bp.route('/<path:filename>')
def serve_static(filename):
    try:
        return current_app.send_static_file(filename)
    except FileNotFoundError:
        abort(404)

@main_bp.errorhandler(404)
def not_found(e):
    return current_app.send_static_file('index.html'), 404 

@main_bp.route('/api/dashboard/stats')
def dashboard_stats():
    # TODO: Fetch and return actual dashboard statistics
    stats = {
        'totalSermons': 10,
        'totalEvents': 5,
        'totalNotes': 8,
        'totalUsers': 100
    }
    return jsonify(stats) 