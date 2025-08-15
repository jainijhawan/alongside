//
//  EmptyStateView.swift
//  Movie Explorer - Empty state view for when no movies are available
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

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