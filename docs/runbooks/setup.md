# Setup Guide

## Scope

This repository records an AWS deployment in ap-south-1.
Some configuration contains project-specific account IDs, role ARNs,
resource names, and an EKS OIDC issuer.

Before deploying into another account, review and adapt those values.
The repository is not yet a fully parameterized deployment template.

## Prerequisites

- An AWS account with permissions to provision the documented resources.
- An authenticated AWS CLI profile named herovired.
- Terraform >= 1.10 and < 2.0.
- Python 3.12, Ansible, Docker, Git, kubectl, and Helm.
- An SSH key pair for administering the Jenkins servers.
- Access to the GitHub repository.
- Budget for EKS, EC2, networking, storage, and load balancing.

Provider versions are recorded in each Terraform dependency lock file.
Review the pinned Helm chart versions in the Jenkinsfiles before setup.

## 1. Verify AWS Access

```bash
aws sts get-caller-identity \
  --profile herovired \
  --region ap-south-1 \
  --no-cli-pager
```

Confirm the intended account before provisioning anything.

## 2. Bootstrap State Storage

The committed bootstrap backend points to an existing S3 bucket.
A completely new installation cannot initialize that backend before
the bucket exists.

For a new installation only, use a separate clean checkout:

1. Temporarily move infrastructure/bootstrap/backend.tf outside the
   Terraform configuration directory.
2. Initialize the bootstrap directory with the default local backend.
3. Generate and review a saved plan, then apply it.
4. Restore backend.tf and set its bucket to the newly created bucket.
5. Run terraform init -migrate-state in the bootstrap directory.
6. Confirm migration when prompted and verify the remote state.
7. Preserve any local state backups securely until migration is verified.

Do not perform this procedure against the existing working installation.
Do not commit local state or backups.

The bucket name is derived from the authenticated AWS account.
Its configuration blocks public access, enables versioning and AES256
encryption, and denies insecure transport.

The bucket has prevent_destroy enabled and force_destroy disabled.
All three backends use S3-native locking.

State keys:

| Layer | S3 key |
|---|---|
| Bootstrap | bootstrap/terraform.tfstate |
| Management | management/terraform.tfstate |
| Platform | platform/dev/terraform.tfstate |

Update the management and platform backend bucket settings when adapting
the project to another account.

## 3. Configure Management Inputs

Create an untracked infrastructure/management/terraform.tfvars containing:

```hcl
admin_cidr          = "YOUR_PUBLIC_IPV4/32"
ssh_public_key_path = "~/.ssh/hv-capstone.pub"
```

Use the public key path, never the private key contents.

Initialize, validate, and plan the management configuration:

```bash
AWS_PROFILE=herovired terraform -chdir=infrastructure/management init

AWS_PROFILE=herovired terraform -chdir=infrastructure/management validate

AWS_PROFILE=herovired terraform -chdir=infrastructure/management \
  plan -out=management.tfplan
```

Review the complete plan before applying that saved plan:

```bash
AWS_PROFILE=herovired terraform -chdir=infrastructure/management \
  apply management.tfplan
```

## 4. Generate Ansible Inventory

After management provisioning:

```bash
AWS_PROFILE=herovired python3 scripts/generate_inventory.py
```

The script reads Terraform's saved management outputs.
After EC2 stop/start, those outputs can contain old public IPs.
Refresh and review management state outputs before regenerating inventory.

Keep the generated inventory and private keys out of Git.
Verify SSH connectivity before running configuration playbooks.

## 5. Configure Jenkins Servers with Ansible

Run these commands from the repository root after generating inventory
and verifying administrator SSH access.

For a fresh installation, generate a dedicated controller-to-agent SSH
key pair. Replace ansible/files/jenkins-agent.pub with its public key.
Ansible installs this key for the agent's jenkins user.

Keep the matching private key outside Git. It is separate from the
administrator key used by the generated inventory.

Check connectivity:

```bash
ansible -i ansible/inventories/generated.ini all -m ping
```

Run the playbooks in order:

```bash
ansible-playbook -i ansible/inventories/generated.ini   ansible/playbooks/common.yml

ansible-playbook -i ansible/inventories/generated.ini   ansible/playbooks/jenkins-controller.yml

ansible-playbook -i ansible/inventories/generated.ini   ansible/playbooks/jenkins-agent.yml
```

The controller playbook installs Java and Jenkins and enables its service.

The agent playbook creates the jenkins user, authorizes its SSH key,
installs Java, Docker, AWS CLI, Terraform, kubectl, Helm, and Ansible,
and grants the user Docker access.

Reconnect the Jenkins agent after changing Docker group membership.

## 6. Complete Jenkins Initial Setup

Access Jenkins through an SSH tunnel to the controller rather than
opening port 8080 publicly.

Complete the setup wizard and create the administrator account.
Retrieve the initial password privately on the controller; never save it
in screenshots or Git.

Install the plugins required by the jobs: Pipeline, Git, GitHub,
SSH Build Agents, Credentials Binding, and Email Extension, together
with their dependencies.

Set the controller's executor count to zero.

Create an SSH username/private-key credential:

- ID: hv-capstone-agent-ssh
- Username: jenkins
- Private key: the dedicated agent key matching jenkins-agent.pub

Configure the agent node:

- Name: capstone-agent
- Label: devops-agent
- Remote root: /home/jenkins/agent
- Host: the agent's private IP from Terraform outputs
- Launch method: SSH
- Credential: hv-capstone-agent-ssh

Verify the agent host key through a trusted connection and configure
host-key verification. Confirm the node is online before running jobs.

The agent uses its EC2 IAM role for AWS operations. Do not copy local
AWS access keys onto it.

## 7. Create Jenkins Pipeline Jobs

Create Pipeline jobs using Pipeline script from SCM, Git, the repository
URL, and branch */main.

| Job | Script path |
|---|---|
| capstone-platform-infrastructure | jenkins/Jenkinsfile.infrastructure |
| capstone-platform-components | jenkins/Jenkinsfile.platform |
| capstone-application-pipeline | jenkins/Jenkinsfile.application |
| capstone-monitoring-pipeline | jenkins/Jenkinsfile.monitoring |

The public repository can be checked out without Git credentials.
A private repository requires a separately configured credential.

Review account-specific values and the approval submitter in the
Jenkinsfiles before using another account or administrator.

Ensure the management Terraform configuration has applied the agent IAM
permissions required by these pipelines. The agent cannot provision
platform resources using its initial server-access permissions alone.

## 8. Provision the EKS Platform

Initialize and validate infrastructure/platform after configuring its
backend and inputs.

Run capstone-platform-infrastructure with the current administrator
IPv4 /32 and APPLY_CHANGES disabled.

Review the complete plan. Run again with APPLY_CHANGES enabled and
approve the fresh plan only after reviewing it.

Wait for the cluster and managed node group to become ready.
The platform includes the ECR repository, metrics-server addon,
EKS access entries, OIDC provider, and load balancer controller IAM role.

For local administration, create the named kubeconfig context using
AWS CLI and verify that both worker nodes are Ready.

## 9. Install Platform Components and Deploy the Application

Run capstone-platform-components to install AWS Load Balancer Controller.
Its Helm values must match the provisioned cluster, VPC, region, and
controller IAM role.

Run capstone-application-pipeline after the controller is ready.
Verify tests, image push, rollout, and application version checks.

Inspect the Ingress address and request /api/info through the public ALB.
Confirm that its target group reports healthy application targets.

The application pipeline uses Kubernetes manifests. The platform and
monitoring pipelines use Helm; an application Helm chart is not required
by this implementation.

## 10. Prepare Monitoring and Notifications

Create the monitoring namespace and required Secrets before running
capstone-monitoring-pipeline.

Required Secrets:

| Secret | Purpose |
|---|---|
| monitoring-grafana-admin | Grafana administrator credentials |
| capstone-alertmanager-config | Alertmanager configuration and SES SMTP settings |

Use private input or an approved secret-management workflow.
Do not commit Secret manifests containing real credentials.
Base64 encoding does not make a Kubernetes Secret safe to publish.

Configure SES identities and SMTP credentials separately.
While SES is in the sandbox, both sender and recipient must be verified.

Configure Jenkins Email Extension with the SES regional SMTP endpoint,
port 587, STARTTLS enabled, and implicit SSL disabled.
Store its SMTP credential as hv-capstone-ses-smtp.

Run capstone-monitoring-pipeline, then verify monitoring pods,
application targets, dashboards, and alert rules.

Monitoring resources can be recreated from Git, but the current setup
requires the Secrets to be supplied separately.

## 11. Configure Signed GitHub Webhooks

Generate a strong shared secret and store it privately.
Create a Jenkins Secret text credential named
hv-capstone-github-webhook-secret.

Select that credential in the GitHub plugin's shared webhook secret
configuration.

In the application job, enable GitHub hook trigger for GITScm polling.
Disable scheduled Poll SCM for this webhook demonstration.

Keep an SSH tunnel running from local port 18091 to the controller's
loopback port 8080. Use the controller's current public IP.

Start the local forwarder in another terminal:

```bash
python3 scripts/webhook_forwarder.py
```

It listens on 127.0.0.1:18092 and forwards only /github-webhook/ to Jenkins.
It preserves the original body and signature headers.

Start the temporary Cloudflare tunnel in a third terminal:

```bash
docker run --rm --name capstone-webhook-tunnel --network host   cloudflare/cloudflared:latest tunnel --no-autoupdate   --url http://127.0.0.1:18092
```

This command reflects the Linux Docker host-network setup used in the lab.
The cloudflared image is not pinned; record the tested version when
reproducing the demonstration.

In GitHub repository settings, create or update the webhook:

- Payload URL: the current HTTPS tunnel URL followed by /github-webhook/
- Content type: application/json
- Secret: the same value configured in Jenkins
- Events: push
- SSL verification: enabled
- Active: enabled

Do not publish the shared secret or temporary tunnel address.

Generate a fresh push and verify:

1. GitHub reports HTTP 200.
2. The forwarder reports Jenkins webhook response: 200.
3. The Jenkins build cause identifies a GitHub push.
4. Tests, image push, deployment, and version verification succeed.

All three connections must remain running.
After a controller restart, update the SSH destination.
After an agent restart, reconcile the EKS API allowlist.
After a Cloudflare tunnel restart, update the webhook URL if it changes.

This is a demonstration arrangement. A permanent installation requires
a stable HTTPS webhook endpoint and reliable service supervision.

## 12. Final Verification

Confirm:

- Both worker nodes are Ready.
- Application replicas are ready and the HPA has valid metrics.
- The public application endpoint returns the expected deployed version.
- Monitoring pods are ready and application targets are UP.
- Grafana displays application and cluster metrics.
- Controlled alert and pipeline failure tests deliver email.
- Test changes are restored and no intentional failures remain in Git.

See validation.md for completed tests and their limitations.
See troubleshooting.md for recovery procedures.
See cost-management.md for pause and cleanup considerations.
