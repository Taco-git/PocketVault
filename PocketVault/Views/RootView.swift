//
//  RootView.swift
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        if session.isLoggedIn {
            DashboardView()
        } else {
            LoginView()
        }
    }
}
