//
//  PocketVaultApp.swift
//  PocketVault — an intentionally vulnerable iOS finance app (educational)
//
//  ⚠️  This app deliberately stores sensitive data insecurely to demonstrate
//      OWASP MASVS / Mobile Top 10 M9 (Insecure Data Storage). It contains NO
//      real data and MUST NOT be used with real accounts. See VULNERABILITIES.md.
//

import SwiftUI

@main
struct PocketVaultApp: App {
    @StateObject private var session = SessionManager()

    init() {
        // Seed fake data on first launch so there is something to steal.
        SeedData.installIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
            // VULN #6 (No privacy snapshot screen): we never blur/cover the UI
            // when the app backgrounds, so iOS caches a clear screenshot of the
            // balance screen to Library/Caches/Snapshots/. A privacy overlay on
            // scenePhase == .background would fix this — intentionally omitted.
        }
    }
}
