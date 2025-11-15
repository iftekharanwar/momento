//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI
import FirebaseAuth

struct MusicView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @StateObject private var viewModel = MusicViewModel()
    @State private var showShareSheet = false
    @State private var selectedTab = 0 // 0 = Received, 1 = Sent
    
    var receivedTracks: [MusicTrack] {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        return viewModel.tracks.filter { $0.userId != currentUserId }
    }
    
    var sentTracks: [MusicTrack] {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        return viewModel.tracks.filter { $0.userId == currentUserId }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Our Music")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "FFB3C6"))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        VStack(spacing: 8) {
                            Text("Received")
                                .font(.system(size: 16, weight: selectedTab == 0 ? .semibold : .regular))
                                .foregroundColor(selectedTab == 0 ? Color(hex: "FFB3C6") : .black.opacity(0.5))
                            
                            if selectedTab == 0 {
                                Rectangle()
                                    .fill(Color(hex: "FFB3C6"))
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: { selectedTab = 1 }) {
                        VStack(spacing: 8) {
                            Text("Sent")
                                .font(.system(size: 16, weight: selectedTab == 1 ? .semibold : .regular))
                                .foregroundColor(selectedTab == 1 ? Color(hex: "FFB3C6") : .black.opacity(0.5))
                            
                            if selectedTab == 1 {
                                Rectangle()
                                    .fill(Color(hex: "FFB3C6"))
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                TabView(selection: $selectedTab) {
                    MusicTracksListView(
                        tracks: receivedTracks,
                        emptyMessage: "No songs received yet",
                        emptyDescription: "When your partner shares a song, it will appear here"
                    )
                    .tag(0)
                    
                    MusicTracksListView(
                        tracks: sentTracks,
                        emptyMessage: "No songs shared yet",
                        emptyDescription: "Share your first favorite song"
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareMusicView(
                heartCode: pairingViewModel.heartCode,
                userName: pairingViewModel.currentUserName,
                viewModel: viewModel
            )
        }
        .onAppear {
            if !pairingViewModel.heartCode.isEmpty {
                viewModel.startListening(heartCode: pairingViewModel.heartCode)
            }
        }
    }
}

struct MusicTracksListView: View {
    let tracks: [MusicTrack]
    let emptyMessage: String
    let emptyDescription: String
    
    var body: some View {
        if tracks.isEmpty {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "FFB3C6").opacity(0.3))
                
                Text(emptyMessage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black.opacity(0.6))
                
                Text(emptyDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(tracks) { track in
                        MusicTrackCard(
                            track: track,
                            isFromMe: track.userId == Auth.auth().currentUser?.uid
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }
}

struct MusicTrackCard: View {
    let track: MusicTrack
    let isFromMe: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFB3C6"), Color(hex: "9B8DBA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "music.note")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(track.trackName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(track.artistName)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(1)
                
                if !track.message.isEmpty {
                    Text(track.message)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
                
                HStack {
                    Text(isFromMe ? "You" : track.userName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isFromMe ? Color(hex: "FFB3C6") : Color(hex: "9B8DBA"))
                    
                    Text("•")
                        .foregroundColor(.black.opacity(0.3))
                    
                    Text(track.createdAt, style: .relative)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct ShareMusicView: View {
    @Environment(\.dismiss) var dismiss
    let heartCode: String
    let userName: String
    @ObservedObject var viewModel: MusicViewModel
    
    @State private var trackName = ""
    @State private var artistName = ""
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FFE5EC"))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "music.note")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "FFB3C6"))
                        }
                        .padding(.top, 20)
                        
                        Text("Share a Song")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Song Title")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                TextField("Enter song title", text: $trackName)
                                    .padding()
                                    .background(Color(hex: "F5F5F5"))
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Artist")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                TextField("Enter artist name", text: $artistName)
                                    .padding()
                                    .background(Color(hex: "F5F5F5"))
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message (optional)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                TextField("Why this song reminds you of them...", text: $message, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding()
                                    .background(Color(hex: "F5F5F5"))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: shareTrack) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            } else {
                                Text("Share Song")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                        }
                        .background(
                            (trackName.isEmpty || artistName.isEmpty) ? Color.gray.opacity(0.3) : Color(hex: "9B8DBA")
                        )
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .disabled(trackName.isEmpty || artistName.isEmpty || viewModel.isLoading)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareTrack() {
        viewModel.shareTrack(
            heartCode: heartCode,
            trackName: trackName,
            artistName: artistName,
            message: message,
            userName: userName
        ) { success in
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    MusicView()
        .environmentObject(PairingViewModel())
}
