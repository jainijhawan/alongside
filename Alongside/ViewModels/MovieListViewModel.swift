//
//  MovieListViewModel.swift
//  Movie Explorer - ViewModel for movie list with MVVM architecture and reactive state management
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation
import Combine

@MainActor
class MovieListViewModel: ObservableObject {
    @Published var movies: [MovieResult] = []
    @Published var searchResults: [MovieResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOnline = true
    
    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    init(repository: MovieRepositoryProtocol? = nil) {
        self.repository = repository ?? MovieRepository()
        
        // Observe network status if repository supports it
        if let movieRepository = self.repository as? MovieRepository {
            movieRepository.$isConnected
                .receive(on: DispatchQueue.main)
                .assign(to: \.isOnline, on: self)
                .store(in: &cancellables)
        }
    }
    
    func loadMovies(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMovies = try await repository.getPopularMovies(page: 1, forceRefresh: forceRefresh)
            movies = fetchedMovies
        } catch {
            errorMessage = error.localizedDescription
            
            // Load cached movies as fallback
            let cachedMovies = await repository.getCachedMovies()
            movies = cachedMovies
        }
        
        isLoading = false
    }
    
    func searchMovies(query: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            do {
                // Add small delay for better UX
                try await Task.sleep(nanoseconds: 3000_000_000) // 0.3 seconds
                
                let results = try await repository.searchMovies(query: query, page: 1)
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                searchResults = results
            } catch {
                // Handle search error silently or show non-intrusive error
                print("Search error: \(error)")
                searchResults = []
            }
        }
    }
    
    func refresh() async {
        await loadMovies(forceRefresh: true)
    }
}
