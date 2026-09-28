//
//  DashboardView.swift
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var session: SessionManager
    private let db = VaultDatabase.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Balance") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("$3,412.18").font(.system(size: 40, weight: .bold))
                        Text(db.maskedCard()).foregroundStyle(.secondary)
                            .monospaced()
                    }.padding(.vertical, 8)
                }

                Section("Recent activity") {
                    ForEach(db.allTransactions(), id: \.0) { merchant, amount in
                        HStack {
                            Text(merchant)
                            Spacer()
                            Text(amount, format: .currency(code: "USD"))
                                .foregroundStyle(amount < 0 ? .primary : .green)
                        }
                    }
                }

                Section {
                    NavigationLink("Profile & Settings") { ProfileView() }
                }
            }
            .navigationTitle("Hi, \(session.currentUser)")
            .toolbar {
                Button("Sign Out") { session.logout() }
            }
        }
    }
}
