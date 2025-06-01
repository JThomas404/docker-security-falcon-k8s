# **Hardened Kubernetes & Docker Deployment for Falcon API**

This document outlines the security design, hardening practices, and CI/CD protections implemented in the **Docker Container Security Falcon** project. The project was created to follow security-first principles in Docker, Kubernetes, and GitHub Actions workflows.

---

## Threat Model & Objectives

This project assumes:

- Public-facing APIs must be protected against unauthorized access.
- Container and cluster compromise should be minimized.
- Supply chain and CI/CD attacks must be proactively addressed.

Security objectives:

- Enforce non-root, minimal base image usage.
- Prevent secret leakage.
- Maintain immutability and runtime restrictions.
- Secure CI pipelines to catch and block known CVEs.

---

## Container Hardening

| Technique                 | Implementation Detail                                                   |
| ------------------------- | ----------------------------------------------------------------------- |
| **Minimal Base Image**    | `python:3.11.12-slim` with pinned SHA digest                            |
| **Non-root User**         | Custom `pyuser:pygroup` (UID\:GID `1001`) with `USER pyuser`            |
| **Read-only Filesystem**  | `readOnlyRootFilesystem: true`                                          |
| **Strict File Ownership** | `chown -R pyuser:pygroup /app` with explicit UID mapping in Dockerfile  |
| **No Package Cache**      | `pip install --no-cache-dir` to avoid layer bloat and leftover metadata |

---

## Kubernetes Runtime Security

| Technique                    | Implementation Detail                                            |
| ---------------------------- | ---------------------------------------------------------------- |
| **runAsNonRoot Enforcement** | UID/GID 1001 assigned and verified in pod `securityContext`      |
| **Probes Enabled**           | `/healthz` endpoint used in both liveness and readiness probes   |
| **ClusterIP Service**        | Internal service exposes only required port, no external access  |
| **Namespace Isolation**      | All resources deployed under dedicated `falcon` namespace        |
| **RBAC Enforcement**         | ServiceAccount used with least privilege permissions             |
| **Secrets Management**       | `Opaque` secrets mounted as environment variables via Kubernetes |

---

## GitHub Actions Security

| Protection                  | Configuration Detail                                                            |
| --------------------------- | ------------------------------------------------------------------------------- |
| **Trivy CVE Scanning**      | Runs on every `push` and `pull_request` to detect CRITICAL/HIGH vulnerabilities |
| **Build Fails on CVEs**     | Pipeline stops if any CRITICAL/HIGH CVEs are detected                           |
| **Metadata Labelling**      | Automated tagging and labeling using Docker metadata-action                     |
| **Secure Secrets Handling** | DockerHub credentials stored in GitHub Actions secrets                          |

---

## Security Architecture Justification

Each security layer in this project was deliberately chosen to reflect modern DevSecOps principles:

| Layer                   | Decision                                     | Justification                                                               |
| ----------------------- | -------------------------------------------- | --------------------------------------------------------------------------- |
| **Base Image**          | `python:3.11.12-slim`                        | Reduces unnecessary packages, shrinking the attack surface                  |
| **User Context**        | UID/GID `1001`, no root                      | Enforces non-root execution across Docker and Kubernetes                    |
| **Filesystem Access**   | `readOnlyRootFilesystem: true`               | Prevents tampering or malware from modifying the container at runtime       |
| **Secrets**             | Kubernetes secrets via `env` injection       | Prevents hardcoded secrets and keeps secrets out of images and codebase     |
| **Probes**              | `/healthz` liveness and readiness checks     | Enables early detection of unresponsive or failing containers               |
| **RBAC**                | Role scoped to `get`, `list`, `watch`        | Follows least privilege—containers can read secrets but not modify anything |
| **CI/CD Security**      | Trivy in GitHub Actions, build fail on CVEs  | Shifts security left and stops vulnerable images before reaching production |
| **Namespace Isolation** | All resources deployed to `falcon` namespace | Prevents cross-namespace lateral movement and isolates risk                 |

---

## Future Enhancements

The following security features are recommended for future improvements:

| Feature                        | Benefit                                                               |
| ------------------------------ | --------------------------------------------------------------------- |
| **PodSecurityAdmission (PSA)** | Enforce cluster-wide security policies for pod-level isolation        |
| **NetworkPolicies**            | Segment internal traffic and restrict communication between pods      |
| **Signed Container Images**    | Validate container integrity and prevent unauthorized image tampering |

These would elevate this project to enterprise-grade security maturity.

---

## Conclusion

This project reflects a production-aware security mindset. Every configuration—from user context and filesystem immutability to CVE scanning and Kubernetes probes—was designed with the principle of **“least privilege and maximum visibility.”**

By integrating these patterns and enhancements into a CI/CD-enabled container lifecycle, this project shows how modern cloud-native workloads can be deployed securely, monitored effectively, and hardened against compromise from build to runtime.

See the initial phase and Docker implementation: [Docker Container Security Falcon (Phase 1)](https://github.com/JThomas404/docker-security-falcon)

---
