# momento
An app for couples that helps them deepen their emotional connection and stay engaged in their relationship through daily check-ins, love notes, and interactive features. 

## Features

- **Letters** - Send heartfelt messages to your partner
- **Music Sharing** - Share songs and create playlists together
- **Love Questions** - Answer fun questions to know each other better
- **Check-ins** - Quick daily updates with your partner
- **Calendar** - Track your shared moments and activities
- **Widgets** - Stay connected right from your home screen

## Screenshots

| Home Screen | Letters | Music |
|-------------|---------|-------|
| <img src="https://github.com/user-attachments/assets/e0e676be-9969-437d-a8c5-bbf2a6ff4ec1" width="350" alt="Screenshot" /> | <img src="https://github.com/user-attachments/assets/f8b22b73-28d7-44b4-8dcf-ce828bf89e43" width="350" alt="Screenshots" /> | <img src="https://github.com/user-attachments/assets/e19a3d32-d40c-4c46-80f9-0fef82b8cd8b" width="350" alt="Screenshot Sim" /> |

| Calendar | Profile | Widget |
|----------|---------|--------|
| <img src="https://github.com/user-attachments/assets/bf13d119-182d-42d9-a4fe-c5bb788ce499" width="350" alt="Screenshots" /> | <img src="https://github.com/user-attachments/assets/0938f728-0f0e-4623-8a76-e545749c1da1" width="350" alt="Screenshots" /> | <img src="https://github.com/user-attachments/assets/668e6413-db26-4b45-a762-fd63d162c701" width="350" alt="Simulator Screenshot" /> |




## Tech Stack

- **SwiftUI** - Modern iOS UI framework
- **Firebase** - Authentication & real-time database
- **WidgetKit** - Home screen widgets

- **MultipeerConnectivity** - Device pairing


## Setup


1. Clone the repository

2. Add your `GoogleService-Info.plist` to the project
3. Open `moments.xcodeproj` in Xcode
4. Build and run

## Firebase Configuration

Update Firebase Security Rules to allow paired users to read each other's data:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /hearts/{heartCode} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Architecture

- **MVVM Pattern** - Clean separation of concerns
- **View Models** - PairingViewModel, LettersViewModel, MusicViewModel, etc.
- **Firebase Manager** - Centralized Firebase operations
- **Shared Data Manager** - Widget data synchronization

## License
MIT License
