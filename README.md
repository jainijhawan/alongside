# Movie Explorer 🎬

A modern SwiftUI app for exploring movies with offline support using TMDb API and Core Data.

## Features

### Core Features
- **Browse Popular Movies**: Displays a grid of popular movies with posters, titles, and ratings
- **Movie Details**: Detailed view with backdrop images, overview, ratings, and additional information
- **Offline Support**: Core Data integration for caching movies and browsing offline
- **Search Functionality**: Search movies by title with real-time results
- **Pull-to-Refresh**: Refresh the movie list with a simple pull gesture
- **Network Status**: Visual indicator when offline with graceful fallback to cached data

### Technical Highlights
- **MVVM Architecture**: Clean separation of concerns with ViewModels
- **Repository Pattern**: Centralized data management with network and local storage abstraction
- **Async/Await**: Modern Swift concurrency for smooth, non-blocking operations
- **Core Data**: Robust local storage with automatic background context management
- **Network Monitoring**: Real-time network status detection
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Architecture

The app follows a clean, layered architecture demonstrating senior iOS development practices:

```
Models/
├── MovieModel.swift           # Codable models and Core Data extensions

Services/
├── NetworkService.swift       # TMDb API integration with URLSession

Repositories/
├── MovieRepository.swift      # Repository pattern for data management

ViewModels/
├── MovieListViewModel.swift   # MVVM pattern with Combine integration

Views/
├── MovieListView.swift        # Main movie grid with search and refresh
├── MovieDetailView.swift      # Detailed movie information view

Core/Data/
├── PersistenceController.swift # Core Data stack management
├── MovieExplorer.xcdatamodeld  # Core Data model definition
```

## Setup Instructions

1. **Clone/Download**: Ensure you have the project files in your development environment

2. **Xcode Requirements**: 
   - Xcode 15.0 or later
   - iOS 16.0+ deployment target
   - Swift 5.9+

3. **API Configuration**: 
   The TMDb API credentials are already configured in `NetworkService.swift`. For production apps, these should be stored securely using:
   - Keychain Services
   - Environment variables
   - Configuration files excluded from version control

4. **Build and Run**:
   - Open `Alongside.xcodeproj` in Xcode
   - Select your target device/simulator
   - Build and run (⌘+R)

## Technical Implementation Details

### Data Flow
1. **Online Mode**: App fetches from TMDb API → Caches to Core Data → Displays in UI
2. **Offline Mode**: App loads from Core Data cache → Displays with offline indicator
3. **Search**: Online searches via API, offline searches through local cache

### Key Design Decisions

**Repository Pattern**: Abstracts data source complexity, making it easy to switch between network and local storage. The repository automatically handles online/offline scenarios and provides a clean interface to the ViewModels.

**Core Data with Background Contexts**: All Core Data operations use background contexts to prevent UI blocking. The main context is only used for UI-bound fetch requests, ensuring smooth scrolling and interactions.

**Network Monitoring**: Real-time network status monitoring provides immediate feedback to users and enables intelligent data fetching decisions.

**SwiftUI + Async/Await**: Leverages modern SwiftUI patterns with async/await for clean, readable asynchronous code that's easier to test and maintain.

## Dependencies

- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Apple's object graph and persistence framework  
- **Combine**: Reactive programming for state management
- **Network**: System network path monitoring
- **Foundation**: URLSession for networking

*No third-party dependencies required - built entirely with Apple's frameworks for maximum stability and performance.*

---

**Built with ❤️ using SwiftUI, Core Data, and modern iOS development practices**