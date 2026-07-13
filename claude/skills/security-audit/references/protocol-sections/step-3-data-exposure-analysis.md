## Step 3 — Data Exposure Analysis

Trace sensitive data (PII, credentials, tokens, financial data) through the system:
- Where does it enter?
- Where is it stored?
- Where is it logged? (should it be?)
- Where does it exit? (API responses, error messages, emails)
- Who can access it? (roles, permissions)
- Is it ever exposed in URLs, query parameters, or client-side code?
