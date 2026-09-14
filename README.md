# 01 — DevSecOps Security Pipeline as Code

A production-oriented DevSecOps CI/CD security pipeline implemented with GitHub Actions. This repository demonstrates how to automatically enforce security checks on every commit using industry-standard tools — catching secrets, insecure code, vulnerable dependencies, and unsafe infrastructure-as-code before merging.

## What it does

- **Secret scanning** — gitleaks detects hardcoded credentials, tokens, and API keys
- **Static analysis** — Semgrep identifies insecure code patterns and OWASP vulnerabilities
- **Container scanning** — Trivy finds CVEs in filesystem and container images
- **IaC scanning** — tfsec flags misconfigurations in Terraform code
- **Consolidated reporting** — All findings rendered into a machine-readable `security-report.md`

## Why it matters

Security scanning is only valuable when it's automated and enforced. This pipeline runs on every push and pull request, ensuring no vulnerable code reaches production accidentally. The consolidated dashboard gives security teams a single view of all findings across tools.

## Quick start

```bash
# Push to GitHub — workflows run automatically
git push origin main

# Or run tools locally with Docker
docker run --rm -v "$PWD:/pwd" zricethezav/gitleaks:latest detect --source /pwd
```

## Requirements

- GitHub account (for Actions)
- Docker (for local tool testing)

## License

MIT
