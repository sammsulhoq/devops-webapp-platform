# Troubleshooting

Use AWS profile `herovired`, region `ap-south-1`, and Kubernetes context
`hv-capstone-dev`. Never share credentials, private keys, or webhook secrets.

## Jenkins Dashboard Does Not Load

Check the controller's state and current public IP:

```bash
aws ec2 describe-instances \
  --instance-ids i-00ab6db047a19a67d \
  --profile herovired \
  --region ap-south-1 \
  --query 'Reservations[].Instances[].{State:State.Name,PublicIP:PublicIpAddress}' \
  --output table \
  --no-cli-pager
```

Start a stopped instance and retrieve its new public IP before reconnecting.
If SSH times out, check EC2 status checks and the actual security group.
SSH access must allow your current public IP.

If SSH works, run these commands on the controller:

```bash
systemctl is-active jenkins
curl -I --max-time 10 http://127.0.0.1:8080/
```

An unauthenticated HTTP 403 can confirm that Jenkins is responding.
Reopen the SSH tunnel using the current controller IP and keep it running.

## Local Tunnel Port Already in Use

Inspect the existing listener:

```bash
ss -ltnp 'sport = :18091'
curl -I --max-time 10 http://127.0.0.1:18091/
```

Stop only the identified stale tunnel before recreating it.
The webhook forwarder expects Jenkins on local port 18091.

## EC2 Instances Stop Unexpectedly

Inspect recent stop events:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=StopInstances \
  --max-results 10 \
  --profile herovired \
  --region ap-south-1 \
  --query 'Events[].{Time:EventTime,Actor:Username,Resources:Resources[].ResourceName}' \
  --output json \
  --no-cli-pager
```

Project events identified `aws-janitor` stopping Jenkins instances.
Contact the lab provider about working-session exemptions.
Do not modify the provider's cleanup automation.

## Kubernetes Reports Unauthorized

Check the AWS session:

```bash
aws sts get-caller-identity \
  --profile herovired \
  --region ap-south-1 \
  --no-cli-pager
```

Refresh expired credentials, then retry:

```bash
AWS_PROFILE=herovired kubectl --context hv-capstone-dev get nodes
```

If authentication succeeds but access still fails, check EKS access
entries and Kubernetes permissions.

## Jenkins Times Out Connecting to EKS

Restarting the agent can change its public IP. The EKS API allowlist
may still contain the previous address.

Run the infrastructure job with the current ADMIN_CIDR and APPLY_CHANGES
disabled. Review the plan, then run again with approval to apply it.

Do not disable Kubernetes validation to work around a network timeout.

## Terraform Saved Plan Is Stale

Another operation changed the state after the plan was generated.
Generate and review a fresh plan before applying it.
Do not force-unlock state unless its lock is confirmed abandoned.

## Webhook Returns 502

Check that all components are running:

- Cloudflare tunnel.
- Local forwarder on port 18092.
- SSH tunnel to Jenkins on port 18091.
- Jenkins controller.

The forwarder returns 502 when it cannot connect to Jenkins.
If the temporary Cloudflare URL changes, update the GitHub webhook URL.

## Webhook Returns 400 for an Invalid Signature

Confirm that GitHub sends X-Hub-Signature-256.
Use the same shared secret in GitHub and Jenkins.

Preserve the original request body and signature headers.
Reformatting JSON can invalidate the signature.

Generate a fresh push event after correcting the configuration.
Keep signature verification enabled.

## Webhook Returns 200 but No Build Starts

Check the application's GitHub hook trigger, repository URL, branch,
and polling log.

HTTP 200 alone does not prove deployment. Verify the GitHub push build
cause, successful pipeline result, and deployed application version.

## Grafana or Prometheus Refuses Local Connections

Their Services use ClusterIP. Check that monitoring pods are ready,
then start the appropriate kubectl port-forward and keep it running.

## HPA Metrics Are Missing

Check metrics-server and node metrics:

```bash
AWS_PROFILE=herovired kubectl --context hv-capstone-dev \
  -n kube-system get deployment metrics-server

AWS_PROFILE=herovired kubectl --context hv-capstone-dev top nodes
```

New or unready pods may temporarily lack metrics.
Inspect HPA conditions and events before changing its configuration.

## SES Email Does Not Arrive

While SES is in its sandbox, verify both sender and recipient identities.
For SMTP port 587, use STARTTLS without also enabling implicit SSL.

Check Jenkins mail settings and errors, and inspect the recipient's spam
folder. Verify actual receipt; a successful job alone does not prove
email delivery.
