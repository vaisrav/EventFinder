//
//  MySavedEvent+CoreDataProperties.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//
//

import Foundation
import CoreData


extension MySavedEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MySavedEvent> {
        return NSFetchRequest<MySavedEvent>(entityName: "MySavedEvent")
    }

    @NSManaged public var name: String
    @NSManaged public var userEmail: String
    @NSManaged public var id: UUID
    @NSManaged public var price: String
    @NSManaged public var datetime: String
    @NSManaged public var venueName: String
    @NSManaged public var png: String

}

extension MySavedEvent : Identifiable {

}
