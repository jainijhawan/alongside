//
//  SearchLoadingView.swift
//  Movie Explorer - Search loading overlay view for search operations
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

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