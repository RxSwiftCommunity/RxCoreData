//
//  NSManagedObjectContext+Test.swift
//  RxCoreData_Example
//
//  Created by Evghenii Nicolaev on 7/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    static var test: NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.test])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            fatalError("Failed to initialize in-memory store coordinator")
        }

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return managedObjectContext
    }

}
