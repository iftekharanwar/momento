//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import WidgetKit

struct MomentsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MomentsEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: MomentsEntry
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "FFB3C6"))
            }
            
            Text(entry.heartName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            if entry.isPaired {
                Text(entry.partnerName)
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Connected")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.green)
                }
            } else {
                Text("Waiting...")
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(hex: "FFE5EC"),
                    Color(hex: "F0ECFF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct MediumWidgetView: View {
    let entry: MomentsEntry
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "envelope.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "FFB3C6"))
            }
            .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 6) {
                if let letter = entry.latestLetter {
                    Text("From \(letter.senderName)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "9B8DBA"))
                    
                    Text(letter.content)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Text(timeAgo(from: letter.date))
                        .font(.system(size: 10))
                        .foregroundColor(.black.opacity(0.5))
                } else {
                    Text(entry.heartName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("No letters yet")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                    
                    Spacer()
                    
                    Text("Open app to send love")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "FFB3C6"))
                }
            }
            .padding(.vertical, 12)
            .padding(.trailing, 16)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(hex: "FFE5EC"),
                    Color(hex: "FFF0F5")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct LargeWidgetView: View {
    let entry: MomentsEntry
    
    var shouldShowLetter: Bool {
        guard let letter = entry.latestLetter, let track = entry.latestTrack else {
            return entry.latestLetter != nil
        }
        return letter.date > track.date
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.heartName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    if entry.isPaired {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Connected with \(entry.partnerName)")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "FFB3C6"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            if shouldShowLetter, let letter = entry.latestLetter {
                LetterContentView(letter: letter)
            } else if let track = entry.latestTrack {
                MusicContentView(track: track)
            } else {
                EmptyContentView()
            }
            
            Spacer()
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(hex: "FFE5EC"),
                    Color(hex: "FFF0F5"),
                    Color(hex: "F0ECFF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct LetterContentView: View {
    let letter: WidgetLetterData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "9B8DBA"))
                
                Text("Latest Love Letter")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "9B8DBA"))
                
                Spacer()
                
                Text(timeAgo(from: letter.date))
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("From \(letter.senderName)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "FFB3C6"))
                
                Text(letter.content)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color.white.opacity(0.7))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
}

struct MusicContentView: View {
    let track: WidgetMusicData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "music.note")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "9B8DBA"))
                
                Text("Latest Shared Song")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "9B8DBA"))
                
                Spacer()
                
                Text(timeAgo(from: track.date))
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("From \(track.senderName)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "FFB3C6"))
                
                HStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "9B8DBA"))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.trackName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Text(track.artistName)
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                
                if !track.message.isEmpty {
                    Text(track.message)
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.7))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }
}

struct EmptyContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "FFB3C6").opacity(0.5))
            
            Text("No moments yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
            
            Text("Open the app to share love")
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}


extension View {
    func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct MomentsWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MomentsWidgetEntryView(entry: MomentsEntry(
                date: Date(),
                heartName: "rewrites the stars",
                partnerName: "Maaryah",
                isPaired: true,
                latestLetter: WidgetLetterData(
                    content: "Just wanted to tell you how much I love you. You make every day brighter! ❤️",
                    senderName: "Maaryah",
                    date: Date().addingTimeInterval(-3600)
                ),
                latestTrack: nil
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            MomentsWidgetEntryView(entry: MomentsEntry(
                date: Date(),
                heartName: "rewrites the stars",
                partnerName: "Maaryah",
                isPaired: true,
                latestLetter: WidgetLetterData(
                    content: "Just wanted to tell you how much I love you. You make every day brighter! ❤️",
                    senderName: "Maaryah",
                    date: Date().addingTimeInterval(-3600)
                ),
                latestTrack: nil
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            MomentsWidgetEntryView(entry: MomentsEntry(
                date: Date(),
                heartName: "rewrites the stars",
                partnerName: "Maaryah",
                isPaired: true,
                latestLetter: WidgetLetterData(
                    content: "Just wanted to tell you how much I love you. You make every day brighter! ❤️",
                    senderName: "Maaryah",
                    date: Date().addingTimeInterval(-7200)
                ),
                latestTrack: WidgetMusicData(
                    trackName: "Perfect",
                    artistName: "Ed Sheeran",
                    senderName: "Maaryah",
                    message: "This song always reminds me of us 💕",
                    date: Date().addingTimeInterval(-1800)
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
