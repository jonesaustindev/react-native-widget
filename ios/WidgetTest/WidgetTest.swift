//
//  WidgetTest.swift
//  WidgetTest
//
//  Created by Austin Jones on 3/5/21.
//

import WidgetKit
import SwiftUI
import Intents

struct WidgetData: Decodable {
  var displayText: String
}

struct Provider: IntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), configuration: ConfigurationIntent(), displayText: "Placeholder")
  }
  
  func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), configuration: configuration, displayText: "DATA")
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    var entryDate = Date()
    
    let sharedDefaults = UserDefaults.init(suiteName: "group.YOURINFO.HERE")
    var entries: [SimpleEntry] = []
    if sharedDefaults != nil {
      if let aValue = sharedDefaults!.value(forKey: "savedData") as? String {
        let decoder = JSONDecoder()
        let data = aValue.data(using: .utf8)
        
        if let parsedData = try? decoder.decode(WidgetData.self, from: data!) {
          for minuteOffset in 0 ..< 5 {
            entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: entryDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, displayText: parsedData.displayText)
            entries.append(entry)
          }
          
          let timeline = Timeline(entries: entries, policy: .atEnd)
          completion(timeline)
        } else {
          print("Could not parse data")
        }
        
      } else {
        for minuteOffset in 0 ..< 5 {
          entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: entryDate)!
          let entry = SimpleEntry(date: entryDate, configuration: configuration, displayText: "Hi there, offset: \(minuteOffset)")
          entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
      }
    }
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationIntent
  let displayText: String
}

struct WidgetTestEntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom)
      .edgesIgnoringSafeArea(.vertical)
      .overlay(
        VStack {
          Text(entry.displayText)
            .bold()
            .foregroundColor(.white)
        }.padding(20)
      )
  }
}

@main
struct WidgetTest: Widget {
  let kind: String = "WidgetTest"
  
  var body: some WidgetConfiguration {
    IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
      WidgetTestEntryView(entry: entry)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

struct WidgetTest_Previews: PreviewProvider {
  static var previews: some View {
    WidgetTestEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), displayText: "Widget preview"))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
