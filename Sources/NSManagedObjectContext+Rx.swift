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

public enum CoreDataObserverError: Error {
    case unknown
    case objectDeleted
}

public extension Reactive where Base: NSManagedObjectContext {
    
    /**
     Executes a fetch request and returns the fetched objects as an `Observable` array of `NSManagedObjects`.
     - parameter fetchRequest: an instance of `NSFetchRequest` to describe the search criteria used to retrieve data from a persistent store
     - parameter sectionNameKeyPath: the key path on the fetched objects used to determine the section they belong to; defaults to `nil`
     - parameter cacheName: the name of the file used to cache section information; defaults to `nil`
     - returns: An `Observable` array of `NSManagedObjects` objects that can be bound to a table view.
     */
    func entities<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>,
                                      sectionNameKeyPath: String? = nil,
                                      cacheName: String? = nil) -> Observable<[T]> {
        return Observable.create { observer in

            let observerAdapter = FetchedResultsControllerEntityObserver(observer: observer, fetchRequest: fetchRequest, managedObjectContext: self.base, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)

            return Disposables.create {
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
    func sections<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>,
                                      sectionNameKeyPath: String? = nil,
                                      cacheName: String? = nil) -> Observable<[NSFetchedResultsSectionInfo]> {
        return Observable.create { observer in
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                 managedObjectContext: self.base,
                                                 sectionNameKeyPath: sectionNameKeyPath,
                                                 cacheName: cacheName)
            
            let observerAdapter = FetchedResultsControllerSectionObserver(observer: observer, frc: frc)
            return Disposables.create {
                observerAdapter.dispose()
            }
        }
    }

    /// Observes changes in current context
    ///
    /// - Returns: Signal that captures context change event
    func changes() -> Observable<CoreDataChangeEvent> {
        return Observable.create { observer in

            let notificationObserver = ManagedObjectContextNotificationObserver(observer: observer, managedObjectContext: self.base)

            return Disposables.create {
                notificationObserver.dispose()
            }

        }
    }

    /// Observe changes of provided object in current context. Reacts to all objects in relationship changes as well.
    ///
    /// - Parameter object: NSManagedObject to be observed
    /// - Returns: Signal that return observed object every time some fields are modified
    func entity<T: NSManagedObject>(_ entity: T) -> Observable<T> {
        return changes()
            .flatMap({ changeEvent -> Observable<Bool> in
                let deletedSet = Set(changeEvent.deleted.map({ $0.objectID }))
                guard !deletedSet.contains(entity.objectID) else {
                    throw CoreDataObserverError.objectDeleted
                }

                let interestSet = entity.relationshipIDs.union([ entity.objectID ])
                let changedSet = Set(changeEvent.updated.map({ $0.objectID }))
                return Observable.just(!changedSet.intersection(interestSet).isEmpty)
            })
            .filter { $0 }
            .map { _ in return entity }
    }

    /**
     Performs transactional update, initiated on a separate managed object context, and propagating thrown errors.
     - parameter updateAction: a throwing update action
     */
    func performUpdate(updateAction: (NSManagedObjectContext) throws -> Void) throws {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self.base
        
        try updateAction(privateContext)
        
        guard privateContext.hasChanges else { return }
        
        try privateContext.save()
        
        try self.base.save()
    }
}
