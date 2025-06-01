# 🛡️ Docker Security Falcon – Kubernetes Phase

This project extends [Phase 1](https://github.com/JThomas404/docker-security-falcon), a secure, Trivy-scanned FastAPI app containerised with Docker. In **Phase 2**, we deploy the container to a Kubernetes cluster using best practices for security, scalability, and CI/CD automation.

---

## 📌 Purpose

Demonstrate a complete DevSecOps deployment pipeline with:
- Multi-stage Docker builds
- Non-root containers with hardened settings
- Kubernetes manifests with resource limits and health probes
- GitHub Actions CI/CD
- Secrets management via Kubernetes
- Cost-efficient, local development with `kind`

---

## 📁 Project Structure

```

docker-security-falcon-k8s/
├── app/                  # FastAPI app code
├── k8s/                  # Kubernetes manifests (deployment, service)
├── scripts/              # Optional helper scripts
├── Dockerfile            # Secure multi-stage build
├── requirements.txt      # Python dependencies
├── .github/workflows/    # GitHub Actions CI
├── .gitignore
├── README.md
└── SECURITY.md

````

---

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/JThomas404/docker-security-falcon-k8s.git
cd docker-security-falcon-k8s

# Build the Docker image
docker build -t falcon-api .

# Run locally
docker run -p 8000:8000 falcon-api
````

---

## 📦 Stack

* **FastAPI** – Lightweight Python web framework
* **Docker** – Containerisation
* **Trivy** – CVE scanning in CI
* **Kubernetes (kind)** – Local demo cluster
* **GitHub Actions** – CI/CD automation
* **K8s Secrets + env** – Secure config management

---

## 🔒 Security Practices

* Multi-stage Docker build with pinned base image
* Runs as non-root with `readOnlyRootFilesystem`
* K8s probes (`livenessProbe`, `readinessProbe`)
* No secrets stored in code or image

---