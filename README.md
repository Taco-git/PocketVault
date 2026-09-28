# PocketVault — an intentionally vulnerable iOS finance app

> **Educational security research project.** PocketVault is a deliberately
> insecure SwiftUI app that mishandles sensitive data in every way it shouldn't.
> It exists so the flaws can be **found, documented, and remediated** — the same
> role DVIA-v2, iGoat, and the OWASP MASTG test apps play. It contains **no real
> data** and must never be pointed at a real account.

Phase 1 focuses on **OWASP Mobile Top 10 — M9: Insecure Data Storage**
(equivalently MASVS-STORAGE). Seven distinct storage flaws are planted, then
recovered from the device with an all-Linux (Kali) toolchain — no jailbreak.

## Why this exists / what it demonstrates

- I can **build and ship an iOS app to a device without owning a Mac**, using a
  GitHub Actions macOS runner for the build and Sideloadly for install.
- I understand iOS's data-at-rest model: the sandbox, file protection classes,
  Keychain accessibility, backups, and where secrets leak.
- I can perform **static and dynamic recovery** of on-device data using
  `libimobiledevice`, `sqlite3`, `plistutil`, `strings`, and the unified log.

## Build → install → attack pipeline (no Mac)

```
 GitHub Actions (macOS runner)        Windows / Kali VM
 ─────────────────────────────        ───────────────────────────
 xcodegen generate                    download PocketVault-unsigned.ipa
 xcodebuild archive (unsigned)   ──►  Sideloadly  ──► iPhone (Developer Mode)
 zip Payload/ → .ipa artifact         idevicebackup2 / ideviceinstaller
                                      sqlite3 / plistutil / strings  ──► findings
```

1. **Build.** Push to `main` (or run the workflow by hand). The
   [`Build unsigned IPA`](.github/workflows/build.yml) workflow produces
   `PocketVault-unsigned.ipa` as a downloadable artifact.
2. **Install.** On Windows, sign+sideload the IPA with **Sideloadly** (or
   AltStore) using a free Apple ID. Trust the developer profile on the phone
   (Settings → General → VPN & Device Management), which Developer Mode allows.
3. **Attack.** From Kali, pull the app container / a device backup and dig out
   everything PocketVault leaked. See [`writeups/`](writeups/).

## The planted vulnerabilities (M9)

| # | Flaw | Where it lands on device |
|---|------|--------------------------|
| 1 | Session token, PIN & saved credentials in `UserDefaults` | `Library/Preferences/com.tacogit.pocketvault.plist` |
| 2 | Full PAN/CVV + transactions in an **unencrypted SQLite** DB | `Documents/vault.sqlite` |
| 3 | API key / HMAC secret baked into the app bundle | `Payload/PocketVault.app/Config.plist` |
| 4 | SSN written to a **cache** file | `Library/Caches/profile_scratch.json` |
| 5 | Keychain item with `kSecAttrAccessibleAlways` (backed up) | Keychain / backup keychain |
| 6 | No privacy screen → clear **backgrounding snapshot** | `Library/Caches/Snapshots/…` |
| 7 | Auth token written to the **unified log** | device console (`idevicesyslog`) |

The internal answer key with exact code locations is
[`VULNERABILITIES.md`](VULNERABILITIES.md).

## Repo layout

```
PocketVault/
├── project.yml                 # XcodeGen spec (project generated on CI)
├── .github/workflows/build.yml # macOS build → unsigned .ipa artifact
├── PocketVault/                # SwiftUI sources
│   ├── Storage/                # the insecure storage layer (the interesting bit)
│   ├── Views/
│   └── Resources/              # Info.plist, Config.plist
├── VULNERABILITIES.md          # answer key (code locations + fixes)
└── writeups/                   # one finding per file, htb-writeups style
```

## Scope & ethics

Every target here is code I wrote and a device I own. Nothing in this project
touches third-party apps, other people's data, or production services. This is
the responsible-disclosure-by-construction model: I am the vendor and the
researcher.
