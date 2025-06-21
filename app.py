#!/usr/bin/env python3
"""
The Office BALLS Simulator - Web Interface
Simple Flask app for demonstrating BALLS-powered Office dynamics
"""

from flask import Flask, render_template, request, jsonify
import json
from office_meeting_simulator import OfficeMeetingSimulator

app = Flask(__name__)

# Global simulator instance
simulator = OfficeMeetingSimulator()

@app.route('/')
def index():
    """Main interface for the Office meeting simulator"""
    return render_template('index.html')

@app.route('/api/start_meeting', methods=['POST'])
def start_meeting():
    """API endpoint to start a new Office meeting"""
    data = request.get_json()
    topic = data.get('topic', 'General office discussion')
    max_turns = data.get('max_turns', 10)
    
    # Run the meeting simulation
    meeting_log = simulator.start_meeting(topic, max_turns)
    analytics = simulator.analyze_meeting_dynamics()
    
    return jsonify({
        'meeting_log': meeting_log,
        'analytics': analytics,
        'success': True
    })

@app.route('/api/demo_topics')
def demo_topics():
    """Get suggested demo topics"""
    topics = [
        "We need to discuss the new sales targets",
        "There's been an HR complaint about workplace behavior", 
        "Someone has been stealing lunches from the refrigerator",
        "We need to plan the office party",
        "There are rumors about corporate layoffs",
        "I think we need better security measures",
        "The printer is broken again",
        "We should discuss work-from-home policies"
    ]
    return jsonify(topics)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)