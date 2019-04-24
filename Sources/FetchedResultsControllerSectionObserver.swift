import Foundation
import CoreData
import RxSwift

public final class FetchedResultsControllerSectionObserver<T: NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
    
    typealias Observer = AnyObserver<[NSFetchedResultsSectionInfo]>
    
    private let observer: Observer
    private let frc: NSFetchedResultsController<T>
    
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
    
    private func sendNextElement() {
        let sections = self.frc.sections ?? []
        observer.on(.next(sections))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sendNextElement()
    }
    
    public func dispose() {
        frc.delegate = nil
    }
}

extension FetchedResultsControllerSectionObserver : Disposable { }
