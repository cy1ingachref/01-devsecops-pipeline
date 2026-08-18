# 01 — DevSecOps Security Pipeline as Code

**Hireability:** This is the single highest-leverage project in the portfolio.
Every company with a security team is hiring people who can wire security into
CI/CD. It proves you reduce risk *automatically on every commit*, not just when
someone manually runs a scan.

**The story:** During your authorized pentest internship at E-Tafakna (legal-tech
SaaS) you saw code shipped without automated checks. This repo is the pipeline
you'd bolt onto that SaaS so the exact bugs you found — weak secrets, vulnerable
dependencies, insecure IaC — get caught before merge.

## What this repo contains
- A fully working GitHub Actions workflow that runs on every push/PR:
  - **gitleaks** — secret scanning (catches hardcoded API keys / JWT secrets)
  - **Semgrep** — SAST (catches insecure code patterns)
  - **Trivy** — filesystem + container image scanning (CVEs in deps & base images)
  - **tfsec** — Terraform IaC scanning (catches insecure cloud config)
  - A **findings dashboard** generated as Markdown in the CI run summary
- A deliberately *lightly* vulnerable sample app (`app/`) so the pipeline has
  something real to catch (a hardcoded secret + an unsafe `eval` to show Semgrep).
- Per-tool config files you can tune.

## How to run it
1. Push this folder to a GitHub repo.
2. GitHub Actions runs automatically on push (no self-hosted runners needed).
3. Open the "Actions" tab → see each scan. Failed secrets/SAST show as red.
4. The run summary renders `security-report.md` as a dashboard.

To run the same tools locally (Linux/macOS/Git-Bash):
```
# gitleaks
docker run --rm -v "$PWD:/pwd" zricethezav/gitleaks:latest detect --source=/pwd -c .gitleaks.toml

# semgrep
docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan --config auto --config .semgrep.yml /src

# trivy fs
docker run --rm -v "$PWD:/work" aquasec/trivy:latest fs /work

# tfsec
docker run --rm -v "$PWD:/src" aquasec/tfsec:latest /src
```

> Note: the sample app intentionally contains a hardcoded secret and an `eval`.
> That is the POINT — it lets you demonstrate the pipeline catching real issues.
> In a real project you would fix them; here we keep them so the demo fires.

See `GUIDE.md` for a step-by-step walkthrough of every file and what each line does.
