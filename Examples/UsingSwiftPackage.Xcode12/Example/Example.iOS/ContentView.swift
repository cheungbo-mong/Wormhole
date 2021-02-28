//
//  ContentView.swift
//  Example
//
//  Created by Vance Will on 2/28/21.
//

import Combine
import SwiftUI
import Wormhole

struct ContentView: View {
    @State var selectedSegment = 0
    private let segments = ["One", "Two", "Three"]
    @Environment(\.injected) private var injected: DIContainer
    @State var buttonValue: String
    @State var widgetMessage: String
    init() {
        _buttonValue = .init(initialValue: "")
        _widgetMessage = .init(initialValue: "")
    }

    var body: some View {
        VStack {
            Text("Message from widget")
            Text(widgetMessage)
                .onReceive(messageFromWidget, perform: { widgetMessage = $0 })
            Picker(selection: $selectedSegment, label: Text("Section Value"), content: {
                Text("One").tag(0)
                Text("Two").tag(1)
                Text("Three").tag(2)
            }).onChange(of: selectedSegment, perform: { selected in
                injected.interactors.mainInteractor.segmentChange(segments[selected])
            })
                .padding(.horizontal, 50)
                .pickerStyle(SegmentedPickerStyle())

            Text("Button value from watch")
                .padding(.top, 30)
            Text(buttonValue)
                .onReceive(buttonFromCompanion) { buttonValue = $0 }
        }
        .onAppear {
            injected.interactors.mainInteractor.segmentChange(segments[selectedSegment])
        }
    }

    var messageFromWidget: AnyPublisher<String, Never> {
        injected.interactors.mainInteractor.messageFromWidget
    }

    var buttonFromCompanion: AnyPublisher<String, Never> {
        injected.interactors.mainInteractor.buttonFromCompanion
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
