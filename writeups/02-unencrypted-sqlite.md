# 02 — Full card number & CVV in an unencrypted SQLite database

**Category:** OWASP Mobile M9 (Insecure Data Storage) / MASVS-STORAGE-1
**Severity:** Critical
**Target:** PocketVault 1.0, `com.tacogit.pocketvault.N6QK377BQ8`

## Summary

Card data (full PAN, CVV, expiry) and the transaction history are stored in a
plain SQLite database at `Documents/vault.sqlite`, with no encryption and no
file-protection class. Storing a CVV at all is a PCI-DSS violation on its own.

## Discovery

### Static
`Storage/VaultDatabase.swift` → `path` (Documents/vault.sqlite), `insertCard`.

### Dynamic (Kali)
```bash
sqlite3 ~/pentest/pv/Documents/vault.sqlite '.tables'
# cards  transactions
sqlite3 ~/pentest/pv/Documents/vault.sqlite 'SELECT holder,pan,cvv,expiry FROM cards;'
# TACO TESTER|4539578763621486|451|11/28
sqlite3 ~/pentest/pv/Documents/vault.sqlite 'SELECT merchant,amount,memo FROM transactions;'
# Hudson Valley Coffee|-4.75|latte
# Payroll Deposit|2200.0|biweekly
# Steam|-59.99|game
# MTA Metro-North|-18.5|commute
```

## Impact

Cardholder data fully exposed at rest — a clone-able card (PAN + CVV + expiry),
plus a spending profile useful for social engineering.

## Remediation

- Never persist the CVV; tokenize the PAN.
- Encrypt the DB (SQLCipher) and/or set `NSFileProtectionComplete`.
- Keep card data off-device where the server/PSP can hold it instead.

## Evidence
`sqlite3` session output above, captured 2026-09-28.
