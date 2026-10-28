# DevOps Capstone 1: Containerization, IaC, and Kubernetes Lifecycle Management

An enterprise-ready deployment of the polyglot **Example Voting App** on AWS Elastic Kubernetes Service (EKS). This project demonstrates multi-stage container hardening, automated CI/CD with vulnerability scanning, Infrastructure as Code (Terraform), unified Helm chart packaging, and zero-downtime release rollback strategies.

---

## Architecture Overview

The system consists of five decoupled microservices:
* **Vote (`Python/Flask`)**: Frontend web interface for users to cast votes.
* **Redis (`In-Memory Queue`)**: Buffers incoming votes before processing.
* **Worker (`.NET Core`)**: Background consumer pulling votes from Redis and persisting them into PostgreSQL.
* **Database (`PostgreSQL`)**: Relational data store for deduplicated vote records.
* **Result (`Node.js/Express`)**: Frontend web dashboard displaying real-time vote metrics via WebSockets.


---

## Core Engineering Implementations

### 1. Docker Multi-Stage Builds & Security Hardening
* **Minimal Attack Surface:** Built microservices using minimal base images (`alpine`, `slim`) with multi-stage compilation to eliminate build dependencies, compilers, and development headers from runtime artifacts.
* **Non-Root Execution:** Hardened container definitions by binding execution to dedicated non-root users (`USER appuser` / `USER node`).
* **Deterministic Tagging:** Configured automated image builds tagged deterministically using Git commit SHAs rather than mutable `latest` tags.

### 2. Automated CI/CD & Vulnerability Scanning (GitHub Actions)
* Continuous integration matrix workflow triggered on branch pushes.
* Integrates **Trivy** scanning into the pipeline to block critical and high severity vulnerabilities before publishing images.
* Automatically packages and pushes multi-architecture images to Docker Hub:
  * `echeck246/voting-app-vote:<commit-sha>`
  * `echeck246/voting-app-result:<commit-sha>`
  * `echeck246/voting-app-worker:<commit-sha>`

### 3. Infrastructure as Code (Terraform on AWS)
* Declarative provisioning of AWS infrastructure in `eu-north-1`:
  * **VPC:** Multi-AZ public and private subnets with route table associations and internet gateway routing.
  * **EKS Cluster (v1.31):** Managed control plane configured with strict IAM role bindings.
  * **Managed Node Groups:** EC2 compute instances configured with auto-scaling boundaries and proper node labels.

### 4. Unified Helm Chart Packaging (`voting-app`)
* Consolidated all 5 microservices, ClusterIP services, persistent volume configurations, and environment secrets into a single, modular Helm chart.
* Decoupled environment configurations and image tags into an externalized `values.yaml` file.

### 5. Deployment Lifecycle & Rollback Drill
To validate resilience and recovery procedures:
1. Deployed initial stable release at Revision 3 with all 5 pods active (`1/1 Running`).
2. Simulated a production failure by pushing a release with an invalid image tag (`vote.image.tag=does-not-exist`).
3. Observed Kubernetes containment behavior: new replica halted in `ImagePullBackOff` while existing pods maintained availability.
4. Executed rapid recovery using Helm:
   ```bash
   helm rollback voting-app 3

# Repository structure
├── .github/
│   └── workflows/
│       └── ci.yaml              # Build, Trivy scan, and Docker Hub push workflow
├── terraform/
│   ├── main.tf                  # EKS cluster and VPC infrastructure definition
│   ├── variables.tf             # Cluster configuration variables
│   └── outputs.tf               # EKS endpoint and ARN outputs
├── voting-app/                  # Unified Helm Chart
│   ├── Chart.yaml               # Chart metadata (v0.1.0)
│   ├── values.yaml              # Centralized service configuration & image tags
│   └── templates/
│       ├── db.yaml              # PostgreSQL deployment & service
│       ├── redis.yaml           # Redis deployment & service
│       ├── vote.yaml            # Vote UI deployment & service
│       ├── result.yaml          # Result UI deployment & service
│       └── worker.yaml          # Background worker deployment
├── vote/                        # Python voting app source & multi-stage Dockerfile
├── result/                      # Node.js dashboard source & multi-stage Dockerfile
├── worker/                      # .NET Core worker source & multi-stage Dockerfile
└── .gitignore                   # Ignore rules for tfstate, secrets, and caches


Local Verification & Port-Forwarding
Bash
# Port-forward Vote UI (Python)
kubectl port-forward svc/vote 5000:5000
# Access via http://localhost:5000

# Port-forward Result UI (Node.js)
kubectl port-forward svc/result 5001:5001
# Access via http://localhost:5001
Infrastructure Teardown & Cost Management
To guarantee zero lingering cloud expenditure:

Bash
# 1. Cleanly uninstall in-cluster workloads
helm uninstall voting-app

# 2. Destroy AWS EKS nodegroups, cluster, and VPC via Terraform
cd terraform
terraform destroy -auto-approve

# 3. Confirm termination of compute instances
aws ec2 describe-instances --region eu-north-1 \
  --filters "Name=instance-state-name,Values=running"

---

### Capstone 1 Executive Submission Summary
> **Project Title:** DevOps Capstone 1: Polyglot Microservices CI/CD, EKS IaC, and Kubernetes Lifecycle Management  
> **Repository:** `https://github.com/echeck246/example-voting-app`  
> **Key Accomplishments:**  
> 1. Hardened multi-stage Docker builds across Python, Node.js, and .NET Core microservices, enforcing non-root runtime users and eliminating attack surface bloat.  
> 2. Implemented automated GitHub Actions CI with Trivy vulnerability scanning and Git-SHA-based Docker Hub image tagging.  
> 3. Provisioned modular, production-ready AWS EKS infrastructure (v1.31) using Terraform in `eu-north-1`.  
> 4. Packaged all 5 microservices under a single, unified Helm chart (`voting-app`) with centralized parameterization via `values.yaml`.  
> 5. Successfully conducted failure injection and rollback drill via Helm lifecycle history, demonstrating zero-downtime recovery.  
> 6. Executed complete post-validation cloud teardown to enforce zero idle cloud expenditure.


# Example Voting App

A simple distributed application running across multiple Docker containers.

## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.
