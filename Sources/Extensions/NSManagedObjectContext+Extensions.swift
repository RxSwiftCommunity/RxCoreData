//
//  NSManagedObjectContext+Extensions.swift
//  RxCoreData
//
//  Created by Krunoslav Zaher on 7/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    var relationshipIDs: Set<NSManagedObjectID> {
        var relationshipIDs = Set<NSManagedObjectID>()

        for relationship in entity.relationshipsByName {
            let relationshipObjectIds = objectIDs(forRelationshipNamed: relationship.key)
            relationshipIDs.formUnion(relationshipObjectIds)

            for id in relationshipObjectIds {
                if let object = managedObjectContext?.object(with: id) {
                    relationshipIDs.formUnion(object.relationshipIDs)
                }
            }
        }

        return relationshipIDs
    }

}
