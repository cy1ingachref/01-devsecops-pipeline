"""
app/eval_demo.py — companion module to main.py.

INTENTIONALLY INSECURE: passes user input straight into eval().
semgrep rule "dangerous-eval-of-input" will flag this.

This mirrors a real finding class (RCE via eval of untrusted input) that a
DevSecOps SAST gate should block before merge.
"""

def run_calc(expression: str):
    # NEVER do this with untrusted input.
    return eval(expression)  # noqa: S307  (flagged on purpose)
