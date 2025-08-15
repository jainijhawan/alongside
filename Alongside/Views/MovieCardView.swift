//
//  MovieCardView.swift
//  Movie Explorer - Individual movie card component for grid display
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

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