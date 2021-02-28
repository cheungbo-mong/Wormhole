//
//  ContentView.swift
//  Example.watchOS Extension
//
//  Created by Vance Will on 2/28/21.
//

import SwiftUI
import Wormhole

struct ContentView: View {
    @State var title: String
    @Environment(\.injected) private var injected: DIContainer
    init() {
        _title = .init(initialValue: "")
    }

    var body: some View {
        ScrollView {
            Text(title)
                .onReceive(injected.interactors.mainInteractor.segmentFromCompanion) { value in
                    title = value
                }

            Button(action: {
                injected.interactors.mainInteractor.tapButton(tag: 1)
            }, label: {
                Text("1")
            })
            Button(action: {
                injected.interactors.mainInteractor.tapButton(tag: 2)
            }, label: {
                Text("2")
            })
            Button(action: {
                injected.interactors.mainInteractor.tapButton(tag: 3)
            }, label: {
                Text("3")
            })
        }
    }
}
