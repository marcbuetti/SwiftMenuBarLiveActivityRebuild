//
//  MenuBarLiveActivityRebuildApp.swift
//  MenuBarLiveActivityRebuild
//
//  Created by Marc Büttner on 09.09.25.
//

import SwiftUI

@main
struct MenuBarLiveActivityRebuildApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var menuBarController: MenuBarController

    init() {
        let state = AppState()
        _appState = StateObject(wrappedValue: state)
        _menuBarController = StateObject(wrappedValue: MenuBarController(appState: state))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

