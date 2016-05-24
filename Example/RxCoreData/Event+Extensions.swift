//
//  Event+Extensions.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 5/19/16.
//  Copyright © 2016 Scott Gardner. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
}

extension Event : Equatable { }

extension Event : IdentifiableType {
    typealias Identity = String
    
    var identity: Identity { return id }
}

extension Event : Persistable {
    
    static var entityName: String {
        return "Event"
    }
    
    static var primaryAttributeName: String {
        return "id"
    }
    
    init(entity: NSManagedObject) {
        id = entity.valueForKey("id") as! String
        date = entity.valueForKey("date") as! NSDate
    }
    
    func update(entity: NSManagedObject) {
        entity.setValue(id, forKey: "id")
        entity.setValue(date, forKey: "date")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
