//
//  AppState.swift
//  MenuBarLiveActivityRebuild
//
//  Created by Marc Büttner on 09.09.25.
//

import Combine

final class AppState: ObservableObject {
    @Published var showPill: Bool = false
    @Published var progress: Double = 0.0
}
