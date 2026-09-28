//
//  VaultDatabase.swift
//  An unencrypted SQLite database holding full card numbers and transactions.
//  Uses the system libsqlite3 (no third-party dependency) so CI stays simple.
//  (OWASP Mobile M9 — Insecure Data Storage)
//

import Foundation
import SQLite3

final class VaultDatabase {
    static let shared = VaultDatabase()
    private var db: OpaquePointer?

    /// VULN #2: the DB lives, unencrypted, in Documents/. A plain
    /// `sqlite3 vault.sqlite` (or any SQLite browser) reads every row from a
    /// backup. SQLCipher or file-protection classes would fix this.
    private lazy var path: String = {
        let docs = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0]
        return docs.appendingPathComponent("vault.sqlite").path
    }()

    private init() {
        open()
        createSchema()
    }

    private func open() {
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("DB open failed at \(path)")
        }
    }

    private func createSchema() {
        let sql = """
        CREATE TABLE IF NOT EXISTS cards (
            id INTEGER PRIMARY KEY,
            holder TEXT, pan TEXT, cvv TEXT, expiry TEXT
        );
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY,
            merchant TEXT, amount REAL, date TEXT, memo TEXT
        );
        """
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    func insertCard(holder: String, pan: String, cvv: String, expiry: String) {
        let sql = "INSERT INTO cards (holder,pan,cvv,expiry) VALUES (?,?,?,?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (holder as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (pan as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (cvv as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (expiry as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func insertTransaction(merchant: String, amount: Double, memo: String) {
        let sql = "INSERT INTO transactions (merchant,amount,date,memo) VALUES (?,?,?,?);"
        var stmt: OpaquePointer?
        let date = ISO8601DateFormatter().string(from: Date())
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (merchant as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 2, amount)
            sqlite3_bind_text(stmt, 3, (date as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (memo as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func allTransactions() -> [(String, Double)] {
        var rows: [(String, Double)] = []
        let sql = "SELECT merchant, amount FROM transactions ORDER BY id DESC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let m = String(cString: sqlite3_column_text(stmt, 0))
                let a = sqlite3_column_double(stmt, 1)
                rows.append((m, a))
            }
        }
        sqlite3_finalize(stmt)
        return rows
    }

    func maskedCard() -> String {
        let sql = "SELECT pan FROM cards LIMIT 1;"
        var stmt: OpaquePointer?
        var pan = "•••• •••• •••• ••••"
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK,
           sqlite3_step(stmt) == SQLITE_ROW {
            let full = String(cString: sqlite3_column_text(stmt, 0))
            pan = "•••• •••• •••• " + String(full.suffix(4))
        }
        sqlite3_finalize(stmt)
        return pan
    }
}
