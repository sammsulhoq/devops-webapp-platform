"""Automated checks for the capstone web application."""

import pytest

from app.main import app


@pytest.fixture
def client():
    """Provide a test client without starting a web server."""
    app.config.update(TESTING=True)

    with app.test_client() as test_client:
        yield test_client


def test_homepage(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.get_json()["application"] == "DevOps Web Application Platform"


@pytest.mark.parametrize(
    ("endpoint", "expected_status"),
    [
        ("/health/live", "healthy"),
        ("/health/ready", "ready"),
    ],
)
def test_health_endpoints(client, endpoint, expected_status):
    response = client.get(endpoint)

    assert response.status_code == 200
    assert response.get_json()["status"] == expected_status


def test_application_version(client, monkeypatch):
    monkeypatch.setenv("APP_VERSION", "test-release")

    response = client.get("/api/info")
    data = response.get_json()

    assert response.status_code == 200
    assert data["version"] == "test-release"
    assert data["hostname"]


def test_unknown_route(client):
    response = client.get("/does-not-exist")

    assert response.status_code == 404


def test_metrics_record_application_requests(client):
    client.get("/api/info")

    response = client.get("/metrics")
    metrics_text = response.get_data(as_text=True)

    assert response.status_code == 200
    assert response.mimetype == "text/plain"
    assert (
        'capstone_http_requests_total{method="GET",route="/api/info",status="200"}'
        in metrics_text
    )
