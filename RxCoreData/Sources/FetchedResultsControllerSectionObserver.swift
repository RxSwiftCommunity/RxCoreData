//
//  FetchedResultsControllerSectionObserver.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 5/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

public final class FetchedResultsControllerSectionObserver<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
    
    typealias Observer = AnyObserver<[NSFetchedResultsSectionInfo]>
    
    let observer: Observer
    let frc: NSFetchedResultsController<T>
    
    init(observer: Observer, frc: NSFetchedResultsController<T>) {
        self.observer = observer
        self.frc = frc
        
        super.init()
        
        self.frc.delegate = self
        
        do {
            try self.frc.performFetch()
        } catch let e {
            observer.on(.error(e))
        }
        
        sendNextElement()
    }
    
    fileprivate func sendNextElement() {
        let sections = self.frc.sections ?? []
        observer.on(.next(sections))
    }
    
    @objc
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }
}

extension FetchedResultsControllerSectionObserver : Disposable {
    
    public func dispose() {
        frc.delegate = nil
    }
    
}
