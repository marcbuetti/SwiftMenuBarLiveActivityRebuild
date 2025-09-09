//
//  ContentView.swift
//  MenuBarLiveActivityRebuild
//
//  Created by Marc Büttner on 09.09.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("MenuBarLiveActvity Controller")
                .font(.title3).bold()

            Toggle("Show Live Activity", isOn: $appState.showPill)
                .toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 8) {
                Text("Progress: \(Int(appState.progress * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Slider(value: $appState.progress, in: 0...1, step: 0.01)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }
}
