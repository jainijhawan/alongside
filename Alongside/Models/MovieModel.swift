//
//  MovieModel.swift
//  Movie Explorer - Codable models for TMDb API response and local movie data
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation
import CoreData

// MARK: - API Response Models
struct MovieResponse: Codable {
    let page: Int
    let results: [MovieResult]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieResult: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let adult: Bool
    let popularity: Double
    let originalLanguage: String?
    let originalTitle: String?
    let genreIds: [Int]?
    let video: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, popularity, video
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case genreIds = "genre_ids"
    }
    
    // Helper computed properties
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w780\(backdropPath)"
    }
    
    var formattedReleaseYear: String {
        guard let releaseDate = releaseDate,
              !releaseDate.isEmpty else { return "Unknown" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: releaseDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        }
        
        return String(releaseDate.prefix(4))
    }
    
    var formattedVoteAverage: String {
        return String(format: "%.1f", voteAverage)
    }
}

// MARK: - Core Data Extensions
extension Movie {
    static func fromMovieResult(_ result: MovieResult, context: NSManagedObjectContext) -> Movie {
        let movie = Movie(context: context)
        movie.id = Int32(result.id)
        movie.title = result.title
        movie.overview = result.overview ?? ""
        movie.releaseDate = result.releaseDate ?? ""
        movie.posterPath = result.posterPath ?? ""
        movie.backdropPath = result.backdropPath ?? ""
        movie.voteAverage = result.voteAverage
        movie.voteCount = Int32(result.voteCount)
        movie.adult = result.adult
        movie.popularity = result.popularity
        return movie
    }
    
    var movieResult: MovieResult {
        return MovieResult(
            id: Int(self.id),
            title: self.title ?? "",
            overview: self.overview,
            releaseDate: self.releaseDate,
            posterPath: self.posterPath,
            backdropPath: self.backdropPath,
            voteAverage: self.voteAverage,
            voteCount: Int(self.voteCount),
            adult: self.adult,
            popularity: self.popularity,
            originalLanguage: nil, // We're not storing these in Core Data for now
            originalTitle: nil,
            genreIds: nil,
            video: nil
        )
    }
}

