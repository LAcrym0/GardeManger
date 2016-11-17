//
//  DataManager.swift
//  GardeMnager
//
//  Created by Grunt on 17/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject {
    
    public static let shared = DataManager()
    
    public var objectContext: NSManagedObjectContext?
    
    private override init() {
        if let modelURL = Bundle.main.url(forResource: "GardeMnager", withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOf: modelURL) {
                let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                if let dbURL = FileManager.documentURL(childPath: "gardemanger.db") {
                    print(dbURL)
                    _ = try? persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.persistentStoreCoordinator = persistentStoreCoordinator
                    self.objectContext = context
                }
            }
        }
    }
    
}

