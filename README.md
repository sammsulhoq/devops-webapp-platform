# DevOps Web Application Platform

An end-to-end DevOps capstone demonstrating automated infrastructure provisioning, configuration management, application delivery, and monitoring on AWS.

Built as part of the Hero Vired DevOps Capstone.

## Implementation Status

Implemented and verified locally:

- Flask application with version and hostname information.
- Liveness and readiness endpoints.
- Prometheus metrics with HTTP request tracking.
- Six automated application tests.
- Docker image running Gunicorn as a non-root user.
- Docker Compose setup with an application health check.

Planned: Terraform, Ansible, Jenkins, Amazon ECR, Amazon EKS, Prometheus, and Grafana deployment.

No AWS infrastructure has been provisioned for this project yet.

## Run Locally with Docker

Prerequisites: Docker Engine and Docker Compose.

From the repository root:

```bash
docker compose up -d --build --wait
```

Open http://localhost:8000.

Check container health:

```bash
docker compose ps
```

Stop and remove the local containers:

```bash
docker compose down
```

## Run Automated Tests

Prerequisite: Python 3.12.

From the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
python -m pytest -q
```

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Application introduction, version, and hostname |
| `/api/info` | Application version and hostname |
| `/health/live` | Process liveness |
| `/health/ready` | Readiness to accept traffic |
| `/metrics` | Prometheus application and process metrics |

## Repository Layout

| Path | Purpose |
|---|---|
| `app/` | Application code and runtime dependencies |
| `tests/` | Automated application tests |
| `docs/screenshots/` | Project evidence |
| `docs/runbooks/` | Operational documentation |
| `Dockerfile` | Non-root application image |
| `docker-compose.yml` | Local container configuration |
| `requirements-dev.txt` | Development and test dependencies |

## Local Configuration

Docker Compose defaults `APP_VERSION` to `compose-local`.

To override it:

```bash
APP_VERSION=my-local-version docker compose up -d --wait
```

The application is published on the computer's loopback address only.

## Credentials and Configuration

Do not commit credentials, private keys, environment files, Terraform state, or saved Terraform plans.
