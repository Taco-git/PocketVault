# 06 — Cleartext backgrounding snapshot of the balance screen

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1
**Severity:** Medium · **Target:** PocketVault 1.0

## Summary
iOS snapshots an app's UI when it backgrounds, to power the app switcher.
PocketVault never covers its UI on backgrounding, so a rendered image of the
balance/card screen is written to disk under `Library/SplashBoard/Snapshots/`
and persists.

## Discovery
### Static
`PocketVaultApp.swift` — no `scenePhase` privacy overlay (documented in comment).

### Dynamic (Kali, no jailbreak)
Mounted the app container with `ifuse --container <bundleid>`, then:
```bash
find ~/pentest/pv/Library/SplashBoard/Snapshots -name '*.ktx' -exec ls -la {} \;
# 3981336 bytes  ... B5345412-...@3x.ktx           (full-res, first background)
# 2113560 bytes  ... downscaled/8CEB1A25-...@3x.ktx (downscaled copy)
xxd <snapshot>.ktx | head -3
# 00000000: 4141 504c 0d0a 1a0a 5400 0000 4845 4144  AAPL....T...HEAD
```
Note: despite the `.ktx` extension these are **Apple's proprietary "AAPL"
snapshot container** (magic `41 41 50 4C 0D 0A 1A 0A`, `HEAD` chunk), not a
standard Khronos KTX — a stock KTX decoder will not open them. Rendering to a
viewable image requires parsing Apple's wrapper; the finding is proven by the
presence, header, and size of the captures without rendering.

## Impact
Financial data leaks to disk via the switcher cache — a full-resolution image of
the account screen, readable by anyone with container/backup access, with no
interaction required after the app is backgrounded.

## Remediation
On `scenePhase == .inactive/.background`, overlay a blank/blur view (or set a
privacy window) so the cached snapshot contains no sensitive data.

## Evidence
- Directory listing showing two snapshots (full-res + downscaled) with timestamps.
- `xxd` header showing the `AAPL` magic.
