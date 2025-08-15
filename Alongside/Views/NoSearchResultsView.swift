//
//  NoSearchResultsView.swift
//  Movie Explorer - No search results view for empty search queries
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

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