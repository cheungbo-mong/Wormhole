//
//  ExampleApp.swift
//  watchOS Extension
//
//  Created by Ethan Mengoreo on 2/7/21.
//

import SwiftUI
import Wormhole
@main
struct ExampleApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
