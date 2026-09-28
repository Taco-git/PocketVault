//
//  InsecureStore.swift
//  Wrappers around the wrong places to keep secrets: UserDefaults, Caches, tmp.
//  (OWASP Mobile M9 — Insecure Data Storage)
//

import Foundation

struct InsecureStore {

    private let defaults = UserDefaults.standard

    // MARK: - VULN #1: plaintext UserDefaults

    func saveSessionToken(_ token: String) {
        defaults.set(token, forKey: "session_token")
    }

    func savePIN(_ pin: String) {
        defaults.set(pin, forKey: "user_pin")
    }

    /// Stores username + password as a dictionary. UserDefaults is an
    /// unencrypted plist — anyone with a backup can read this.
    func saveRememberedCredentials(username: String, password: String) {
        defaults.set(["u": username, "p": password], forKey: "remember_me")
    }

    // MARK: - VULN #4: sensitive data written to Caches (survives, backed up)

    func cacheProfileScratch(ssn: String) {
        let caches = FileManager.default.urls(for: .cachesDirectory,
                                              in: .userDomainMask)[0]
        let url = caches.appendingPathComponent("profile_scratch.json")
        let blob = ["ssn": ssn, "written": ISO8601DateFormatter().string(from: Date())]
        if let data = try? JSONSerialization.data(withJSONObject: blob) {
            try? data.write(to: url)   // no file protection attributes set
        }
    }

    /// Also drops a copy in tmp/ "for debugging". tmp is purged by iOS only
    /// under pressure, and is captured in a container dump.
    func writeDebugDump(_ contents: String) {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("last_response.txt")
        try? contents.write(to: tmp, atomically: true, encoding: .utf8)
    }
}
