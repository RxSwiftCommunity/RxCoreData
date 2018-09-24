//
//  ManagedObjectContextNotificationObserver.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 7/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

public struct CoreDataChangeEvent {
    public let inserted: Set<NSManagedObject>
    public let updated: Set<NSManagedObject>
    public let deleted: Set<NSManagedObject>
    public let refreshed: Set<NSManagedObject>
}

class ManagedObjectContextNotificationObserver {

    typealias Observer = AnyObserver<CoreDataChangeEvent>

    private let managedObjectContext: NSManagedObjectContext
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var notificationObserver: NSObjectProtocol?
    private let observer: Observer

    init(observer: Observer, managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
        self.observer = observer

        notificationObserver = NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                                      object: nil,
                                                                      queue: nil) { [weak self] (notification) in
                                                                        self?.contextObjectsDidChange(notification)
        }
    }

    private func contextObjectsDidChange(_ notification: Notification) {
        guard let incomingContext = notification.object as? NSManagedObjectContext,
            let persistentStoreCoordinator = persistentStoreCoordinator,
            let incomingPersistentStoreCoordinator = incomingContext.persistentStoreCoordinator,
            persistentStoreCoordinator == incomingPersistentStoreCoordinator else {
                return
        }

        let changeEvent = CoreDataChangeEvent(inserted: notification.coreDataInsertions,
                                              updated: notification.coreDataUpdates,
                                              deleted: notification.coreDataDeletions,
                                              refreshed: notification.coreDataRefreshes)

        observer.onNext(changeEvent)
    }

}

extension ManagedObjectContextNotificationObserver: Disposable {

    public func dispose() {
        notificationObserver = nil
    }

}


private extension Notification {

    var coreDataInsertions: Set<NSManagedObject> {
        return (userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }

    var coreDataUpdates: Set<NSManagedObject> {
        return (userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }

    var coreDataDeletions: Set<NSManagedObject> {
        return (userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }

    var coreDataRefreshes: Set<NSManagedObject> {
        return (userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject>) ?? Set<NSManagedObject>()
    }

}
