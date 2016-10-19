//
//  FetchedResultsControllerEntityObserver.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 5/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

public final class FetchedResultsControllerEntityObserver<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
	
	typealias Observer = AnyObserver<[T]>
	
	fileprivate let observer: Observer
	private let disposeBag = DisposeBag()
	fileprivate let frc: NSFetchedResultsController<T>
	private let subscriberContext: NSManagedObjectContext
	private let observingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
	
	init(observer: Observer,
	     fetchRequest: NSFetchRequest<T>,
	     managedObjectContext: NSManagedObjectContext,
	     sectionNameKeyPath: String?,
	     cacheName: String?) {
		self.observer = observer
		self.subscriberContext = managedObjectContext
		self.observingContext.parent = managedObjectContext
		self.frc = NSFetchedResultsController(fetchRequest: fetchRequest,
		                                      managedObjectContext: observingContext,
		                                      sectionNameKeyPath: sectionNameKeyPath,
		                                      cacheName: cacheName)
		super.init()
		
        if #available(iOS 10.0, *) {
            self.observingContext.automaticallyMergesChangesFromParent = true
        } else {
            NotificationCenter.default
                .rx.notification(NSNotification.Name.NSManagedObjectContextDidSave, object: self.subscriberContext)
                .subscribeNext() { [weak self] in
                    self?.observingContext.mergeChanges(fromContextDidSave: $0)
                }
                .addDisposableTo(disposeBag)
        }

		
		self.observingContext.perform {
			self.frc.delegate = self
			
			do {
				try self.frc.performFetch()
                self.sendNextElement()
			} catch let e {
				observer.on(.error(e))
			}
		}
	}
	
	private func sendNextElement() {
        self.observingContext.perform {
			let entities = self.frc.fetchedObjects ?? []
            
			self.subscriberContext.perform {
				let mappedEntities = entities.flatMap { self.subscriberContext.object(with: $0.objectID) as? T}
				self.observer.on(.next(mappedEntities))
			}
		}
	}
    
    //If move this to extension method won't be called by delegate
    @objc
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }
}

extension FetchedResultsControllerEntityObserver : Disposable {
	
	public func dispose() {
		frc.delegate = nil
		NotificationCenter.default.removeObserver(self)
	}
	
}
