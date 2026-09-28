//
//  DashboardView.swift
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var session: SessionManager
    private let db = VaultDatabase.shared

    private struct Txn: Identifiable {
        let id = UUID()
        let merchant: String
        let amount: Double
    }

    private var transactions: [Txn] {
        db.allTransactions().map { Txn(merchant: $0.0, amount: $0.1) }
    }

    var body: some View {
        NavigationStack {
            List {
                balanceSection
                activitySection
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

    private var balanceSection: some View {
        Section("Balance") {
            VStack(alignment: .leading, spacing: 4) {
                Text("$3,412.18")
                    .font(.system(size: 40, weight: .bold))
                Text(db.maskedCard())
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
            .padding(.vertical, 8)
        }
    }

    private var activitySection: some View {
        Section("Recent activity") {
            ForEach(transactions) { txn in
                TxnRow(merchant: txn.merchant, amount: txn.amount)
            }
        }
    }
}

private struct TxnRow: View {
    let merchant: String
    let amount: Double

    private var amountColor: Color {
        amount < 0 ? .primary : .green
    }

    var body: some View {
        HStack {
            Text(merchant)
            Spacer()
            Text(amount, format: .currency(code: "USD"))
                .foregroundStyle(amountColor)
        }
    }
}
