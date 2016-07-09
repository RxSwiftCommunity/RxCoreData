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

public final class FetchedResultsControllerEntityObserver : NSObject {
	
	typealias Observer = AnyObserver<[NSManagedObject]>
	
	let observer: Observer
	let disposeBag = DisposeBag()
	private let frc: NSFetchedResultsController
	private let subscriberContext: NSManagedObjectContext
	private let observingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
	
	init(observer: Observer, fetchRequest: NSFetchRequest, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
		self.observer = observer
		self.subscriberContext = context
		self.observingContext.parentContext = context
		self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: observingContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
		super.init()
		
		// TODO: Implement `automaticallyMergesChangesFromParent` whit iOs 10, instead of using NSManagedObjectContextDidSaveNotification
		NSNotificationCenter.defaultCenter()
			.rx_notification(NSManagedObjectContextDidSaveNotification, object: self.subscriberContext)
			.subscribeNext() {
				self.observingContext.mergeChangesFromContextDidSaveNotification($0)
			}
			.addDisposableTo(disposeBag)
		
		self.observingContext.performBlock {
			self.frc.delegate = self
			
			do {
				try self.frc.performFetch()
			} catch let e {
				observer.on(.Error(e))
			}
			
			self.sendNextElement()
		}
	}
	
	private func sendNextElement() {
		self.observingContext.performBlock {
			let entities = (self.frc.fetchedObjects as? [NSManagedObject]) ?? []
			self.subscriberContext.performBlock({
				let mappedEntities = entities.map { self.subscriberContext.objectWithID($0.objectID)}
				self.observer.on(.Next(mappedEntities))
			})
		}
	}
	
}

extension FetchedResultsControllerEntityObserver : NSFetchedResultsControllerDelegate {
	
	public func controllerDidChangeContent(controller: NSFetchedResultsController) {
		sendNextElement()
	}
	
}

extension FetchedResultsControllerEntityObserver : Disposable {
	
	public func dispose() {
		frc.delegate = nil
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
}
