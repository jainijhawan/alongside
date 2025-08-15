//
//  PersistenceController.swift
//  Movie Explorer - Core Data persistence manager for offline movie storage
//
//  Created by Jai Nijhawan on 15/08/25.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let sampleMovie = Movie(context: viewContext)
        sampleMovie.id = 1
        sampleMovie.title = "Sample Movie"
        sampleMovie.overview = "This is a sample movie for preview"
        sampleMovie.releaseDate = "2023-01-01"
        sampleMovie.voteAverage = 7.5
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create managed object model programmatically
        let model = NSManagedObjectModel()
        
        // Create Movie entity
        let movieEntity = NSEntityDescription()
        movieEntity.name = "Movie"
        movieEntity.managedObjectClassName = "Movie"
        
        // Create attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .integer32AttributeType
        idAttribute.isOptional = false
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = true
        
        let overviewAttribute = NSAttributeDescription()
        overviewAttribute.name = "overview"
        overviewAttribute.attributeType = .stringAttributeType
        overviewAttribute.isOptional = true
        
        let releaseDateAttribute = NSAttributeDescription()
        releaseDateAttribute.name = "releaseDate"
        releaseDateAttribute.attributeType = .stringAttributeType
        releaseDateAttribute.isOptional = true
        
        let posterPathAttribute = NSAttributeDescription()
        posterPathAttribute.name = "posterPath"
        posterPathAttribute.attributeType = .stringAttributeType
        posterPathAttribute.isOptional = true
        
        let backdropPathAttribute = NSAttributeDescription()
        backdropPathAttribute.name = "backdropPath"
        backdropPathAttribute.attributeType = .stringAttributeType
        backdropPathAttribute.isOptional = true
        
        let voteAverageAttribute = NSAttributeDescription()
        voteAverageAttribute.name = "voteAverage"
        voteAverageAttribute.attributeType = .doubleAttributeType
        voteAverageAttribute.isOptional = false
        
        let voteCountAttribute = NSAttributeDescription()
        voteCountAttribute.name = "voteCount"
        voteCountAttribute.attributeType = .integer32AttributeType
        voteCountAttribute.isOptional = false
        
        let adultAttribute = NSAttributeDescription()
        adultAttribute.name = "adult"
        adultAttribute.attributeType = .booleanAttributeType
        adultAttribute.isOptional = false
        
        let popularityAttribute = NSAttributeDescription()
        popularityAttribute.name = "popularity"
        popularityAttribute.attributeType = .doubleAttributeType
        popularityAttribute.isOptional = false
        
        movieEntity.properties = [
            idAttribute, titleAttribute, overviewAttribute, releaseDateAttribute,
            posterPathAttribute, backdropPathAttribute, voteAverageAttribute,
            voteCountAttribute, adultAttribute, popularityAttribute
        ]
        
        model.entities = [movieEntity]
        
        container = NSPersistentContainer(name: "MovieExplorer", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}