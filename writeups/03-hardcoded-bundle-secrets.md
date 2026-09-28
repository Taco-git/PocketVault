# 03 — Hardcoded API key / HMAC secret in the app bundle

**Category:** OWASP Mobile M9 / M1 · MASVS-STORAGE-2
**Severity:** High · **Target:** PocketVault 1.0

## Summary
`Config.plist` (API key, API base URL, HMAC signing secret) is compiled into the
app bundle. An `.ipa` is just a zip, so the file ships in the clear — no device
required to extract it.

## Discovery
### Static
`Resources/Config.plist`, read by `Storage/ConfigLoader.swift`.
### Dynamic (Kali)
```bash
unzip -o PocketVault-unsigned.ipa -d extracted >/dev/null
plistutil -i "extracted/Payload/PocketVault.app/Config.plist" -o -
```
Recovered:
```xml
<key>API_BASE</key>   <string>http://api.pocketvault.example/v1</string>
<key>API_KEY</key>    <string>sk_live_51TAcoG1tPocketVaultDEMOkey0000deadbeef</string>
<key>HMAC_SECRET</key><string>super-secret-signing-key-do-not-ship</string>
```

## Impact
Anyone with the IPA obtains the backend API key and HMAC secret → can forge
signed requests / impersonate the client. Secrets in the bundle are not secret.

## Remediation
Keep no long-lived secrets in the bundle; fetch short-lived, per-session tokens
at runtime after authentication. Rotate anything ever shipped.

## Evidence
`plistutil` output above (also visible via `strings` on the app binary),
captured 2026-09-28.
