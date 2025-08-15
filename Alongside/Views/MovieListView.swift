//
//  MovieListView.swift
//  Movie Explorer - Main movie list view with search, offline support, and pull-to-refresh
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection Status Banner
                if !viewModel.isOnline {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.white)
                        Text("Offline Mode")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                }
                
                // Movie List
                if filteredMovies.isEmpty && !viewModel.isLoading && !viewModel.isSearching {
                    if searchText.isEmpty {
                        EmptyStateView(
                            isOnline: viewModel.isOnline,
                            onRetry: {
                                Task {
                                    await viewModel.loadMovies(forceRefresh: true)
                                }
                            }
                        )
                    } else {
                        NoSearchResultsView(searchQuery: searchText)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredMovies) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    MovieCardView(movie: movie)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    // Load more movies when approaching the end
                                    if searchText.isEmpty && movie == filteredMovies.last {
                                        Task {
                                            await viewModel.loadMoreMovies()
                                        }
                                    }
                                }
                            }
                            
                            // Loading more indicator
                            if viewModel.isLoadingMore && searchText.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .padding()
                                        Text("Loading more...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.loadMovies(forceRefresh: true)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Movie Explorer")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search movies...")
            .onChange(of: searchText) { _, newValue in
                viewModel.searchMovies(query: newValue)
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.isSearching && !searchText.isEmpty {
                    SearchLoadingView()
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onReceive(viewModel.$errorMessage) { errorMessage in
                if let errorMessage = errorMessage {
                    alertMessage = errorMessage
                    showingAlert = true
                }
            }
        }
        .task {
            await viewModel.loadMovies()
        }
    }
    
    private var filteredMovies: [MovieResult] {
        if searchText.isEmpty {
            return viewModel.movies
        } else {
            return viewModel.searchResults
        }
    }
}

// MARK: - Supporting Views

struct MovieCardView: View {
    let movie: MovieResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            OfflineAsyncImage(
                url: URL(string: movie.fullPosterURL ?? ""),
                movieId: movie.id,
                imageType: .poster
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(movie.formattedReleaseYear)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(movie.formattedVoteAverage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct EmptyStateView: View {
    let isOnline: Bool
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isOnline ? "film" : "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(isOnline ? "No Movies Found" : "No Offline Content")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(isOnline ?
                 "Unable to load movies at the moment." :
                 "Connect to the internet to browse movies.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if isOnline {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct NoSearchResultsView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                Text("No movies found for")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("\"\(searchQuery)\"")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Text("Try searching with different keywords or check your spelling.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading Movies...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

struct SearchLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Searching...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

#Preview {
    MovieListView()
}
