# 07 — Sensitive data sent to logs (NSLog / print), and modern-iOS redaction

**Category:** OWASP Mobile M9 · MASVS-STORAGE-3
**Severity:** Low–Medium (context-dependent) · **Target:** PocketVault 1.0

## Summary
`SessionManager.login` and `ProfileView.onAppear` write auth context to the log
with `NSLog`, and `login` also does `print("DEBUG auth token issued: \(token)")`.
On a current iPhone the impact is more nuanced than "the token sits in the syslog":
iOS's unified logging **redacts dynamic `os_log`/`NSLog` arguments to `<private>`
by default**, so the token is masked in the live log stream — but `print()` to
stdout is **not** redacted, and any `%{public}@` usage would re-expose it.

## Discovery
### Static
`SessionManager.swift` (`NSLog` + `print` of the token), `Views/ProfileView.swift`.

### Dynamic (Kali, no jailbreak)
```bash
timeout 120 idevicesyslog > syslog.txt      # capture while logging in on the device
grep -c PocketVault syslog.txt              # 8774 lines from the app process
grep -i 'token=' syslog.txt | head
# PocketVault(TextInputUI)[978] <Notice>: Performing delayed generation for token=<private>
```
Observations:
- The app process emits thousands of framework log lines.
- Every dynamic `token=` value renders as `<private>` — os_log redaction.
- Our own `NSLog("[PocketVault] login success … token=%@")` did **not** surface in
  the `idevicesyslog` relay at all: default-level app os_log entries are not
  reliably carried by the live relay and instead land in a full `sysdiagnose`.

## Impact
- `NSLog` is the wrong API for sensitive data: it leaks message structure, timing,
  and any argument marked `%{public}`. Redaction is a default, not a guarantee.
- `print()` writes the token in cleartext to stdout — visible in the Xcode device
  console or to anyone attaching a debugger to the (dev-signed) app.
- A `sysdiagnose` bundle (routinely shared with vendor support) can still contain
  app log entries with sensitive context.

## Remediation
- Never log secrets. Use `os.Logger`, keep interpolated values private (the
  default), and never mark credential-shaped values `%{public}@`.
- Strip `print`/debug logging from Release builds.
- Treat application logs as a detection source (see SOC tie-in).

## Evidence
- `syslog.txt` excerpt showing `token=<private>` redaction (captured 2026-09-28).
- Source lines in `SessionManager.swift` / `ProfileView.swift`.

---
### SOC analyst tie-in
os_log redaction is defense-in-depth, not a control to rely on. A detection rule
should flag apps logging authentication context at all (`token`, `login success`,
`password` appearing in app log subsystems), and code review / CI should flag any
`%{public}` wrapping of credential-shaped values.
