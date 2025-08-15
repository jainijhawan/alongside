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


#Preview {
    MovieListView()
}
