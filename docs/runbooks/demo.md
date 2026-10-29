# Capstone Demonstration

## 1. Explain the Problem

Manual deployments are difficult to repeat consistently.
This project automates application testing, image delivery, Kubernetes
deployment, infrastructure provisioning, and monitoring on AWS.

## 2. Show the Architecture

Open the README architecture diagram.

Explain the responsibilities:
- Terraform creates AWS infrastructure.
- Ansible configures Jenkins servers.
- Jenkins orchestrates jobs.
- Docker packages the application.
- ECR stores images.
- EKS runs application replicas.
- ALB routes external application traffic.
- Prometheus collects metrics; Grafana displays them.
- Alertmanager and Jenkins send notifications through SES.

This implementation uses AWS only. It is not a multi-cloud deployment.

## 3. Demonstrate Application Delivery

Confirm Jenkins and its agent are online and all webhook connections
are running.

Push a small, reviewed change. Show:
- GitHub webhook HTTP 200.
- Jenkins build cause identifying the GitHub push.
- Six passing application tests.
- Docker build and uniquely tagged ECR image.
- Successful Kubernetes rollout.
- Application version verification.

Request the public ALB /api/info endpoint and compare its version with
the successful build's image tag.

## 4. Demonstrate Infrastructure and Configuration

Run a plan-only infrastructure build.

Explain the saved-plan approval workflow and S3 state locking.
Do not introduce unnecessary infrastructure changes for the demonstration.

Show recorded evidence of an approved apply automatically triggering
capstone-server-configuration.

Show its Ansible recap with no failures and explain changed=0:
the existing configuration already matched the playbook.

Initial Jenkins installation remains a separate bootstrap operation.

## 5. Demonstrate Monitoring

Open the application and Jenkins Grafana dashboards.

Show:
- Application targets and request metrics.
- Cluster resource metrics.
- Jenkins readiness, executors, and queue length.

Show Prometheus up{job="jenkins"} = 1.

Explain that application health-check traffic is excluded from the
dashboard's business-request rate where configured.

## 6. Present Resilience and Alert Evidence

Use saved screenshots and the validation runbook to explain:
- HPA scaling from two to four pods and back.
- Pod replacement during sampled availability checks.
- Deployment rollback and restoration.
- Jenkins failure email.
- Alertmanager firing and recovery emails.

State the limits: sampled requests do not prove zero downtime, and the
rollback test used image tags sharing the same application digest.

## 7. Explain Costs and Production Improvements

Discuss the single NAT Gateway, bounded worker capacity, image lifecycle
policy, short metrics retention, and planned resource shutdown.

Explain remaining production improvements:
- TLS for application and metrics traffic.
- Stable webhook endpoint.
- Persistent monitoring storage.
- Narrower Jenkins AWS, Kubernetes, and server permissions.
- Separate environments and stronger release controls.

Use measured billing evidence if available; do not invent savings.
