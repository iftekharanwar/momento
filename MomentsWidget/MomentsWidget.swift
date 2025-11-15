//
//  Created by Iftekhar Anwar on 13/11/25.
//

import WidgetKit
import SwiftUI

struct MomentsEntry: TimelineEntry {
    let date: Date
    let heartName: String
    let partnerName: String
    let isPaired: Bool
    let latestLetter: WidgetLetterData?
    let latestTrack: WidgetMusicData?
}

struct MomentsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MomentsEntry {
        MomentsEntry(
            date: Date(),
            heartName: "Our Love",
            partnerName: "Partner",
            isPaired: true,
            latestLetter: WidgetLetterData(
                content: "You make every day special ❤️",
                senderName: "Partner",
                date: Date()
            ),
            latestTrack: WidgetMusicData(
                trackName: "Perfect",
                artistName: "Ed Sheeran",
                senderName: "Partner",
                message: "This song reminds me of us",
                date: Date()
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MomentsEntry) -> ()) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            let entry = getEntry()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MomentsEntry>) -> ()) {
        let entry = getEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getEntry() -> MomentsEntry {
        let widgetData = SharedDataManager.shared.getWidgetData()
        
        let heartName = widgetData?.heartName.isEmpty == false ? widgetData!.heartName : "Our Love"
        let partnerName = widgetData?.partnerName ?? ""
        let isPaired = widgetData?.isPaired ?? false
        
        return MomentsEntry(
            date: Date(),
            heartName: heartName,
            partnerName: partnerName,
            isPaired: isPaired,
            latestLetter: widgetData?.latestLetter,
            latestTrack: widgetData?.latestTrack
        )
    }
}

struct MomentsWidget: Widget {
    let kind: String = "MomentsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MomentsProvider()) { entry in
            MomentsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Moments")
        .description("Stay connected with your loved one")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
