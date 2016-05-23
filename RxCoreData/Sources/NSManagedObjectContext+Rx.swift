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
    
    func rx_entities(fetchRequest: NSFetchRequest, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Observable<[NSManagedObject]> {
        return Observable.create { observer in
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            
            let observerAdapter = FetchedResultsControllerEntityObserver(observer: observer, frc: frc)
            
            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }
    
    func rx_sections(fetchRequest: NSFetchRequest, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Observable<[NSFetchedResultsSectionInfo]> {
        return Observable.create { observer in
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
            
            let observerAdapter = FetchedResultsControllerSectionObserver(observer: observer, frc: frc)
            
            return AnonymousDisposable {
                observerAdapter.dispose()
            }
        }
    }
        
}

public extension NSManagedObjectContext {
    
    private func createPersistable<E: Persistable>(type: E.Type = E.self) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(E.entityName, inManagedObjectContext: self)
    }
    
    private func get<P: Persistable>(persistable: P) throws -> NSManagedObject? {
        let fetchRequest = NSFetchRequest(entityName: P.entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", persistable.identity)
        let result = (try self.executeRequest(fetchRequest)) as! NSAsynchronousFetchResult
        return result.finalResult?.first as? NSManagedObject
    }
        
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
    
    func rx_entities<P: Persistable>(type: P.Type = P.self, format: String = "", arguments: [AnyObject]? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Observable<[P]> {
        let fetchRequest = NSFetchRequest(entityName: P.entityName)
        fetchRequest.predicate = NSPredicate(format: format == "" ? "1 = 1" : format, argumentArray: arguments)
        fetchRequest.sortDescriptors = sortDescriptors
        
        return self.rx_entities(fetchRequest)
            .map { entities in
                entities.map(P.init)
        }
    }
    
    func performUpdates(updates: (NSManagedObjectContext) throws -> ()) throws {
        let privateContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext.parentContext = self
        
        try updates(privateContext)
        
        try privateContext.save()
    }
    
    func update<P: Persistable>(persistable: P) throws {
        persistable.update(try get(persistable) ?? self.createPersistable(P.self))
    }
    
}
