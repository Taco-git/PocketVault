# 02 — Full card number & CVV in an unencrypted SQLite database

**Category:** OWASP Mobile M9 (Insecure Data Storage) / MASVS-STORAGE-1
**Severity:** Critical
**Target:** PocketVault 1.0, `com.tacogit.pocketvault`

## Summary

Card data (full PAN, CVV, expiry) and the transaction history are stored in a
plain SQLite database at `Documents/vault.sqlite`, with no encryption and no
file-protection class. Storing a CVV at all is a PCI-DSS violation on its own.

## Discovery

### Static
`Storage/VaultDatabase.swift` → `path` (Documents/vault.sqlite), `insertCard`.

### Dynamic (Kali)
```bash
# locate the DB inside the pulled container/backup, then:
sqlite3 vault.sqlite '.tables'
sqlite3 vault.sqlite 'SELECT holder,pan,cvv,expiry FROM cards;'
# TACO TESTER|4539578763621486|451|11/28
sqlite3 vault.sqlite 'SELECT merchant,amount FROM transactions;'
```

## Impact

Cardholder data fully exposed at rest — clone-able card, plus a spending profile
useful for social engineering.

## Remediation

- Never persist the CVV; tokenize the PAN.
- Encrypt the DB (SQLCipher) and/or set `NSFileProtectionComplete`.
- Keep secrets off-device where the server can hold them instead.

## Evidence

_(attach: `sqlite3` session output)_
