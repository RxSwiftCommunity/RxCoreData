//
//  NSManagedObject+Extensions.swift
//  RxCoreData_Tests
//
//  Created by Krunoslav Zaher on 7/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    class func new(in managedObjectContext: NSManagedObjectContext) -> Self {
        return generateObject(type: self, in: managedObjectContext)
    }

    private class func generateObject<T>(type: T.Type, in managedObjectContext: NSManagedObjectContext) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: managedObjectContext) as! T
    }

}
