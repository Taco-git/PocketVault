# VULNERABILITIES.md — internal answer key

Exact locations of every planted M9 flaw and its one-line fix. Keep this out of
the "attacker" writeups; it's the key, not the walkthrough.

| # | Flaw | Source | Symbol | Fix |
|---|------|--------|--------|-----|
| 1 | Token/PIN/creds in UserDefaults | `Storage/InsecureStore.swift` | `saveSessionToken` / `savePIN` / `saveRememberedCredentials` | Keychain (WhenUnlockedThisDeviceOnly); never store passwords |
| 2 | Unencrypted SQLite w/ PAN+CVV | `Storage/VaultDatabase.swift` | `path` / `insertCard` | SQLCipher or `NSFileProtectionComplete`; never store CVV; tokenize PAN |
| 3 | Secrets in app bundle | `Resources/Config.plist`, `Storage/ConfigLoader.swift` | `apiKey()` | Fetch short-lived secrets at runtime; keep nothing sensitive in the IPA |
| 4 | SSN in Caches (+ tmp) | `Storage/InsecureStore.swift` | `cacheProfileScratch` / `writeDebugDump` | Don't persist; if unavoidable, `NSFileProtectionComplete` and purge |
| 5 | Keychain `AccessibleAlways` | `Storage/KeychainHelper.swift` | `saveInsecurely` | `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` |
| 6 | No privacy snapshot screen | `PocketVaultApp.swift` | `body` (comment) | Cover UI on `scenePhase == .background` / `.inactive` |
| 7 | Sensitive data in unified log | `SessionManager.swift`, `Views/ProfileView.swift` | `NSLog`/`print` on login & profile | Never log secrets; use redacted `os.Logger` (`privacy: .private`) |

## Fake data used (safe to publish)

- SSN `078-05-1120` — a well-known invalid/specimen SSN (the 1938 wallet card).
- PAN `4539578763621486` — Luhn-valid test number, not a real issued card.
- API key / HMAC secret — obviously-fake demo strings.
