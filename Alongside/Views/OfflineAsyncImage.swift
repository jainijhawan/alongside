//
//  OfflineAsyncImage.swift
//  Movie Explorer - Custom AsyncImage with offline support using locally stored images
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI

struct OfflineAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let movieId: Int
    private let imageType: ImageStorageService.ImageType
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        movieId: Int,
        imageType: ImageStorageService.ImageType,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.movieId = movieId
        self.imageType = imageType
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard image == nil else { return }
        
        isLoading = true
        
        // First try to get from local storage
        if let storedImage = ImageStorageService.shared.getStoredImage(movieId: movieId, imageType: imageType) {
            self.image = storedImage
            isLoading = false
            return
        }
        
        // If not stored locally and we have a URL, try to download
        guard let url = url else {
            isLoading = false
            return
        }
        
        // Download and store the image
        if let downloadedImage = await ImageStorageService.shared.downloadAndStoreImage(
            from: url.absoluteString,
            movieId: movieId,
            imageType: imageType
        ) {
            self.image = downloadedImage
        }
        
        isLoading = false
    }
}

// MARK: - Convenience Initializers

extension OfflineAsyncImage where Content == Image, Placeholder == AnyView {
    init(url: URL?, movieId: Int, imageType: ImageStorageService.ImageType) {
        self.init(
            url: url,
            movieId: movieId,
            imageType: imageType
        ) { image in
            image
        } placeholder: {
            AnyView(
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: imageType == .poster ? "photo" : "photo.fill")
                            .foregroundColor(.gray)
                    }
            )
        }
    }
}

extension OfflineAsyncImage where Content == Image {
    init(
        url: URL?,
        movieId: Int,
        imageType: ImageStorageService.ImageType,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.init(
            url: url,
            movieId: movieId,
            imageType: imageType
        ) { image in
            image
        } placeholder: {
            placeholder()
        }
    }
}