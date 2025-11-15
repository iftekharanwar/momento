//
//  Created by Iftekhar Anwar on 13/11/25.
//

import Foundation
import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var currentMonth: Date = Date()
    
    var weekdays: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    var days: [Date?] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    func nextMonth() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        }
    }
    
    func previousMonth() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        }
    }
}
