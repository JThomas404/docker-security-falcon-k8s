# Docker Container Security Falcon

A secure, production-ready FastAPI application containerised with Docker, orchestrated via Kubernetes, and scanned for vulnerabilities with GitHub Actions and Trivy. This project showcases a cloud engineer’s mindset by focusing on container security, CI/CD automation, Role-Based Access Control (RBAC), pod security controls, and thoughtful architecture.

This project builds upon [Docker Container Security Falcon (Phase 1)](https://github.com/JThomas404/docker-security-falcon), extending it with a Kubernetes production-grade deployment layer and refined DevSecOps controls.

---

## Table of Contents

- [Purpose and Goals](#purpose-and-goals)
- [Project Overview](#project-overview)
- [Architecture Diagram](#architecture-diagram)
- [Key Technologies](#key-technologies)
- [Security-Focused Features](#security-focused-features)
- [Kubernetes Production-Ready Setup](#kubernetes-production-ready-setup)
- [CI/CD Pipeline with GitHub Actions](#cicd-pipeline-with-github-actions)
- [Before and After Trivy Scan Output](#before-and-after-trivy-scan-output)
- [Decisions and Justifications](#decisions-and-justifications)
- [Running the Project Locally](#running-the-project-locally)
- [Future Improvements](#future-improvements)

---

## Purpose and Goals

This project was developed to:

- Practice and showcase container security best practices.
- Apply CI/CD techniques using GitHub Actions and Trivy.
- Demonstrate production-aware deployment on Kubernetes and Docker.
- Simulate the mindset and problem-solving skills of a modern cloud engineer.
- Show decision-making skills in balancing automation, security, and scalability.

---

## Project Overview

This is a modular FastAPI web application originally developed in [docker-security-falcon](https://github.com/JThomas404/fastapi-project) and containerised securely using `python:3.11.12-slim`. The project was then extended with:

- Dockerfile security hardening
- GitHub Actions automation
- Kubernetes manifests with pod security and RBAC

---

## Architecture Diagram

```
User → Service (ClusterIP)
           ↓
    Kubernetes Deployment
           ↓
  Docker Container (non-root)
           ↓
    FastAPI App (Uvicorn)
```

---

## Key Technologies

- **FastAPI**: Lightweight async Python web framework
- **Docker**: Containerisation engine with hardening applied
- **Trivy**: Vulnerability scanner in CI/CD pipeline
- **GitHub Actions**: CI/CD automation for builds and scans
- **Kubernetes (Minikube)**: Orchestration with RBAC, probes, and secrets

---

## Security-Focused Features

- ✅ **Minimal base image** (`python:3.11.12-slim`) with pinned version
- ✅ **Non-root user** (`pyuser` with UID 1001)
- ✅ **Read-only root filesystem** in both Docker and Kubernetes
- ✅ **Secrets** injected as Kubernetes `env` variables (never hardcoded)
- ✅ **RBAC** via Role and RoleBinding with least privilege
- ✅ **ServiceAccount** scoped to namespace for isolation
- ✅ **3 replicas** deployed in Kubernetes for high availability
- ✅ **Liveness and readiness probes** (`/healthz`) for observability

---

## Kubernetes Production-Ready Setup

The app is deployed as a 3-replica deployment in a custom `falcon` namespace:

```yaml
spec:
  replicas: 3
  selector:
    matchLabels:
      app: falcon-api
  template:
    spec:
      serviceAccountName: falcon-api-sa
      containers:
        - name: falcon-api
          image: falcon-api:v1
          securityContext:
            runAsUser: 1001
            runAsGroup: 1001
            runAsNonRoot: true
            readOnlyRootFilesystem: true
          env:
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: falcon-api-secret
                  key: API_KEY
```

Health probes were added to promote availability and safe restarts:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8000
readinessProbe:
  httpGet:
    path: /healthz
    port: 8000
```

RBAC enforcement:

```yaml
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch"]
```

---

## CI/CD Pipeline with GitHub Actions

The GitHub Actions workflow performs:

- Trivy scan to detect CRITICAL/HIGH CVEs
- Fail build on CVEs using `exit-code: 1`
- Metadata tagging and `docker/build-push-action`
- Dockerfile linting via Hadolint
- Secrets management via GitHub Actions secrets

This ensures security is embedded into every commit via continuous integration.

---

## Before and After Trivy Scan Output

Example before hardening (unscanned image):

```bash
Total: 11 (CRITICAL: 4, HIGH: 5, MEDIUM: 2)
```

After Dockerfile hardening, version pinning, and trimming OS layers:

```bash
Total: 0 (CRITICAL: 0, HIGH: 0, MEDIUM: 0)
```

This demonstrates how proper base image selection, minimal dependencies, and Trivy-in-the-loop reduced attack surface.

📦 Docker Hub Image: [zermann/falcon-api](https://hub.docker.com/repository/docker/zermann/falcon-api)

---

## Decisions and Justifications

| Decision                        | Justification                                                       |
| ------------------------------- | ------------------------------------------------------------------- |
| `python:3.11.12-slim` base      | Minimized attack surface and reduced image size                     |
| Non-root execution              | Enforces principle of least privilege across environments           |
| Read-only filesystem            | Prevents runtime modification, improves immutability                |
| Kubernetes probes               | Ensures proper lifecycle management and container health monitoring |
| RBAC + SA + namespace isolation | Reduces blast radius and enforces boundaries                        |
| GitHub Actions CVE scan         | Detects vulnerabilities before they’re shipped                      |
| Secrets via env vars            | Avoids leaking secrets via image layers or codebase                 |
| 3 replicas                      | Promotes fault tolerance and pod rescheduling resilience            |

---

## Running the Project Locally

```bash
# Build and tag securely
docker build -t falcon-api:v1 .

# Start Minikube
minikube start

# Apply manifests
kubectl apply -f k8s/

# Port-forward
kubectl port-forward svc/falcon-api-service 8000:8000 -n falcon
```

Then navigate to: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## Future Improvements

- ✅ [PodSecurityAdmission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- ✅ [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- ✅ [Signed container image verification (e.g. Cosign)](https://forums.docker.com/t/verifying-signatures-of-images-signed-by-cosign/136928)

These are listed in `SECURITY.md` with the purpose of implementing the thought patterns expected from a cloud security-conscious engineering. For full details on threat model, justification for each layer, and advanced DevSecOps protections, see: [Hardened Kubernetes & Docker Deployment for Falcon API](./SECURITY.md)

---
