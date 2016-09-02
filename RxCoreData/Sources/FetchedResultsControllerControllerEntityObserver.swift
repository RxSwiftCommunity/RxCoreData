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
	
	private let observer: Observer
	private let disposeBag = DisposeBag()
	private let frc: NSFetchedResultsController
	
	init(observer: Observer, fetchRequest: NSFetchRequest, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
		self.observer = observer
		
		self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
		super.init()
		
		context.performBlock {
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
		self.frc.managedObjectContext.performBlock {
			let entities = (self.frc.fetchedObjects as? [NSManagedObject]) ?? []
            self.observer.on(.Next(entities))
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
	}
	
}
