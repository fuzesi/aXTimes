//
//  NSManagedObjectContext+BatchDeletes.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 17/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func batchDeleteEntities<T: NSManagedObject>(ofType type: T.Type) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type.self))
        if #available(iOS 9.0, *) {
            let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            let result = try execute(request) as? NSBatchDeleteResult
            if let objectIDArray = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDArray]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
            }
        } else {
            fetchRequest.includesPropertyValues = false
            let results = try fetch(fetchRequest)
            if let actualResults = results as? [NSManagedObject], !actualResults.isEmpty {
                actualResults.forEach { delete($0) }
            }
        }
    }
}
