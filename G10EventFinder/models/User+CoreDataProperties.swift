//
//  User+CoreDataProperties.swift
//  G10EventFinder
//
//  Created by Graphic on 2023-07-07.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String
    @NSManaged public var password: String
    @NSManaged public var contactNum: String
    @NSManaged public var name: String

}

extension User : Identifiable {

}
