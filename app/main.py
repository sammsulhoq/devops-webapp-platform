"""Web application for the Hero Vired DevOps capstone."""

import os
import socket

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

app = Flask(__name__)

HTTP_REQUESTS = Counter(
    "capstone_http_requests_total",
    "Total application HTTP requests",
    ["method", "route", "status"],
)


@app.after_request
def record_request(response):
    """Count requests without counting monitoring scrapes."""
    if request.path != "/metrics":
        route = request.url_rule.rule if request.url_rule else "unmatched"

        HTTP_REQUESTS.labels(
            method=request.method,
            route=route,
            status=str(response.status_code),
        ).inc()

    return response


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


@app.get("/health/ready")
def health_ready():
    """Confirm that this instance can accept application traffic."""
    return jsonify(status="ready"), 200


@app.get("/api/info")
def application_info():
    """Return the application version and instance hostname."""
    return jsonify(
        application="DevOps Web Application Platform",
        version=os.getenv("APP_VERSION", "local"),
        hostname=socket.gethostname(),
    )


@app.get("/metrics")
def metrics():
    """Expose application and process measurements for Prometheus."""
    return Response(generate_latest(), content_type=CONTENT_TYPE_LATEST)
