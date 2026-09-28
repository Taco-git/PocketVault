# PocketVault writeups — M9: Insecure Data Storage

Each finding is written up the way I do my HTB boxes: **what it is → how I found
it (static + dynamic) → impact → remediation**, with the exact commands used.
All recovery is done from **Kali**, no jailbreak, against a device I own running
in Developer Mode.

## The recovery toolkit (Kali)

```bash
# libimobiledevice — talks to the device over USB
sudo apt install libimobiledevice-utils ideviceinstaller sqlite3 libplist-utils

ideviceinfo                       # confirm the device is paired
idevicepair pair                  # (accept the trust prompt on the phone)

# Option A: pull an unencrypted backup of the whole device
mkdir backup && idevicebackup2 backup --full ./backup

# Option B: list installed apps and target ours
ideviceinstaller -l | grep -i pocketvault

# Watch secrets stream by in the unified log while you use the app
idevicesyslog | grep -i pocketvault
```

Backups land as hashed filenames; `idevicebackup2 unback` (or a tool like
`iBackup Viewer` / `libimobiledevice`'s manifest) maps them back to real paths
under the app's container.

## Findings index

| # | Finding | Status |
|---|---------|--------|
| 01 | Session token, PIN & credentials in UserDefaults | ☐ draft |
| 02 | Full card number & CVV in unencrypted SQLite | ☐ draft |
| 03 | Hardcoded API key / HMAC secret in the app bundle | ☐ draft |
| 04 | SSN persisted to the Caches directory | ☐ draft |
| 05 | Keychain item accessible when locked & backed up | ☐ draft |
| 06 | Cleartext backgrounding snapshot of the balance screen | ☐ draft |
| 07 | Auth token leaked to the unified log | ☐ draft |
