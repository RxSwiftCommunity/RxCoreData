//
//  NSManagedObjectContext+Rx.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 5/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

public extension NSManagedObjectContext {
    
    /**
     Executes a fetch request and returns the fetched objects as an `Observable` array of `NSManagedObjects`.
     - parameter fetchRequest: an instance of `NSFetchRequest` to describe the search criteria used to retrieve data from a persistent store
     - parameter sectionNameKeyPath: the key path on the fetched objects used to determine the section they belong to; defaults to `nil`
     - parameter cacheName: the name of the file used to cache section information; defaults to `nil`
     - returns: An `Observable` array of `NSManagedObjects` objects that can be bound to a table view.
     */
    func rx_entities(fetchRequest: NSFetchRequest, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Observable<[NSManagedObject]> {
        return Observable.create { observer in
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            
            let observerAdapter = FetchedResultsControllerEntityObserver(observer: observer, frc: frc)
            
            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }
    
    /**
     Executes a fetch request and returns the fetched section objects as an `Observable` array of `NSFetchedResultsSectionInfo`.
     - parameter fetchRequest: an instance of `NSFetchRequest` to describe the search criteria used to retrieve data from a persistent store
     - parameter sectionNameKeyPath: the key path on the fetched objects used to determine the section they belong to; defaults to `nil`
     - parameter cacheName: the name of the file used to cache section information; defaults to `nil`
     - returns: An `Observable` array of `NSFetchedResultsSectionInfo` objects that can be bound to a table view.
     */
    func rx_sections(fetchRequest: NSFetchRequest, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Observable<[NSFetchedResultsSectionInfo]> {
        return Observable.create { observer in
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            
            let observerAdapter = FetchedResultsControllerSectionObserver(observer: observer, frc: frc)
            
            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }
    
    /**
     Performs transactional update, initiated on a separate managed object context, and propagating thrown errors.
     - parameter updateAction: a throwing update action
     */
    func performUpdate(updateAction: (NSManagedObjectContext) throws -> Void) throws {
        guard self.hasChanges else { return }
        
        let privateContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext.parentContext = self
        
        try updateAction(privateContext)
        
        try privateContext.save()
        
        try self.save()
    }
}

public extension NSManagedObjectContext {
    
    /**
     Creates, inserts, and returns a new `NSManagedObject` instance for the given `Persistable` concrete type (defaults to `Persistable`).
     */
    private func createPersistable<E: Persistable>(type: E.Type = E.self) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(E.entityName, inManagedObjectContext: self)
    }
    
    private func get<P: Persistable>(persistable: P) throws -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: P.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", P.primaryAttributeName, persistable.identity)
        let result = (try self.executeRequest(fetchRequest)) as! NSAsynchronousFetchResult
        return result.finalResult?.first as? NSManagedObject
    }
    
    /**
     Attempts to retrieve  remove a `Persistable` object from a persistent store, and then attempts to commit that change or throws an error if unsuccessful.
     - seealso: `Persistable`
     - parameter persistable: a `Persistable` object
     */
    func delete<P: Persistable>(persistable: P) throws {
        if let entity = try get(persistable) {
            self.deleteObject(entity)
            
            do {
                try entity.managedObjectContext?.save()
            } catch let e {
                print(e)
            }
        }
    }
    
    /**
     Creates and executes a fetch request and returns the fetched objects as an `Observable` array of `Persistable`.
     - parameter type: the `Persistable` concrete type; defaults to `Persistable`
     - parameter format: the format string for the predicate; defaults to `""`
     - parameter arguments: the arguments to substitute into `format`, in the order provided; defaults to `nil`
     - parameter sortDescriptors: the sort descriptors for the fetch request; defaults to `nil`
     - returns: An `Observable` array of `Persistable` objects that can be bound to a table view.
     */
    func rx_entities<P: Persistable>(type: P.Type = P.self, format: String = "", arguments: [AnyObject]? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[P]> {
        let fetchRequest = NSFetchRequest(entityName: P.entityName)
        fetchRequest.predicate = NSPredicate(format: format == "" ? "1 = 1" : format, argumentArray: arguments)
        fetchRequest.sortDescriptors = sortDescriptors
        
        return self.rx_entities(fetchRequest)
            .map { entities in
                entities.map(P.init)
        }
    }
    
    /**
     Attempts to fetch and update (or create if not found) a `Persistable` instance. Will throw error if fetch fails.
     - parameter persistable: a `Persistable` instance
     */
    func update<P: Persistable>(persistable: P) throws {
        persistable.update(try get(persistable) ?? self.createPersistable(P.self))
    }
    
}
