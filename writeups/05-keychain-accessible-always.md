# 05 — Keychain item accessible when locked & migrated to backups

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1/2
**Severity:** Medium · **Target:** PocketVault 1.0

## Summary
The auth token is stored in the Keychain — the correct location — but with
`kSecAttrAccessibleAlways`. It is readable while the device is locked and, because
the accessibility class is not `...ThisDeviceOnly`, is copied into iTunes/Finder
backups where it can be extracted offline. `AccessibleAlways` was deprecated by
Apple precisely because it defeats the Keychain's at-rest protections.

## Discovery
### Static
`Storage/KeychainHelper.swift` → `saveInsecurely`
(`kSecAttrAccessible = kSecAttrAccessibleAlways`).

### Build-time confirmation
The insecure attribute is confirmed by the compiler itself — the CI build emitted:
```
KeychainHelper.swift:26:43: warning: 'kSecAttrAccessibleAlways' was deprecated in
iOS 12.0: Use an accessibility level that provides some user protection, such as
kSecAttrAccessibleAfterFirstUnlock
```

### Dynamic (not yet performed — method)
Unlike the file-based findings, Keychain items are **not** exposed through the
`ifuse` container mount. Extraction requires an **encrypted** backup plus a
keychain parser:
```bash
idevicebackup2 encryption on <password> ~/pentest/kc
idevicebackup2 backup ~/pentest/kc
# then parse the backup Keychain (e.g. with a keychain-dumper against the
# encrypted backup) and read the item's kSecAttrAccessible value.
```
Planned as a follow-up; the static + build-time evidence already establishes the
misconfiguration.

## Impact
Defeats the point of using the Keychain: the token survives lock state and is
recoverable from backups on another machine.

## Remediation
Use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

## Evidence
- CI build deprecation warning (above).
- `KeychainHelper.saveInsecurely` source.
- Dynamic keychain extraction: TODO (encrypted-backup method noted above).
