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
    typealias T = NSManagedObject
    
    static var entityName: String {
        return "Event"
    }
    
    static var primaryAttributeName: String {
        return "id"
    }
    
    init(entity: T) {
        id = entity.value(forKey: "id") as! String
        date = entity.value(forKey: "date") as! Date
    }
    
    func update(_ entity: T) {
        entity.setValue(id, forKey: "id")
        entity.setValue(date, forKey: "date")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
}
