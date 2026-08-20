# 01 — DevSecOps Security Pipeline as Code

A production-oriented DevSecOps CI/CD security pipeline implemented with GitHub Actions. This repository demonstrates how to automatically enforce security checks on every commit using industry tools so teams catch secrets, insecure code, vulnerable dependencies, and unsafe infrastructure-as-code before merging.

Why this project matters

- Demonstrates end-to-end automation of security testing in CI/CD (high recruiter value).
- Shows practical integration of multiple scanners into a single workflow and a machine-readable findings dashboard.
- Includes a minimal vulnerable sample application so you can observe the pipeline catching real issues.

Key components

- GitHub Actions workflow that runs on push and pull request
  - gitleaks — secret scanning
  - Semgrep — static application security testing (SAST)
  - Trivy — filesystem and container image CVE scanning
  - tfsec — Terraform IaC scanning
  - Consolidated findings rendered as `security-report.md` in the run summary
- sample app/ — intentionally lightly vulnerable sample application used for demos
- Per-tool configuration files (customize rules, allowlists, thresholds)

Quick start (cloud / GitHub)

1. Push this repository to a GitHub remote (or fork).
2. Open the repository’s Actions tab — workflows run automatically on push/PR.
3. Review the run summary and `security-report.md` artifact to see findings.

Run tools locally (Docker)

# gitleaks
docker run --rm -v "$PWD:/pwd" zricethezav/gitleaks:latest detect --source=/pwd -c .gitleaks.toml

# semgrep
docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan --config auto --config .semgrep.yml /src

# trivy (filesystem)
docker run --rm -v "$PWD:/work" aquasec/trivy:latest fs /work

# tfsec
docker run --rm -v "$PWD:/src" aquasec/tfsec:latest /src

Notes

- The sample app intentionally contains a hardcoded secret and an unsafe `eval` so the pipeline has demonstrable findings. In production, fix these issues; in demos, keep them to exercise the checks.
- See GUIDE.md for a line-by-line walkthrough of the workflow and configuration.
