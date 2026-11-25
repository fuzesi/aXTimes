//
//  Customer+Helper.swift
//  aXTimes
//
//  Created by Christopher Füseschi on 04/04/2017.
//  Copyright © 2017 aXimilate. All rights reserved.
//

import Foundation

extension Customer {
    @objc var sortedProjects: [Project] {
        let sortDescriptor = NSSortDescriptor(key: "name",
                                              ascending: true)
        let projects: [Project] = self.projects?.sortedArray(using: [sortDescriptor]) as! [Project]
        return projects
    }

    @objc var color: UIColor {
        // fallback black
        return UIColor(fromHex: colourAsHex ?? "#000000")
    }
}
