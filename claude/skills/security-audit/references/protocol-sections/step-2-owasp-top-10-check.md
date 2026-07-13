## Step 2 — OWASP Top 10 Check

Systematically check for each category:

### A01: Broken Access Control
- Are auth/authz checks present on every endpoint that needs them?
- Can a user access or modify another user's resources? (IDOR)
- Are permission checks at the data layer, not just the UI?
- Can API endpoints be called directly, bypassing UI-level guards?

### A02: Cryptographic Failures
- Is sensitive data encrypted at rest and in transit?
- Are there hardcoded secrets, API keys, or credentials?
- Is password hashing using a strong algorithm (bcrypt, argon2)?
- Are TLS configurations current?

### A03: Injection
- SQL injection: Are queries parameterized? Any string concatenation in queries?
- XSS: Is user input sanitized before rendering? Are CSP headers set?
- Command injection: Is user input ever passed to shell commands?
- Template injection: Are template engines used safely?

### A04: Insecure Design
- Are there rate limits on sensitive operations (login, password reset, API)?
- Are business logic flows validated server-side (not just client)?
- Are there anti-automation measures where needed?

### A05: Security Misconfiguration
- Are debug modes, verbose errors, or stack traces exposed in production?
- Are default credentials or configurations in use?
- Are CORS policies appropriate (not wildcard)?
- Are security headers set (CSP, X-Frame-Options, HSTS)?

### A06: Vulnerable Components
- Check dependency files (mix.lock, package-lock.json, requirements.txt, etc.)
- Spawn **docs-researcher** to check for known CVEs in dependencies
- Are dependencies pinned to specific versions?
- Are there outdated packages with known vulnerabilities?

### A07: Authentication Failures
- Are sessions managed securely? (httpOnly, secure, SameSite cookies)
- Is session fixation possible?
- Are password policies enforced?
- Is MFA available for sensitive operations?

### A08: Data Integrity Failures
- Are deserialized objects validated?
- Are CI/CD pipelines secured against tampering?
- Are software updates verified (signatures, checksums)?

### A09: Logging & Monitoring Failures
- Are security events logged (failed logins, permission denials, input validation failures)?
- Is sensitive data excluded from logs (passwords, tokens, PII)?
- Are logs tamper-resistant?

### A10: SSRF
- Can user input influence server-side HTTP requests?
- Are internal service URLs accessible via user-controlled parameters?
- Are allowlists in place for external requests?
