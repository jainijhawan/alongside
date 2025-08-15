//
//  Movie+CoreDataProperties.swift
//  Movie Explorer - Core Data properties for Movie entity
//
//  Created by Jai Nijhawan on 15/08/25.
//

import Foundation
import CoreData

extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int32
    @NSManaged public var adult: Bool
    @NSManaged public var popularity: Double

}