# 04 — SSN persisted to the Caches directory

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1
**Severity:** High · **Target:** PocketVault 1.0

## Summary
The user's SSN is written to `Library/Caches/profile_scratch.json` with no file
protection. Caches persist across launches and are captured in backups — a
directory developers wrongly treat as ephemeral.

## Discovery
### Static
`Storage/InsecureStore.swift` → `cacheProfileScratch` (and `writeDebugDump` → tmp).
### Dynamic (Kali)
```bash
cat ~/pentest/pv/Library/Caches/profile_scratch.json
# {"written":"2026-09-28T08:35:39Z","ssn":"078-05-1120"}
```

## Impact
PII (SSN) recoverable at rest from the app container / a backup.

## Remediation
Don't persist PII to Caches/tmp. If short-lived caching is unavoidable, apply
`NSFileProtectionComplete` and purge on logout/background.

## Evidence
Recovered JSON above, captured 2026-09-28.
