# 05 — Keychain item accessible when locked & migrated to backups

**Category:** OWASP Mobile M9 · MASVS-STORAGE-1/2
**Severity:** Medium · **Target:** PocketVault 1.0

## Summary
The auth token is stored in the Keychain — correct location — but with
`kSecAttrAccessibleAlways`. It's readable while the device is locked and, lacking
`ThisDeviceOnly`, is copied into iTunes/Finder backups where it can be extracted
offline.

## Discovery
### Static
`Storage/KeychainHelper.swift` → `saveInsecurely` (`kSecAttrAccessible` =
`kSecAttrAccessibleAlways`).
### Dynamic
Restore the backup keychain and read the generic-password item, or observe the
attribute via a Keychain dumper on a device you control.

## Impact
Defeats the point of using the Keychain: the token survives lock state and
backup extraction.

## Remediation
Use `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. `AccessibleAlways` is
deprecated by Apple precisely for this reason.

## Evidence
_(attach: keychain attribute dump)_
