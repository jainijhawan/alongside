//
//  MovieRepository.swift
//  Movie Explorer - Repository pattern implementation for movie data management with offline support
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation
import CoreData
import Network
import Combine

protocol MovieRepositoryProtocol {
    func getPopularMovies(page: Int, forceRefresh: Bool) async throws -> [MovieResult]
    func getMovieDetails(id: Int) async throws -> MovieResult?
    func searchMovies(query: String, page: Int) async throws -> [MovieResult]
    func getCachedMovies() async -> [MovieResult]
    func isOnline() -> Bool
}

class MovieRepository: ObservableObject, MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let persistenceController: PersistenceController
    private let networkMonitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected = true
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         persistenceController: PersistenceController = PersistenceController.shared) {
        self.networkService = networkService
        self.persistenceController = persistenceController
        self.networkMonitor = NWPathMonitor()
        
        setupNetworkMonitoring()
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    func isOnline() -> Bool {
        return isConnected
    }
    
    // MARK: - Public Methods
    
    func getPopularMovies(page: Int = 1, forceRefresh: Bool = false) async throws -> [MovieResult] {
        if isConnected {
            do {
                let response = try await networkService.fetchPopularMovies(page: page)
                
                // Only clear cache when refreshing page 1
                if page == 1 && forceRefresh {
                    await clearCachedMovies()
                }
                
                await cacheMovies(response.results)
                return response.results
            } catch {
                print("Network request failed: \(error). Loading from cache...")
                if page == 1 {
                    return await getCachedMovies()
                } else {
                    // For subsequent pages, if network fails, return empty array
                    return []
                }
            }
        } else {
            if page == 1 {
                return await getCachedMovies()
            } else {
                // For offline mode, only return results for page 1
                return []
            }
        }
    }
    
    func getMovieDetails(id: Int) async throws -> MovieResult? {
        if let cachedMovie = await getCachedMovie(by: id) {
            return cachedMovie
        }
        
        if isConnected {
            do {
                let movie = try await networkService.fetchMovieDetails(id: id)
                await cacheMovie(movie)
                return movie
            } catch {
                print("Failed to fetch movie details: \(error)")
                throw error
            }
        } else {
            return nil
        }
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> [MovieResult] {
        guard isConnected else {
            return await searchCachedMovies(query: query)
        }
        
        do {
            let response = try await networkService.searchMovies(query: query, page: page)
            return response.results
        } catch {
            print("Search failed: \(error). Searching in cache...")
            return await searchCachedMovies(query: query)
        }
    }
    
    func getCachedMovies() async -> [MovieResult] {
        return await withCheckedContinuation { continuation in
            let context = persistenceController.container.viewContext
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.popularity, ascending: false)]
            
            do {
                let movies = try context.fetch(request)
                let movieResults = movies.map { $0.movieResult }
                continuation.resume(returning: movieResults)
            } catch {
                print("Failed to fetch cached movies: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func cacheMovies(_ movies: [MovieResult]) async {
        await withCheckedContinuation { continuation in
            let context = persistenceController.container.newBackgroundContext()
            context.perform {
                // First, add/update movies
                for movieResult in movies {
                    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", movieResult.id)
                    
                    do {
                        let existingMovies = try context.fetch(fetchRequest)
                        if let existingMovie = existingMovies.first {
                            self.updateMovie(existingMovie, with: movieResult)
                        } else {
                            _ = Movie.fromMovieResult(movieResult, context: context)
                        }
                    } catch {
                        print("Failed to check for existing movie: \(error)")
                        _ = Movie.fromMovieResult(movieResult, context: context)
                    }
                }
                
                // Enforce cache size limit of 50 movies
                self.enforceCacheSizeLimit(in: context)
                
                do {
                    try context.save()
                } catch {
                    print("Failed to save movies: \(error)")
                }
                
                continuation.resume()
            }
        }
        
        // Preload images for offline use
        if isConnected {
            await preloadImages(for: movies)
        }
    }
    
    private func cacheMovie(_ movieResult: MovieResult) async {
        await cacheMovies([movieResult])
    }
    
    private func clearCachedMovies() async {
        await withCheckedContinuation { continuation in
            let context = persistenceController.container.newBackgroundContext()
            context.perform {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Movie.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                    try context.save()
                } catch {
                    print("Failed to clear cached movies: \(error)")
                }
                
                continuation.resume()
            }
        }
    }
    
    private func getCachedMovie(by id: Int) async -> MovieResult? {
        return await withCheckedContinuation { continuation in
            let context = persistenceController.container.viewContext
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)
            request.fetchLimit = 1
            
            do {
                let movies = try context.fetch(request)
                if let movie = movies.first {
                    continuation.resume(returning: movie.movieResult)
                } else {
                    continuation.resume(returning: nil)
                }
            } catch {
                print("Failed to fetch cached movie: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    private func searchCachedMovies(query: String) async -> [MovieResult] {
        return await withCheckedContinuation { continuation in
            let context = persistenceController.container.viewContext
            let request: NSFetchRequest<Movie> = Movie.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.popularity, ascending: false)]
            
            do {
                let movies = try context.fetch(request)
                let movieResults = movies.map { $0.movieResult }
                continuation.resume(returning: movieResults)
            } catch {
                print("Failed to search cached movies: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    private func updateMovie(_ movie: Movie, with result: MovieResult) {
        movie.title = result.title
        movie.overview = result.overview
        movie.releaseDate = result.releaseDate
        movie.posterPath = result.posterPath
        movie.backdropPath = result.backdropPath
        movie.voteAverage = result.voteAverage
        movie.voteCount = Int32(result.voteCount)
        movie.adult = result.adult
        movie.popularity = result.popularity
    }
    
    private func preloadImages(for movies: [MovieResult]) async {
        await withTaskGroup(of: Void.self) { group in
            for movie in movies {
                // Preload poster image
                if let posterURL = movie.fullPosterURL,
                   !ImageStorageService.shared.hasStoredImage(movieId: movie.id, imageType: .poster) {
                    group.addTask {
                        _ = await ImageStorageService.shared.downloadAndStoreImage(
                            from: posterURL,
                            movieId: movie.id,
                            imageType: .poster
                        )
                    }
                }
                
                // Preload backdrop image
                if let backdropURL = movie.fullBackdropURL,
                   !ImageStorageService.shared.hasStoredImage(movieId: movie.id, imageType: .backdrop) {
                    group.addTask {
                        _ = await ImageStorageService.shared.downloadAndStoreImage(
                            from: backdropURL,
                            movieId: movie.id,
                            imageType: .backdrop
                        )
                    }
                }
            }
        }
    }
    
    private func enforceCacheSizeLimit(in context: NSManagedObjectContext) {
        let maxMovies = 50
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.sortDescriptors = [
            // Sort by popularity descending first, then by id ascending for consistency
            NSSortDescriptor(keyPath: \Movie.popularity, ascending: false),
            NSSortDescriptor(keyPath: \Movie.id, ascending: true)
        ]
        
        do {
            let allMovies = try context.fetch(fetchRequest)
            let movieCount = allMovies.count
            
            if movieCount > maxMovies {
                let moviesToDelete = Array(allMovies.dropFirst(maxMovies))
                print("Cache limit exceeded (\(movieCount)/\(maxMovies)). Removing \(moviesToDelete.count) oldest movies.")
                
                // Remove associated images for movies being deleted
                for movie in moviesToDelete {
                    ImageStorageService.shared.removeStoredImage(movieId: Int(movie.id), imageType: .poster)
                    ImageStorageService.shared.removeStoredImage(movieId: Int(movie.id), imageType: .backdrop)
                    context.delete(movie)
                }
                
                print("Cache size after cleanup: \(allMovies.count - moviesToDelete.count) movies")
            }
        } catch {
            print("Failed to enforce cache size limit: \(error)")
        }
    }
    
}