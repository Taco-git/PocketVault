# 03 — Hardcoded API key / HMAC secret in the app bundle

**Category:** OWASP Mobile M9 / M1 · MASVS-STORAGE-2
**Severity:** High · **Target:** PocketVault 1.0

## Summary
`Config.plist` (API key, API base URL, HMAC signing secret) is compiled into the
app bundle. An `.ipa` is just a zip, so the file ships in the clear.

## Discovery
### Static
`Resources/Config.plist`, read by `Storage/ConfigLoader.swift`.
### Dynamic (Kali)
```bash
unzip -o PocketVault-unsigned.ipa -d extracted
cat extracted/Payload/PocketVault.app/Config.plist
strings -a extracted/Payload/PocketVault.app/PocketVault | grep -iE 'sk_live|secret|api'
```

## Impact
Anyone with the IPA obtains the backend API key and HMAC secret → can forge
signed requests / impersonate the client.

## Remediation
Keep no long-lived secrets in the bundle; fetch short-lived, per-session tokens
at runtime after authentication. Rotate anything ever shipped.

## Evidence
_(attach: unzip + strings output)_
