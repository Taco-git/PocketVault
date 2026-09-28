//
//  LoginView.swift
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State private var username = "taco"
    @State private var password = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.shield")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("PocketVault").font(.largeTitle.bold())
            Text("Your money, one tap away.")
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 32)

            Button {
                if !session.login(username: username, password: password) {
                    showError = true
                }
            } label: {
                Text("Sign In").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)

            if showError {
                Text("Enter any username and a 4+ char password.")
                    .font(.footnote).foregroundStyle(.red)
            }
            Spacer()
            Text("⚠️ Intentionally vulnerable demo app — no real data.")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding()
    }
}
