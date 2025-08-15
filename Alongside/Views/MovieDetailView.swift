//
//  MovieDetailView.swift
//  Movie Explorer - Detailed movie view with full information and hero image layout
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: MovieResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                // Hero Section with Backdrop
                ZStack(alignment: .topLeading) {
                    OfflineAsyncImage(
                        url: URL(string: movie.fullBackdropURL ?? movie.fullPosterURL ?? ""),
                        movieId: movie.id,
                        imageType: movie.fullBackdropURL != nil ? .backdrop : .poster
                    ) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .overlay {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                    }
                    .frame(width: geometry.size.width, height: 300)
                    .clipped()
                    
                    // Gradient Overlay
                    LinearGradient(
                        colors: [Color.black.opacity(0.6), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geometry.size.width, height: 300)
                    
                    // Back Button
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.4))
                        )
                    }
                    .padding(.top, 50)
                    .padding(.leading, 16)
                }
                
                // Movie Information
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Year
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(movie.formattedReleaseYear)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(movie.formattedVoteAverage)
                                    .fontWeight(.semibold)
                                Text("(\(movie.voteCount))")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Overview
                    if let overview = movie.overview, !overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(overview)
                                .font(.body)
                                .lineSpacing(4)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Movie Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading)
                        ], spacing: 12) {
                            MovieStatView(title: "Release Date", value: formattedReleaseDate)
                            MovieStatView(title: "Rating", value: "\(movie.formattedVoteAverage)/10")
                            MovieStatView(title: "Votes", value: "\(movie.voteCount)")
                            MovieStatView(title: "Popularity", value: String(format: "%.1f", movie.popularity))
                        }
                    }
                    
                    // Poster Section
                    if let posterURL = movie.fullPosterURL {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Poster")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            OfflineAsyncImage(
                                url: URL(string: posterURL),
                                movieId: movie.id,
                                imageType: .poster
                            ) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay {
                                        ProgressView()
                                    }
                            }
                            .frame(maxWidth: min(200, geometry.size.width * 0.6))
                            .cornerRadius(12)
                            .shadow(radius: 8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: geometry.size.width)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
    
    private var formattedReleaseDate: String {
        guard let releaseDate = movie.releaseDate,
              !releaseDate.isEmpty else { return "Unknown" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: releaseDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .long
            return outputFormatter.string(from: date)
        }
        
        return releaseDate
    }
}

struct MovieStatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    MovieDetailView(movie: MovieResult(
        id: 1,
        title: "Sample Movie",
        overview: "This is a sample movie overview that describes the plot and main characters of the movie in detail.",
        releaseDate: "2023-12-01",
        posterPath: nil,
        backdropPath: nil,
        voteAverage: 7.5,
        voteCount: 1250,
        adult: false,
        popularity: 125.5,
        originalLanguage: "en",
        originalTitle: "Sample Movie",
        genreIds: [28, 12],
        video: false
    ))
}