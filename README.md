# Movie Explorer 🎬

A SwiftUI app for exploring movies with offline support using TMDb API and Core Data.

## Features

- **Browse Popular Movies**: Grid of popular movies with infinite scrolling
- **Movie Details**: Detailed view with backdrop images, overview, and ratings
- **Offline Support**: View cached movies and images when offline
- **Search**: Search movies by title with real-time results
- **Pull-to-Refresh**: Refresh the movie list

## Setup

1. Open `Alongside.xcodeproj` in Xcode
2. Build and run (⌘+R)

## Architecture

- **MVVM Pattern**: Clean separation with ViewModels
- **Repository Pattern**: Handles network and local storage
- **Core Data**: Local caching and offline support
- **SwiftUI + Async/Await**: Modern UI and concurrency

## Requirements

- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+