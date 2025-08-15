//
//  ImageStorageService.swift
//  Movie Explorer - Local image storage service for offline movie poster and backdrop caching
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation
import UIKit

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let imagesDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        imagesDirectory = documentsDirectory.appendingPathComponent("MovieImages")
        
        // Create images directory if it doesn't exist
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    // MARK: - Public Methods
    
    /// Store image locally using movie ID and image type
    func storeImage(_ image: UIImage, movieId: Int, imageType: ImageType) {
        let filename = generateFilename(movieId: movieId, imageType: imageType)
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data for movie ID: \(movieId)")
            return
        }
        
        do {
            try imageData.write(to: fileURL)
            print("Successfully stored \(imageType.rawValue) image for movie ID: \(movieId)")
        } catch {
            print("Failed to store image for movie ID \(movieId): \(error)")
        }
    }
    
    /// Retrieve stored image using movie ID and image type
    func getStoredImage(movieId: Int, imageType: ImageType) -> UIImage? {
        let filename = generateFilename(movieId: movieId, imageType: imageType)
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Download and store image from URL
    func downloadAndStoreImage(from urlString: String, movieId: Int, imageType: ImageType) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data for movie ID: \(movieId)")
                return nil
            }
            
            // Store the image locally
            storeImage(image, movieId: movieId, imageType: imageType)
            return image
            
        } catch {
            print("Failed to download image for movie ID \(movieId): \(error)")
            return nil
        }
    }
    
    /// Check if image exists locally
    func hasStoredImage(movieId: Int, imageType: ImageType) -> Bool {
        let filename = generateFilename(movieId: movieId, imageType: imageType)
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Remove stored image
    func removeStoredImage(movieId: Int, imageType: ImageType) {
        let filename = generateFilename(movieId: movieId, imageType: imageType)
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Clear all stored images
    func clearAllStoredImages() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
            print("Cleared all stored images")
        } catch {
            print("Failed to clear stored images: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func generateFilename(movieId: Int, imageType: ImageType) -> String {
        return "movie_\(movieId)_\(imageType.rawValue).jpg"
    }
}

// MARK: - Image Type Enum

extension ImageStorageService {
    enum ImageType: String, CaseIterable {
        case poster = "poster"
        case backdrop = "backdrop"
    }
}