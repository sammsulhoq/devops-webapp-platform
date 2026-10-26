"""Web application for the Hero Vired DevOps capstone."""

import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    """Display basic application information."""
    return jsonify(
        application="DevOps Web Application Platform",
        message="Hello from the Hero Vired capstone!",
        version=os.getenv("APP_VERSION", "local"),
        hostname=socket.gethostname(),
    )


@app.get("/health/live")
def health_live():
    """Confirm that the application process is responding."""
    return jsonify(status="healthy"), 200
