# 04 — SSN persisted to the Caches directory

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1
**Severity:** High · **Target:** PocketVault 1.0

## Summary
The user's SSN is written to `Library/Caches/profile_scratch.json` (and a debug
copy to `tmp/`) with no file protection. Caches persist across launches and are
captured in backups.

## Discovery
### Static
`Storage/InsecureStore.swift` → `cacheProfileScratch`, `writeDebugDump`.
### Dynamic (Kali)
```bash
find ./backup -name 'profile_scratch.json' -exec cat {} \;
# {"ssn":"078-05-1120","written":"2026-..."}
```

## Impact
PII (SSN) recoverable at rest from a directory developers wrongly assume is
ephemeral.

## Remediation
Don't persist PII to Caches/tmp. If short-lived caching is required, use
`NSFileProtectionComplete` and purge on logout/background.

## Evidence
_(attach: recovered JSON)_
