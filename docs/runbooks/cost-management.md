# Cost Management

## Implemented Cost Controls

| Choice | Benefit | Tradeoff |
|---|---|---|
| Two t3.medium EKS workers | Bounded baseline capacity for the lab | Fixed worker cost while running |
| Application HPA: two to four pods | Limits application replica growth | Does not scale worker nodes |
| One NAT Gateway | Lower baseline cost than one per Availability Zone | Shared dependency and possible cross-AZ transfer costs |
| Six-hour Prometheus retention | Limits retained monitoring data | Short investigation history |
| Ephemeral monitoring storage | Avoids dedicated persistent monitoring volumes | History is lost when pods are replaced |
| ECR lifecycle policy | Controls image retention according to the configured rules | Retention must preserve images needed for rollback |
| Jenkins EC2 stop/start | Reduces instance compute usage outside working sessions | Public IPs change and connections need restoring |

These are learning-environment tradeoffs, not a production cost or
availability recommendation.

## Costs That Continue During a Pause

Stopping Jenkins instances does not remove their EBS storage.

Scaling the worker group to zero does not remove the EKS control plane,
NAT Gateway, Application Load Balancer, allocated public IPv4 addresses,
ECR images, S3 objects, or applicable data-transfer charges.

Verify resource usage and billing instead of assuming a paused
application has no cost.

## Daily Pause and Resume

Before pausing, finish builds and save documentation and evidence.

Stop Jenkins EC2 instances when they are no longer needed.
For a planned lab pause, the managed node group's minimum and desired
capacity can be reduced to zero, accepting application and monitoring
unavailability.

On resume, restore worker capacity, start Jenkins, retrieve current
public IPs, and restore local tunnels. Reconcile the agent's EKS API
allowlist through the reviewed infrastructure pipeline.

Avoid competing node-group changes from Terraform and the AWS CLI.
Review the next Terraform plan after any manual scaling operation.

## Final Cleanup

Delete the application's Ingress while the load balancer controller and
worker nodes are still available. Verify that its AWS load balancer and
associated resources have been removed before destroying the cluster
and network.

Review Terraform destroy plans separately for each infrastructure layer.
Preserve required evidence and protect state storage until dependent
resources have been removed.

This document does not execute cleanup.

## Billing Evidence

Use AWS billing tools to record actual project costs and the reporting
period before submission, if the lab account grants access.

Do not present account-wide costs as project-only costs. Shared resources,
tag coverage, reporting delay, and permissions can limit attribution.

No measured savings percentage or final project cost is claimed here.
