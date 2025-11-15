//
//  Created by Iftekhar Anwar on 13/11/25.
//

import SwiftUI

struct CartoonDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        let day = Calendar.current.component(.day, from: date)
        
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? Color(hex: "FFADAD") :
                      isToday ? Color(hex: "FFD6A5") :
                      Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 2)
                .scaleEffect(isSelected ? 1.05 : 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color(hex: "FF6B6B") : Color.clear, lineWidth: 2)
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
            
            Text("\(day)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(isSelected ? .white : .black)
                .scaleEffect(isSelected ? 1.2 : 1)
                .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
        .frame(height: 50)
    }
}
