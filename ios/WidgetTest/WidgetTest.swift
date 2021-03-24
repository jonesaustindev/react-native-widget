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
    let entry = SimpleEntry(date: Date(), configuration: configuration, displayText: "Data goes here")
    completion(entry)
  }
  
  func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
    let entryDate = Date()
    
    let userDefaults = UserDefaults.init(suiteName: "group.com.YOURINFO.ReactNativeWidget")
    if userDefaults != nil {
      if let savedData = userDefaults!.value(forKey: "savedData") as? String {
        let decoder = JSONDecoder()
        let data = savedData.data(using: .utf8)
        
        if let parsedData = try? decoder.decode(WidgetData.self, from: data!) {
          let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: entryDate)!
          let entry = SimpleEntry(date: nextRefresh, configuration: configuration, displayText: parsedData.displayText)
          let timeline = Timeline(entries: [entry], policy: .atEnd)
          
          completion(timeline)
        } else {
          print("Could not parse data")
        }
        
      } else {
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: entryDate)!
        let entry = SimpleEntry(date: nextRefresh, configuration: configuration, displayText: "No data set")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
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
