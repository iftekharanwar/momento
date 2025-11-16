//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI

struct CreateOrJoinHeartView: View {
    @Binding var showCreateHeart: Bool
    @Binding var showJoinHeart: Bool
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFB3C6").opacity(0.3))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color(hex: "FFB3C6"))
                }
                
                VStack(spacing: 12) {
                    Text("Grow Your Love")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Create your shared heart or join your partner's")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        showCreateHeart = true
                    }) {
                        Text("Create Heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "FFB3C6"))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    Button(action: {
                        showJoinHeart = true
                    }) {
                        Text("Join Heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "FFB3C6"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical,18)
                            .background(Color.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(hex: "FFB3C6"), lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    CreateOrJoinHeartView(showCreateHeart: .constant(false), showJoinHeart: .constant(false))
}
