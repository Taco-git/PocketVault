//
//  SessionManager.swift
//  Auth/session state. Demonstrates several M9 storage sins on login.
//

import Foundation
import SwiftUI

final class SessionManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: String = ""

    private let store = InsecureStore()

    /// "Authenticates" the user. Auth itself is fake (M3 territory); the point
    /// here is everything it *stores* on success.
    func login(username: String, password: String) -> Bool {
        // Trivial client-side check — real app would hit a server.
        guard !username.isEmpty, password.count >= 4 else { return false }

        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(UUID().uuidString).sig"

        // VULN #1 (Insecure UserDefaults): session token, PIN and a "remember
        // me" credential blob written to NSUserDefaults in plaintext. Recoverable
        // from Library/Preferences/<bundleid>.plist in any backup.
        store.saveSessionToken(token)
        store.savePIN("1998")                // user's real banking PIN, reused
        store.saveRememberedCredentials(username: username, password: password)

        // VULN #7 (Sensitive data in unified logs): the auth token is printed to
        // the device console on every login. Visible via `idevicesyslog` / the
        // macOS Console app with no jailbreak.
        NSLog("[PocketVault] login success user=%@ token=%@", username, token)
        print("DEBUG auth token issued: \(token)")

        // VULN #4 (Sensitive data in caches/tmp): SSN dropped into a cache file
        // that survives relaunch and lands in backups.
        store.cacheProfileScratch(ssn: "078-05-1120")

        // VULN #5 (Keychain misuse): store the token in the Keychain but with
        // kSecAttrAccessibleAlways, so it is readable while the device is locked
        // and is included in unencrypted backups.
        KeychainHelper.shared.saveInsecurely(key: "auth_token", value: token)

        currentUser = username
        isLoggedIn = true
        return true
    }

    func logout() {
        // Note: we never actually clear the stored token/PIN/credentials.
        isLoggedIn = false
    }
}
