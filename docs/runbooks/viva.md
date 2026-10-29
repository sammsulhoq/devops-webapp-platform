# Capstone Viva Notes

## What problem does this project solve?

It makes application delivery repeatable: a GitHub push triggers tests,
an image build, an ECR push, an EKS rollout, and a version check.
Infrastructure and server configuration are also managed as code.

## Why use both Terraform and Ansible?

Terraform manages AWS resources and their lifecycle.
Ansible configures software on the Jenkins servers.
EKS managed worker nodes are not configured using these Ansible playbooks.

## Why separate the Jenkins controller and agent?

The controller schedules jobs and manages Jenkins.
The agent executes builds and deployments.
The controller has zero executors. This separation is useful, but it
does not make builds fully isolated from privileged credentials.

## How does Jenkins authenticate to AWS?

The agent uses temporary credentials supplied through its EC2 IAM role.
Local AWS credentials are not copied into the pipeline.

## Why store Terraform state in S3?

Remote state gives authorized operators a shared record of managed
resources. Encryption, versioning, blocked public access, HTTPS
enforcement, and S3-native locking protect its use.

State and saved plans can contain sensitive data and stay out of Git.

## How are infrastructure changes approved?

Jenkins creates a saved plan. An authorized operator reviews and approves
it, then that build applies the saved plan.
Plan-only runs do not apply changes or trigger configuration.

## How does Terraform trigger Ansible?

After successful apply, Jenkins asynchronously queues the configuration
job. That job validates SSH and sudo access and applies common.yml.

Asynchronous execution avoids waiting while holding the agent executor.
The downstream result must be checked separately.

Initial controller and agent installation remains a bootstrap operation.

## What is the difference between readiness and liveness?

Readiness determines whether a pod should receive Service traffic.
Liveness detects an unhealthy running container and can trigger a restart.

## How does autoscaling work?

The HPA uses CPU utilization relative to container CPU requests.
The tested configuration scales between two and four application pods.

This does not automatically scale worker nodes.

## How does external traffic reach a pod?

The AWS Load Balancer Controller reconciles the Ingress into an ALB.
With IP targets, the ALB routes traffic to registered pod IPs.
The Ingress references the Kubernetes Service.

## Why use signed webhooks?

They trigger builds without scheduled polling.
Jenkins verifies a shared-secret signature over the original request body.

The demonstration uses a temporary Cloudflare endpoint, local forwarder,
and SSH tunnel. All must remain available.

## What monitoring was verified?

Prometheus scraped application, cluster, and Jenkins metrics.
Grafana displayed application, cluster, and Jenkins dashboards.
SES delivered Jenkins failure and Alertmanager firing/recovery emails.

The Jenkins dashboard covers readiness, executors, and queue length.
It does not include per-job duration or failure-rate panels.

## What resilience tests were completed?

HPA scale-up and scale-down, pod replacement, and Deployment rollback.

During pod replacement, 395 sampled requests succeeded with no observed
failures. Sampling every two seconds does not prove zero downtime.

Rollback restored an older template and APP_VERSION. The tested image
tags shared a digest, so different application code was not rolled back.

## What cost evidence is available?

Cost Explorer returned estimated account-wide costs for the recorded
period. Project-tag attribution was unavailable.

The cost guide records the reporting date and limitations.
No measured savings percentage is claimed.

## What would you improve for production?

Add TLS, a stable webhook endpoint, persistent monitoring storage,
narrower permissions, isolated environments, stronger release controls,
and tested recovery procedures.

The current deployment is an AWS learning environment, not multi-cloud.
