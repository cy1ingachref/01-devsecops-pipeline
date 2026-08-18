# GUIDE — 01 DevSecOps Security Pipeline (step by step, code by code)

This guide walks you through EVERY file in this project and explains what it
does and how to build/run it. Read top to bottom once, then use it as reference.

────────────────────────────────────────────────────────────────────────────
STEP 1 — Understand the architecture
────────────────────────────────────────────────────────────────────────────
On every push/PR to `main`, GitHub spins up a Linux runner and runs 4 security
scanners + a dashboard builder. The result:
  - shows on the Actions tab (pass/fail per control)
  - renders a `security-report.md` dashboard in the run summary
  - uploads detailed artifacts (trivy-fs.txt, tfsec.md)

The flow:
   code ──► checkout ──► gitleaks ──► semgrep ──► trivy ──► tfsec ──► dashboard

────────────────────────────────────────────────────────────────────────────
STEP 2 — The workflow file (.github/workflows/security.yml)
────────────────────────────────────────────────────────────────────────────
Read that file. Key parts:
  - `on:` triggers the workflow on push/PR to main.
  - `jobs.security.steps` is an ordered list of actions.
  - Each scanner uses a prebuilt GitHub Action (gitleaks-action, semgrep-action,
    trivy-action, tfsec-action). You don't reimplement scanners; you ORCHESTRATE
    them — that's exactly the DevSecOps job.
  - `continue-on-error: true` keeps the dashboard building even if a scan finds
    issues (we report, we don't hard-fail the demo; in prod you'd set exit-code).
  - The "Build security dashboard" step writes Markdown and appends it to
    `$GITHUB_STEP_SUMMARY` (the run summary tab).
  - The "Upload reports" step saves artifacts via actions/upload-artifact.

To ADAPT for your own SaaS: replace `app/` with your real code and point the
scanners at it. Same pipeline, zero rewrites.

────────────────────────────────────────────────────────────────────────────
STEP 3 — Secret scanning config (.gitleaks.toml)
────────────────────────────────────────────────────────────────────────────
gitleaks uses regex + entropy to find secrets. `useDefault = true` turns on the
built-in rules (AWS, GitHub, JWT, RSA, generic API keys). We ADD two custom
rules: one for a hardcoded JWT signing secret, one for hardcoded passwords.
The `[[rules]]` block:
  - `id`          unique name
  - `regex`       the pattern to match (note `(?i)` = case-insensitive)
  - `entropy`     minimum Shannon entropy to reduce false positives
  - `keywords`    tokens that must appear (speeds up scanning)
The `[allowlist]` stops gitleaks from flagging the config files themselves.

────────────────────────────────────────────────────────────────────────────
STEP 4 — SAST config (.semgrep.yml)
────────────────────────────────────────────────────────────────────────────
Semgrep matches CODE PATTERNS, not just text. We encode three real findings:
  1) jwt-string-equality-check — flags `if token == X` (the broken verification
     pattern from E-Tafakna). Real JWT libs verify the SIGNATURE, not a string.
  2) dangerous-eval-of-input — flags `eval(user_input)` (RCE risk).
  3) sql-concatenation — flags `"SELECT ..." + x` (SQL injection).
Each rule has: id, severity (ERROR/WARNING/INFO), languages, message, pattern.
`pattern-either` lets one rule match several shapes of the same mistake.

────────────────────────────────────────────────────────────────────────────
STEP 5 — The sample vulnerable app (app/main.py, app/eval_demo.py)
────────────────────────────────────────────────────────────────────────────
These exist ONLY so the pipeline has real findings to surface. They contain:
  - a hardcoded `JWT_SECRET` (gitleaks will catch it)
  - an `eval()` of input in eval_demo.py (semgrep will catch it)
  - a broken `verify_token` using `==` instead of signature check (semgrep)
You do NOT run this app to prove the pipeline; you push the repo and let CI run.
(If you DO run it, just `pip install fastapi uvicorn` then `uvicorn app.main:app`.)

────────────────────────────────────────────────────────────────────────────
STEP 6 — IaC example (infra/main.tf)
────────────────────────────────────────────────────────────────────────────
Terraform defining an S3 bucket + IAM policy, left INSECURE on purpose so
tfsec flags: missing encryption, public access, wildcard IAM. This proves the
IaC gate works. In real life you'd add `server_side_encryption_configuration`,
`block_public_acls = true`, and least-privilege IAM.

────────────────────────────────────────────────────────────────────────────
STEP 7 — Run it
────────────────────────────────────────────────────────────────────────────
Option A (recommended, zero local setup):
  1. Create a GitHub repo, push this folder.
  2. Go to the "Actions" tab. The "Security Pipeline" runs automatically.
  3. Click the run → see each scan + the dashboard in "Summary".

Option B (run each scanner locally with Docker, Linux/Git-Bash):
  docker run --rm -v "$PWD:/pwd" zricethezav/gitleaks:latest detect --source=/pwd -c .gitleaks.toml
  docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan --config auto --config .semgrep.yml /src
  docker run --rm -v "$PWD:/work" aquasec/trivy:latest fs /work
  docker run --rm -v "$PWD:/src" aquasec/tfsec:latest /src

────────────────────────────────────────────────────────────────────────────
STEP 8 — What to write on your CV / LinkedIn
────────────────────────────────────────────────────────────────────────────
"Built a CI/CD security gate (GitHub Actions) running SAST (Semgrep), secret
scanning (gitleaks), dependency/container CVE scanning (Trivy), and Terraform
IaC scanning (tfsec) on every commit, with an auto-generated Markdown security
dashboard. Encoded real pentest findings (e.g. broken JWT verification, hardcoded
secrets) as automated, enforceable rules."

That sentence tells a hiring manager: "this candidate stops the bugs I found
from ever reaching production." That is what gets you hired.
