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

public final class FetchedResultsControllerEntityObserver : NSObject {
    
    typealias Observer = AnyObserver<[NSManagedObject]>
    
    let observer: Observer
    let frc: NSFetchedResultsController
    
    init(observer: Observer, frc: NSFetchedResultsController) {
        self.observer = observer
        self.frc = frc
        
        super.init()
        
        self.frc.delegate = self
        
        do {
            try self.frc.performFetch()
        } catch let e {
            observer.on(.Error(e))
        }
        
        sendNextElement()
    }
    
    private func sendNextElement() {
        let entities = (self.frc.fetchedObjects as? [NSManagedObject]) ?? []
        observer.on(.Next(entities))
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
