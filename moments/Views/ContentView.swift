//
//  Created by Iftekhar Anwar on 08/11/25.
//

import SwiftUI

enum Tabs {
    case home, shortcuts, profile
}

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    @EnvironmentObject var pairingViewModel: PairingViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                MomentoHomeView()
            }
            Tab("Calendar", systemImage: "calendar", value: .shortcuts) {
             CalendarView()
            }
            Tab("Profile", systemImage: "person.2.fill", value: .profile) {
                ProfileView()
                    .environmentObject(pairingViewModel)
            }
        }
        .tint(Color(hex: "ED708C"))
    }


}


#Preview {
    ContentView()
        .environmentObject(PairingViewModel())
}

