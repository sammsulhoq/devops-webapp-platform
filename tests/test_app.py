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
