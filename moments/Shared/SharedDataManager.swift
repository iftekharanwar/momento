//
//  Created by Iftekhar Anwar on 13/11/25.
//

import Foundation
import WidgetKit

class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let appGroupID = "group.com.iftekharanwar.moments"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    func saveWidgetData(heartName: String, partnerName: String, isPaired: Bool, latestLetter: WidgetLetterData?, latestTrack: WidgetMusicData?) {
        guard let defaults = userDefaults else { return }
        
        let data = WidgetData(
            heartName: heartName,
            partnerName: partnerName,
            isPaired: isPaired,
            latestLetter: latestLetter,
            latestTrack: latestTrack,
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: "widgetData")
            
            // Force widget reload
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func getWidgetData() -> WidgetData? {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "widgetData"),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    func updateLatestLetter(_ letter: WidgetLetterData) {
        guard let currentData = getWidgetData() else { return }
        saveWidgetData(
            heartName: currentData.heartName,
            partnerName: currentData.partnerName,
            isPaired: currentData.isPaired,
            latestLetter: letter,
            latestTrack: currentData.latestTrack
        )
    }
    
    func updateLatestTrack(_ track: WidgetMusicData) {
        guard let currentData = getWidgetData() else { return }
        saveWidgetData(
            heartName: currentData.heartName,
            partnerName: currentData.partnerName,
            isPaired: currentData.isPaired,
            latestLetter: currentData.latestLetter,
            latestTrack: track
        )
    }
    
    func updatePairingInfo(heartName: String, partnerName: String, isPaired: Bool) {
        let currentData = getWidgetData()
        saveWidgetData(
            heartName: heartName,
            partnerName: partnerName,
            isPaired: isPaired,
            latestLetter: currentData?.latestLetter,
            latestTrack: currentData?.latestTrack
        )
    }
}

struct WidgetData: Codable {
    let heartName: String
    let partnerName: String
    let isPaired: Bool
    let latestLetter: WidgetLetterData?
    let latestTrack: WidgetMusicData?
    let lastUpdated: Date
}

struct WidgetLetterData: Codable {
    let content: String
    let senderName: String
    let date: Date
}

struct WidgetMusicData: Codable {
    let trackName: String
    let artistName: String
    let senderName: String
    let message: String
    let date: Date
}
