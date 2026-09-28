# 01 — Session token, PIN & credentials in UserDefaults

**Category:** OWASP Mobile M9 (Insecure Data Storage) / MASVS-STORAGE-1
**Severity:** High
**Target:** PocketVault 1.0, `com.tacogit.pocketvault`

## Summary

On successful login PocketVault writes the session JWT, the user's 4-digit PIN,
and their username **and password** into `UserDefaults`. `UserDefaults` is an
unencrypted `.plist` inside the app sandbox with no file-protection guarantees,
so all of it is recoverable from a normal (even unencrypted) device backup.

## Discovery

### Static
`Storage/InsecureStore.swift` → `saveSessionToken`, `savePIN`,
`saveRememberedCredentials`, called from `SessionManager.login(...)`.

### Dynamic (Kali, no jailbreak)
```bash
# after idevicebackup2 pulled a backup, or via Xcode "Download Container"
plistutil -i com.tacogit.pocketvault.plist -o -
```
```xml
<key>session_token</key><string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9. ...</string>
<key>user_pin</key><string>1998</string>
<key>remember_me</key><dict><key>u</key><string>taco</string>
                            <key>p</key><string>hunter2</string></dict>
```

## Impact

Full account-takeover material at rest: a valid bearer token, the banking PIN
(reused elsewhere), and the cleartext password. Any process/tooling with backup
access reads it offline.

## Remediation

- Never store passwords on device at all.
- Put the session token in the Keychain with
  `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- `UserDefaults` is for non-sensitive preferences only.

## Evidence

_(attach: `plistutil` output, screenshot of the plist in a viewer)_
