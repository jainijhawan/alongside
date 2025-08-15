//
//  LoadingView.swift
//  Movie Explorer - Main loading overlay view for movie operations
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading Movies...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}