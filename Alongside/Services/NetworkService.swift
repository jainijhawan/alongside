//
//  NetworkService.swift
//  Movie Explorer - Network service for TMDb API integration with async/await support
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MovieResponse
    func fetchMovieDetails(id: Int) async throws -> MovieResult
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "06840463d3d25f8933cf00a9753e9ae1"
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNjg0MDQ2M2QzZDI1Zjg5MzNjZjAwYTk3NTNlOWFlMSIsIm5iZiI6MTc0ODM4MzY5MC41MTIsInN1YiI6IjY4MzYzN2NhMzUzNzAxMmEyMjQxNGIxNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.kkRerUQGG_5tolyXhK0p_c0nLNZYqbXosVrbF3LOa0"
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    func fetchPopularMovies(page: Int = 1) async throws -> MovieResponse {
        let endpoint = "/movie/popular"
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    func fetchMovieDetails(id: Int) async throws -> MovieResult {
        let endpoint = "/movie/\(id)"
        let queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        let endpoint = "/search/movie"
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        return try await performRequest(endpoint: endpoint, queryItems: queryItems)
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}