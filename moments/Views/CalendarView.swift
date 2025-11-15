//
//  Created by Iftekhar Anwar on 12/11/25.
//

import SwiftUI
import Combine

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.93, blue: 1.0),
                    Color(red: 0.93, green: 0.97, blue: 1.0)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Button(action: viewModel.previousMonth) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "EC99B0"))
                            .shadow(radius: 2)
                            .scaleEffect(1.1)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(viewModel.monthYearString)
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .shadow(color: .white.opacity(0.7), radius: 2)
                        
                        Capsule()
                            .fill(Color(hex: "FFD6A5"))
                            .frame(width: 120, height: 8)
                            .shadow(radius: 1)
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    Button(action: viewModel.nextMonth) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "EC99B0"))
                            .shadow(radius: 2)
                            .scaleEffect(1.1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                
                HStack(spacing: 10) {
                    ForEach(viewModel.weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "FF9B85"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 12)
                
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 7), spacing: 10) {
                    ForEach(viewModel.days, id: \.self) { dateValue in
                        if let date = dateValue {
                            CartoonDayView(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                                isToday: Calendar.current.isDateInToday(date)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.selectedDate = date
                                }
                            }
                        } else {
                            Color.clear.frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
    }
}

#Preview {
    CalendarView()
}
