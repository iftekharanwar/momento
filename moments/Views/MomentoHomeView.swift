//
//  Created by Iftekhar Anwar on 12/11/25.
//

import SwiftUI

struct MomentoHomeView: View {
    @EnvironmentObject var pairingViewModel: PairingViewModel
    @State private var showMusicSheet = false
    @State private var showLoveQuestionsSheet = false
    @State private var showCheckInsSheet = false
    @State private var showLettersSheet = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                HeaderView(heartName: pairingViewModel.heartName)
                
                ContentAreaView(
                    showMusicSheet: $showMusicSheet,
                    showLoveQuestionsSheet: $showLoveQuestionsSheet,
                    showCheckInsSheet: $showCheckInsSheet,
                    showLettersSheet: $showLettersSheet
                )
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showMusicSheet) {
            MusicView()
                .environmentObject(pairingViewModel)
        }
        .fullScreenCover(isPresented: $showLoveQuestionsSheet) {
            LoveQuestionsView()
                .environmentObject(pairingViewModel)
        }
        .fullScreenCover(isPresented: $showCheckInsSheet) {
            CheckInsView()
                .environmentObject(pairingViewModel)
        }
        .fullScreenCover(isPresented: $showLettersSheet) {
            LettersView()
                .environmentObject(pairingViewModel)
        }
    }
}

struct HeaderView: View {
    let heartName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                StatBadge(icon: "heart.fill", count: "550", color: .pink)
                StatBadge(icon: "flame.fill", count: "1", color: .orange)
                Spacer()
            }
            
            Text(heartName.isEmpty ? "the Best" : heartName)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct StatBadge: View {
    let icon: String
    let count: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
            Text(count)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct ContentAreaView: View {
    @Binding var showMusicSheet: Bool
    @Binding var showLoveQuestionsSheet: Bool
    @Binding var showCheckInsSheet: Bool
    @Binding var showLettersSheet: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                Image("cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.35)
                    .position(x: width * 0.25, y: height * 0.15)
                    .opacity(0.9)
                
                Image("cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.45)
                    .position(x: width * 0.65, y: height * 0.1)
                    .opacity(0.9)
                
                IconButton(imageName: "gift-box", size: width * 0.18) {}
                    .position(x: width * 0.78, y: height * 0.28)
                
                IconButton(imageName: "music", size: width * 0.22) {
                    showMusicSheet = true
                }
                    .position(x: width * 0.2, y: height * 0.45)
                
                IconButton(imageName: "mugs", size: width * 0.22) {
                    showLoveQuestionsSheet = true
                }
                    .position(x: width * 0.5, y: height * 0.48)
                
                IconButton(imageName: "dog", size: width * 0.22) {}
                    .position(x: width * 0.8, y: height * 0.46)
                
                IconButton(imageName: "letter", size: width * 0.18) {
                    showCheckInsSheet = true
                }
                    .position(x: width * 0.38, y: height * 0.72)
                
                IconButton(imageName: "coffee-plant", size: width * 0.2) {}
                    .position(x: width * 0.75, y: height * 0.75)
                
                IconButton(imageName: "love-letter", size: width * 0.17) {
                    showLettersSheet = true
                }
                    .position(x: width * 0.18, y: height * 0.85)
            }
        }
    }
}

struct IconButton: View {
    let imageName: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    MomentoHomeView()
        .environmentObject(PairingViewModel())
}
