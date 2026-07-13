## Step 5 — Status Reporting

### During Monitoring
Brief updates at natural points:
```
[HH:MM] Pipeline #N — 5/8 jobs passed, 2 running (test_unit: 4m, test_integration: 7m), 1 queued
```

### On Failure Detection
```
[HH:MM] FAILED: job `test_unit` in workflow `build_and_test`
Failure: 2 tests failed in test/accounts/user_test.exs
- test_create_user_with_invalid_email (line 42): expected {:error, changeset}, got {:ok, user}
- test_update_user_permissions (line 87): ** (MatchError) no match of right hand side value
Diagnosing...
```

### On Fix Applied
```
[HH:MM] Fix pushed (abc1234): Fix email validation in User changeset
New pipeline triggered — resuming monitoring...
```

### On Completion
```
