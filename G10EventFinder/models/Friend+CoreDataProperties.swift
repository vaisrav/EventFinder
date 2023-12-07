//
//  Friend+CoreDataProperties.swift
//  G10EventFinder
//
//  Created by super on 2023-07-13.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var name: String
    @NSManaged public var userEmail: String
    @NSManaged public var friendEmail: String

}

extension Friend : Identifiable {

}
