//
//  NSManagedObjectContext+Extensions.swift
//  Differentiator
//
//  Created by Evghenii Nicolaev on 7/28/18.
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
