//
//  ProfileView.swift
//

import SwiftUI

struct ProfileView: View {
    private let store = InsecureStore()

    var body: some View {
        List {
            Section("Account holder") {
                LabeledContent("Name", value: "Taco Tester")
                LabeledContent("SSN", value: "•••-••-1120")
                LabeledContent("PIN on file", value: "••••")
            }
            Section("Developer") {
                // Surfacing the baked-in secret in the UI too, for good measure.
                LabeledContent("API key", value: ConfigLoader.apiKey())
                    .font(.caption).monospaced()
            }
            Section {
                Text("This screen renders sensitive fields masked, but the "
                     + "underlying values are stored in the clear on device. "
                     + "See VULNERABILITIES.md.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Profile")
        .onAppear {
            // VULN #7 again: log sensitive context on screen view.
            NSLog("[PocketVault] profile opened, cached ssn present")
        }
    }
}
