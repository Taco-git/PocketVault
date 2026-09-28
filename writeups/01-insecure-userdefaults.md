# 01 — Session token, PIN & credentials in UserDefaults

**Category:** OWASP Mobile M9 (Insecure Data Storage) / MASVS-STORAGE-1
**Severity:** High
**Target:** PocketVault 1.0, installed bundle id `com.tacogit.pocketvault.N6QK377BQ8`

## Summary

On successful login PocketVault writes the session JWT, the user's 4-digit PIN,
and their username **and password** into `UserDefaults`. `UserDefaults` is an
unencrypted `.plist` inside the app sandbox with no file-protection guarantees,
so all of it is recoverable from the app container or a device backup.

## Discovery

### Static
`Storage/InsecureStore.swift` → `saveSessionToken`, `savePIN`,
`saveRememberedCredentials`, called from `SessionManager.login(...)`.

### Dynamic (Kali, no jailbreak)
Mounted the dev-signed app's container directly with `ifuse` (no full backup):
```bash
ifuse --container com.tacogit.pocketvault.N6QK377BQ8 ~/pentest/pv
plistutil -i ~/pentest/pv/Library/Preferences/com.tacogit.pocketvault.N6QK377BQ8.plist -o -
```
Recovered:
```xml
<key>session_token</key>
<string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.7B70FFC9-D44B-49E5-A9A0-D0A76C4873BA.sig</string>
<key>remember_me</key>
<dict>
    <key>u</key><string>Iseeyou</string>
    <key>p</key><string>trick</string>
</dict>
<key>user_pin</key><string>1998</string>
```

## Impact

Full account-takeover material at rest: a valid bearer token, the banking PIN,
and the cleartext password — all readable from the app's own `Library/Preferences`
plist, which is also carried into unencrypted backups.

## Remediation

- Never store passwords on device at all.
- Put the session token in the Keychain with
  `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- `UserDefaults` is for non-sensitive preferences only.

## Evidence
`plistutil` output above, captured 2026-09-28 from the mounted container.
