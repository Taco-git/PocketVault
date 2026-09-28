# 06 — Cleartext backgrounding snapshot of the balance screen

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1
**Severity:** Medium · **Target:** PocketVault 1.0

## Summary
iOS snapshots the current UI when an app backgrounds, to power the app switcher.
PocketVault never covers its UI, so a clear image of the balance/card screen is
written to `Library/Caches/Snapshots/…` and persists.

## Discovery
### Static
`PocketVaultApp.swift` — no `scenePhase` privacy overlay (documented in comment).
### Dynamic (Kali)
```bash
find ./backup -path '*Snapshots*' -name '*.ktx' -o -name '*.jpeg'
# render/convert and view: balance + masked card visible in the clear
```

## Impact
Financial data leaks to disk via the switcher cache — visible to anyone with
device/backup access, no interaction with the app required.

## Remediation
On `scenePhase == .inactive/.background`, overlay a blank/blur view (or set a
privacy window) so the cached snapshot contains no sensitive data.

## Evidence
_(attach: recovered snapshot image)_
