# Validation Results

These results describe tests completed during the capstone.
They are not guarantees of ongoing availability.

## Application and Container

- Six automated application tests passed locally and in Jenkins.
- The Docker image runs Gunicorn as a non-root user.
- Application readiness and information endpoints returned successful responses.
- The information endpoint exposes the deployed version and pod hostname.

## Infrastructure and Configuration

- Terraform provisioned the management and application infrastructure.
- Remote state uses S3 with encryption, versioning, public access blocking,
  and state locking.
- Ansible connectivity and repeated configuration runs were checked.
- Jenkins controller and agent were configured separately.
- The Jenkins agent authenticated to AWS through its EC2 IAM role.
- Two EKS worker nodes became Ready.

## Application Delivery

- Jenkins tested the application, built its image, and pushed it to ECR.
- Jenkins deployed the application and waited for a successful rollout.
- A request through the Kubernetes Service returned the expected build version.
- The public ALB endpoint returned application information.
- The ALB target group reported two healthy application targets.
- A signed GitHub push webhook automatically started a successful deployment.

Evidence:
- ../screenshots/66-github-webhook-triggered-build.png
- ../screenshots/67-github-webhook-deployment-success.png

## Autoscaling

- metrics-server supplied node resource metrics.
- The application HPA used a CPU utilization target of 60%.
- Load testing caused application replicas to increase from two to four.
- Replicas returned to two after load ended and the stabilization period passed.

This verifies pod autoscaling. It does not demonstrate automatic scaling
of the EKS worker node group.

## Monitoring and Notifications

- Prometheus scraped both application targets successfully.
- Grafana displayed cluster and application metrics.
- An application monitoring failure triggered the configured alert.
- Restoring metric collection returned the alert to Inactive.
- SES delivered Alertmanager firing and recovery emails.
- An intentional Jenkins Replay failure delivered a pipeline failure email.

The alert test interrupted metric collection. It did not demonstrate
a complete application outage.

## Pod Replacement

A running application pod was deleted and Kubernetes created a replacement.
The replacement became Ready.

During the availability sampling test, 395 requests succeeded and none failed.
Requests were sampled every two seconds.

Evidence: pod-replacement-availability.log

Sampling does not prove zero downtime or uninterrupted service for every client.

## Rollback and Restoration

A previous Deployment revision was restored and the public endpoint returned
its expected APP_VERSION. The newer Deployment revision was then restored
and its version was verified.

The tested image tags shared the same image digest. This demonstrates
Deployment template and version configuration rollback, rather than rollback
between different application implementations.

## Known Limits

- Public application access uses HTTP without TLS.
- The webhook demonstration depends on local processes and a temporary URL.
- Monitoring data uses ephemeral storage.
- One NAT Gateway is shared by the private subnets.
- Jenkins has broad EKS administrative access in this learning environment.
- Lab cleanup automation can stop Jenkins instances.
- Multiple isolated application environments and automated code rollback
  have not been demonstrated.
