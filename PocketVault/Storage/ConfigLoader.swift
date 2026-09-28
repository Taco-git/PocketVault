//
//  ConfigLoader.swift
//  Reads secrets baked into the app bundle at build time.
//  (OWASP Mobile M9 / M1 — secrets shipped inside the IPA)
//

import Foundation

enum ConfigLoader {

    /// VULN #3: Config.plist is compiled into the app bundle. Anyone can unzip
    /// the .ipa (it's just a zip) and read Payload/PocketVault.app/Config.plist,
    /// or run `strings` on the binary. Secrets in the bundle are not secret.
    static func apiKey() -> String {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let key = dict["API_KEY"] as? String else {
            return "MISSING"
        }
        return key
    }

    static func backendBaseURL() -> String {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let base = dict["API_BASE"] as? String else {
            return ""
        }
        return base
    }
}
