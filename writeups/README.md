# PocketVault writeups — M9: Insecure Data Storage

Each finding is written up the way I do my HTB boxes: **what it is → how I found
it (static + dynamic) → impact → remediation**, with the exact commands used.
All recovery is done from **Kali**, no jailbreak, against a device I own running
in Developer Mode. The app was built on a GitHub Actions macOS runner and
sideloaded from Linux with Sideloader — no Mac involved.

## The recovery toolkit (Kali)

```bash
sudo apt install libimobiledevice-utils ideviceinstaller ifuse sqlite3 libplist-utils

ideviceinfo | head                      # confirm the device is paired
idevicepair pair                        # (accept the trust prompt on the phone)

# find the installed bundle id (free-signing appends a team suffix)
ideviceinstaller list --all | grep -i pocket
# com.tacogit.pocketvault.N6QK377BQ8, "1.0", "PocketVault"

# mount the dev-signed app's sandbox directly — no full-device backup needed
mkdir -p ~/pentest/pv
ifuse --container com.tacogit.pocketvault.N6QK377BQ8 ~/pentest/pv
```

Mounting the container beats a full `idevicebackup2` here: it exposes
`Documents/`, `Library/` and `tmp/` for a dev-signed app in seconds and pulls
nothing else off the phone.

## Findings index

| # | Finding | Status |
|---|---------|--------|
| 01 | Session token, PIN & credentials in UserDefaults | ✅ recovered |
| 02 | Full card number & CVV in unencrypted SQLite | ✅ recovered |
| 03 | Hardcoded API key / HMAC secret in the app bundle | ✅ recovered |
| 04 | SSN persisted to the Caches directory | ✅ recovered |
| 05 | Keychain item accessible when locked & backed up | 🟨 static + build-time confirmed; dynamic extraction TODO |
| 06 | Cleartext backgrounding snapshot of the balance screen | ✅ proven (Apple "AAPL" container) |
| 07 | Sensitive data sent to logs / os_log redaction | ✅ characterized on modern iOS |

## Notes worth keeping (real-device reality vs the naive expectation)

- **Bundle id changed:** free-signing installed the app as
  `com.tacogit.pocketvault.N6QK377BQ8`, so the on-disk plist is named with that
  suffix too.
- **Snapshots moved:** app-switcher snapshots live under
  `Library/SplashBoard/Snapshots/`, and are Apple's proprietary `AAPL` container,
  not standard Khronos KTX.
- **Log redaction:** modern iOS redacts dynamic `os_log`/`NSLog` args to
  `<private>`, so the token does **not** appear in plaintext in `idevicesyslog`;
  the real leak vector is `print()` to stdout and any `%{public}@` misuse.
