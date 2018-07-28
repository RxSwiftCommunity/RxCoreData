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

public final class FetchedResultsControllerEntityObserver<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
	
	typealias Observer = AnyObserver<[T]>
	
	fileprivate let observer: Observer
	fileprivate let disposeBag = DisposeBag()
	fileprivate let frc: NSFetchedResultsController<T>
	
	
	init(observer: Observer, fetchRequest: NSFetchRequest<T>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName: String?) {
		self.observer = observer
		

		self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
		super.init()
		
		context.perform {
			self.frc.delegate = self
			
			do {
				try self.frc.performFetch()
			} catch let e {
				observer.on(.error(e))
			}
			
			self.sendNextElement()
		}
	}
	
	fileprivate func sendNextElement() {
		self.frc.managedObjectContext.perform {
			let entities = self.frc.fetchedObjects ?? []
			self.observer.on(.next(entities))
		}
	}
	
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		sendNextElement()
	}
}

extension FetchedResultsControllerEntityObserver : Disposable {
	
	public func dispose() {
		frc.delegate = nil
	}
	
}
