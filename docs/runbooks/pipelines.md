# Jenkins Pipelines

Jenkins runs build and deployment work on the agent labelled `devops-agent`.
The controller has zero build executors. The agent authenticates to AWS
through its EC2 IAM role.

## Infrastructure

Job: `capstone-platform-infrastructure`

Source: `jenkins/Jenkinsfile.infrastructure`

1. Check out the repository and verify the AWS identity.
2. Check Terraform formatting, initialize providers and state, and validate configuration.
3. Generate a saved plan using the supplied `ADMIN_CIDR`.
4. When `APPLY_CHANGES` is enabled, request approval from the configured operator.
5. Apply this build's saved plan and remove the temporary plan file.

Start with `APPLY_CHANGES` disabled to review proposed changes.
Infrastructure changes require a separate reviewed run with approval.

The platform discovers the running agent's public IP for the EKS API
allowlist. After an EC2 stop/start changes that IP, reconcile the allowlist
before running application or Helm deployments.

## Application

Job: `capstone-application-pipeline`

Source: `jenkins/Jenkinsfile.application`

1. Check out the repository and derive an image tag from the commit and build number.
2. Run the six application tests inside a Python container.
3. Build the application Docker image.
4. Authenticate to ECR and push the tagged image.
5. Generate a temporary kubeconfig for EKS.
6. Apply the Service, HPA, and rendered Deployment.
7. Wait for the Deployment rollout and apply the Ingress.
8. Request `/api/info` through the Kubernetes Service and compare its version
   with the current build's image tag.

A signed GitHub push webhook triggers this job automatically.
The pipeline sends an SES email notification on failure.

The version check runs inside the cluster. It does not replace a separate
test of the public Application Load Balancer endpoint.

## Monitoring

Job: `capstone-monitoring-pipeline`

Source: `jenkins/Jenkinsfile.monitoring`

The pipeline checks that the Grafana and Alertmanager configuration Secrets
exist, installs or upgrades the pinned monitoring Helm chart, and applies
the application ServiceMonitor, dashboard ConfigMap, and alert rules.

Secret values are created separately and are not stored in Git.

## Platform Components

Job: `capstone-platform-components`

Source: `jenkins/Jenkinsfile.platform`

The pipeline installs or upgrades the pinned AWS Load Balancer Controller
Helm chart and waits for its Deployment to become ready.
Terraform manages its IAM role, policy, and OIDC provider.

## Configuration Management

Job: `capstone-server-configuration`

Source: `jenkins/Jenkinsfile.configuration`

After a successful Terraform apply, the infrastructure pipeline
automatically queues this job with APPLY_CONFIGURATION enabled.
Plan-only runs skip the trigger.

The job validates common.yml, verifies SSH and sudo access to both
servers, and applies the common package configuration over private IPs.
It uses credential hv-capstone-ansible-ssh and recorded SSH host keys.

The trigger is asynchronous to avoid holding the agent executor while
waiting for another job that needs it. Check the configuration job's
result separately; its failure does not change the upstream result.

The automatic run completed successfully with changed=0,
unreachable=0, and failed=0 on both servers.

Controller and agent installation playbooks were run separately during
initial setup. They are not executed by this configuration job.

The dedicated configuration credential connects as ubuntu with sudo
access. Restrict who can modify or run pipelines that use it.

Evidence:
- ../screenshots/69-jenkins-ansible-configuration-success.png
- ../screenshots/70-terraform-triggered-ansible.png

## Webhook Demonstration

The demonstration uses a temporary Cloudflare tunnel, a local Python
forwarder, and an SSH tunnel to Jenkins.

The forwarder accepts only the webhook path and preserves the request body
and signature headers. Jenkins validates the shared-secret signature.

All three connections must remain running. If the Cloudflare URL changes,
update the GitHub webhook destination. A successful HTTP delivery alone
does not prove deployment: also verify the GitHub-triggered build and its
final deployment result.

A permanent installation needs a stable HTTPS webhook endpoint.
