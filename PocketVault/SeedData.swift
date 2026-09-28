//
//  SeedData.swift
//  Installs fake-but-realistic data once, so there is something to recover.
//

import Foundation

enum SeedData {
    static func installIfNeeded() {
        let d = UserDefaults.standard
        guard !d.bool(forKey: "seeded") else { return }

        let db = VaultDatabase.shared
        db.insertCard(holder: "TACO TESTER",
                      pan: "4539578763621486",   // fake, passes Luhn for realism
                      cvv: "451",
                      expiry: "11/28")
        db.insertTransaction(merchant: "Hudson Valley Coffee", amount: -4.75, memo: "latte")
        db.insertTransaction(merchant: "Payroll Deposit",      amount: 2200.00, memo: "biweekly")
        db.insertTransaction(merchant: "Steam",                amount: -59.99, memo: "game")
        db.insertTransaction(merchant: "MTA Metro-North",      amount: -18.50, memo: "commute")

        // VULN #3 is the *bundled* Config.plist (read-only, see ConfigLoader).
        d.set(true, forKey: "seeded")
    }
}
