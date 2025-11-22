# Voting Application - Fully Automated DevOps Pipeline.

- Local K8s Cluster	Environment to deploy and test the application (e.g., Minikube/Kind).

- Docker Engine	Required to build the images and run Docker Compose locally.

- kubectl CLI	For direct management and troubleshooting of Kubernetes resources.

- Helm CLI (v3+) Essential tool for templating and deploying the application chart.

- Terraform CLI Needed for validating the Infrastructure as Code (IaC) manifests.

- Git CLI	For code management and integration with the CI/CD pipeline.

- Ingress Controller	Nginx Ingress Addon must be enabled to route external traffic.

- Local DNS Mapping	Required to map vote.dev.local to the cluster's external IP (/etc/hosts).

- Docker Hub Access	For the CI/CD pipeline to push and pull built images.

- Cloud Credentials	Necessary to run terraform plan against Azure or AWS environments.


# Phase 1: Containerization & Local Setup

### This phase establishes the secure, reliable local development environment using Docker Compose.
# I. Key Production Decisions

- ##### Security & Efficiency: Dockerfiles were optimized using Multi-Stage Builds for small image sizes and enforced Non-Root User operation for all services to mitigate security risks.
- ##### Networking Isolation: Implemented a Two-Tier Networking Model (frontend vs. backend). This ensures the publicly accessible services (vote, result) are isolated from the sensitive data stores (postgres, redis).
- ##### Reliability Gates: Defined explicit Health Checks for Redis and PostgreSQL. This guarantees that dependent services (like the Worker) only start processing tasks once the databases are fully initialized and ready, not just running.

# II. Verification

- docker compose up -d --build
- Access: Check the application at http://localhost:8080 and the results at http://localhost:8081.




# Phase 2: Infrastructure & Deployment

- IaC Foundation : Terraform Code written for EKS/AKS (codifying the infrastructure).
- Deployment Tool : Helm Chart as the unified deployment mechanism.
- Data Safety : Implemented PersistentVolumeClaims (PVCs) and VolumeMounts for PostgreSQL and Redis.
- Security Hardening : Defined Secrets for credentials, Resource Limits, and Readiness Probes for all services.
- Network Isolation : NetworkPolicies codified to restrict backend access.

# Phase 3: Automation, Security & Observability

### This phase focused on building a robust, automated pipeline to move code from the repository to the running cluster, enforcing security and quality checks at every stage.

# I. CI/CD Workflow & Methodology
- Build : GitHub Actions runs docker build using Multi-Stage Builds and pushes images tagged with $GITHUB_SHA.
- Test : Run Python unit tests (pytest) in an isolated container environment.
- Security Scan : Utilized Trivy (FS & Image scan) in the pipeline.
- Deploy : helm upgrade to the ephemeral Minikube cluster (or real AKS).
- Wait/Verify : Used kubectl wait for the Nginx Webhook and Health Probes.

# II. System Observability
- ### Integrated Monitoring: The CI/CD cycle is complete because the deployment phase includes installing the Prometheus and Grafana monitoring stack via Helm.
- ### Final Goal: The cycle ensures that the application is not only deployed, but is immediately visible and measurable, achieving a Fully Automated Build ➝ Deploy ➝ Monitor Cycle.
