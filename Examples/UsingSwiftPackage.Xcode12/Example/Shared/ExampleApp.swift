//
//  ExampleApp.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import SwiftUI

@main
struct ExampleApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let env = AppEnvironment.bootstrap()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .inject(env.container)
            .onAppear(perform: env.handler.onLaunch)
        }
        .onChange(of: scenePhase, perform: env.handler.onScenePhaseChange(_:))
    }
}
