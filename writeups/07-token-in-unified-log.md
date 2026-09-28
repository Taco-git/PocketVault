# 07 — Auth token leaked to the unified log

**Category:** OWASP Mobile M9 · MASVS-STORAGE-3
**Severity:** Medium · **Target:** PocketVault 1.0

## Summary
`SessionManager.login` and `ProfileView.onAppear` write the auth token and
sensitive context to the device log via `NSLog`/`print`. The unified log is
readable over USB with no jailbreak.

## Discovery
### Static
`SessionManager.swift` (`NSLog`/`print` of token), `Views/ProfileView.swift`.
### Dynamic (Kali)
```bash
idevicesyslog | grep -i pocketvault
# [PocketVault] login success user=taco token=eyJhbGciOi...
```

## Impact
Bearer token disclosed to anyone who can read the log (local tooling, some
diagnostic profiles, sysdiagnose bundles shared with support).

## Remediation
Never log secrets. Use `os.Logger` with `privacy: .private` (default for
interpolated values) and strip debug `print`s from Release builds.

## Evidence
_(attach: idevicesyslog capture)_

---

### SOC analyst tie-in
This finding is the bridge to the blue-team side: the same unified log that
leaks the token is a **detection source**. A companion note (`writeups/soc/`)
can cover writing a log query/Sigma-style rule that flags secrets appearing in
app logs — turning the vuln into a detection engineering exercise.
