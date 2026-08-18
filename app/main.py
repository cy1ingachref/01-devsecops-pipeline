"""
app/main.py — A DELIBERATELY lightly-vulnerable sample service.

WHY THIS EXISTS:
  The DevSecOps pipeline needs something REAL to catch so the demo actually
  fires. This file intentionally contains:
    1) a hardcoded JWT signing secret  -> caught by gitleaks
    2) an eval() of request input      -> caught by semgrep (dangerous-eval-of-input)

In a REAL project you would fix these. For this portfolio repo we KEEP them so
you can show the pipeline working end to end. Do NOT copy these patterns into
production code.

To run locally (after `pip install fastapi uvicorn`):
    uvicorn app.main:app --reload
"""

import eval_demo  # noqa: F401  (kept to show semgrep catching eval in another module)

# INTENTIONALLY INSECURE — a hardcoded HMAC secret.
# gitleaks rule "jwt-hardcoded-secret" will flag this line.
JWT_SECRET = "supersecretproductionkey_do_not_do_this"

def build_token(user_id: str) -> str:
    # In a real app you'd sign with the secret above using PyJWT.
    # Here we just return a fake token string to keep the demo dependency-free.
    return f"fake.jwt.for.{user_id}"

def verify_token(token: str) -> bool:
    # INTENTIONALLY BROKEN — string equality is NOT signature verification.
    # semgrep rule "jwt-string-equality-check" flags this pattern.
    expected = build_token("admin")
    if token == expected:
        return True
    return False
