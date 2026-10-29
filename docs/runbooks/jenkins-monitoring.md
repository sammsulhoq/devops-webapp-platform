# Jenkins Monitoring

## Components

The Jenkins Prometheus metrics plugin exposes /prometheus/ on port 8080.
Prometheus in EKS scrapes it every 30 seconds.

Grafana dashboard: Capstone Jenkins

| Panel | Metric |
|---|---|
| Jenkins Ready | default_jenkins_up |
| Available Executors | default_jenkins_executors_available |
| Busy Executors | default_jenkins_executors_busy |
| Queue Length | default_jenkins_executors_queue_length |

Executor and queue queries filter label="devops-agent".
The same executor also appears under the node's self-label, so summing
across labels would double-count capacity.

## Network Access

The controller security group allows TCP 8080 from the EKS NAT Gateway's
public IPv4 /32, supplied through monitoring_source_cidr in the management
Terraform inputs.

This rule permits the whole HTTP listener from that source, not only
the metrics path. Jenkins authentication remains enabled for protected
resources, but the tested metrics endpoint permits anonymous reads.

Scraping currently uses HTTP through public addresses. Private routing,
TLS, and authenticated metrics access are production improvements.

## Deployment

Source files:

- monitoring/jenkins-scrape-values.yaml
- monitoring/jenkins-dashboard.json
- jenkins/Jenkinsfile.monitoring

The monitoring pipeline discovers the running controller's public IP
through the EC2 API and validates it as IPv4. It renders the scrape values
into a temporary file and passes that file to the pinned monitoring chart.

It also applies the Grafana dashboard ConfigMap.

## After an EC2 Restart

1. Restore the Jenkins controller and agent.
2. Reconnect the local Jenkins SSH tunnel.
3. If the agent IP changed, reconcile the EKS API allowlist through the
   reviewed infrastructure pipeline.
4. Run capstone-monitoring-pipeline to refresh the controller scrape IP.
5. Verify up{job="jenkins"} returns 1.
6. Check all four Grafana dashboard panels.

Discovery happens when the job runs; it is not continuous.
If the NAT Gateway address changes, update monitoring_source_cidr and
review and apply the management Terraform plan.

## Verified Results

- EKS reached /prometheus/ and received HTTP 200 with metric content.
- Prometheus returned up{job="jenkins"} = 1.
- Grafana displayed readiness, available executors, busy executors,
  and queue length.

Evidence:

- ../screenshots/71-prometheus-jenkins-target-up.png
- ../screenshots/72-grafana-jenkins-dashboard.png

These panels show controller readiness and scheduling capacity.
They do not provide per-job build duration or failure-rate dashboards.
Pipeline failure emails are configured separately.
