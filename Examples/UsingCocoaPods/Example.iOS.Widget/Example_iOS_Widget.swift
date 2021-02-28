//
//  Example_iOS_Widget.swift
//  Example.iOS.Widget
//
//  Created by Vance Will on 2/28/21.
//

import Combine
import CoreServices
import SwiftUI
import WidgetKit
import Wormhole

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var phoneSelection: String {
        if
            let box = wormhole.message(with: .phoneWidgetMsgID),
            let message = box.open(as: [String: String].self),
            let selection = message["selectionString"]
        {
            return selection
        } else {
            return ""
        }
    }

    var watchButton: String {
        if
            let box = wormhole.message(with: .watchPhoneWidgetMsgID),
            let message = box.open(as: [String: String].self),
            let value = message["buttonNumber"]
        {
            return value
        } else {
            return ""
        }
    }

    private let wormhole = Wormhole(
        appGroup: .wormholeAppGroup,
        container: .wormholeContainer
    )

    init(date: Date) {
        self.date = date
    }

    func onAppear() {
        wormhole.passMessage(["message": "Widget did appear"], with: .widgetPhoneMsgID)
    }
}

struct Example_iOS_WidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack {
            Text("phoneSelection: \(entry.phoneSelection)")

            Text("watchButton: \(entry.watchButton)")
        }.onAppear(perform: entry.onAppear)
    }
}

@main
struct Example_iOS_Widget: Widget {
    let kind: String = "Example_iOS_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Example_iOS_WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Example_iOS_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Example_iOS_WidgetEntryView(entry: .init(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
