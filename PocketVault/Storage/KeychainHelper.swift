//
//  KeychainHelper.swift
//  The Keychain is the *right* place — used the *wrong* way.
//  (OWASP Mobile M9 — Insecure Data Storage)
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    // MARK: - VULN #5: Keychain item with kSecAttrAccessibleAlways

    /// Saves an item accessible even when the device is locked, and — because
    /// the accessibility class is not "ThisDeviceOnly" — migrated into
    /// iTunes/Finder backups where it can be extracted offline.
    func saveInsecurely(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            // ❌ should be kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            kSecAttrAccessible as String: kSecAttrAccessibleAlways
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var out: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &out) == errSecSuccess,
              let data = out as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
