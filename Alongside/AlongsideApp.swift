//
//  AlongsideApp.swift
//  Movie Explorer - A SwiftUI app for browsing movies with offline support
//
//  Created by Jai Nijhawan on 15/08/25.
//

import SwiftUI
import CoreData

@main
struct AlongsideApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MovieListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
