# Movie Explorer 🎬

A SwiftUI app for exploring movies with offline support using TMDb API and Core Data.

## Features

### Core Movie Browsing
- **Popular Movies Grid**: Browse trending movies in a responsive 2-column grid layout
- **Infinite Scrolling**: Automatically loads more movies as you scroll to the bottom
- **Movie Posters**: High-quality movie posters with elegant placeholder loading states
- **Movie Details**: Rich detail view with backdrop images, plot overview, ratings, and metadata
- **Release Information**: Movie release dates, vote averages, and popularity scores

### Search & Discovery
- **Real-time Search**: Instant movie search with debounced API calls
- **Search Loading States**: Centered loading indicator during search operations
- **No Results Feedback**: User-friendly "no results" screen with helpful suggestions
- **Search Result Highlighting**: Clear display of search queries and results

### Offline Experience
- **Complete Offline Support**: Browse cached movies without internet connection
- **Local Image Storage**: Movie posters and backdrops stored locally using movie IDs
- **Offline Indicators**: Visual "Offline Mode" banner when disconnected
- **Smart Cache Management**: Automatic cache size limiting to 50 movies maximum
- **Cache Prioritization**: Keeps most popular movies when cache limit is exceeded

### Network & Connectivity
- **Auto-refresh on Reconnection**: Instantly updates content when internet is restored
- **Network Status Monitoring**: Real-time connection state detection
- **Seamless Online/Offline Transitions**: Smooth switching between network states
- **Intelligent Data Loading**: Prioritizes cached content when network is slow

### User Interface & Experience
- **SwiftUI Design**: Modern, native iOS interface with smooth animations
- **Pull-to-Refresh**: Standard iOS gesture for manual content refresh  
- **Keyboard Dismissal**: Automatic keyboard hiding when scrolling
- **Loading States**: Professional loading indicators for all operations
- **Error Handling**: Graceful error messages and retry options
- **Responsive Layout**: Optimized for different device sizes and orientations

### Performance & Storage
- **Image Caching**: Local storage of movie images with automatic cleanup
- **Background Processing**: Non-blocking Core Data operations
- **Memory Management**: Efficient image loading and caching strategies
- **Storage Optimization**: Intelligent cache eviction based on movie popularity

## Setup

1. Open `Alongside.xcodeproj` in Xcode
2. Build and run (⌘+R)

## Architecture

- **MVVM Pattern**: Clean separation with ViewModels
- **Repository Pattern**: Handles network and local storage
- **Core Data**: Local caching and offline support
- **SwiftUI + Async/Await**: Modern UI and concurrency

## File Structure

```
Alongside/
├── Models/
│   └── MovieModel.swift
├── Services/
│   ├── NetworkService.swift
│   └── ImageStorageService.swift
├── Repositories/
│   └── MovieRepository.swift
├── ViewModels/
│   └── MovieListViewModel.swift
├── Views/
│   ├── MovieListView.swift
│   ├── MovieDetailView.swift
│   ├── MovieCardView.swift
│   ├── OfflineAsyncImage.swift
│   ├── EmptyStateView.swift
│   ├── NoSearchResultsView.swift
│   ├── LoadingView.swift
│   └── SearchLoadingView.swift
└── Core/Data/
    ├── PersistenceController.swift
    ├── Movie+CoreDataClass.swift
    └── Movie+CoreDataProperties.swift
```

## Requirements

- Xcode 15.0+
- iOS 16.0+
- Swift 5.9+