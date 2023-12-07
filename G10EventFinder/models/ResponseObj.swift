//
//  ResponseObj.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import Foundation


struct Event:Codable {
    var type: String
    var id: Int
    var datetime: String
    var title: String
    var venue: Venue
    var performers: [Performer]
    var popularity: Double
    var isOpen: Bool
    var stats: Stats
    
    //use custom names for properties
    enum CodingKeys:String, CodingKey{
        //propeties to rename
        case datetime = "datetime_utc"
        case isOpen = "is_open"

        // properties we didnt want to rename
        case type
        case id
        case title
        case venue
        case performers
        case popularity
        case stats
    }
    
    func dateFormatter(includeTime: Bool = true) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter
        }()
        
        let displayFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if includeTime {
                formatter.timeStyle = .short
            } else {
                formatter.timeStyle = .none
            }
            return formatter
        }()
        
        if let date = dateFormatter.date(from: self.datetime) {
            return displayFormatter.string(from: date)
        } else {
            return "NA"
        }
    }
}

struct Venue:Codable {
    var name: String
    var postalCode: String
    var address: String? = "NA"
    var city: String
    var location: Location
    
    //use custom names for properties
    enum CodingKeys:String, CodingKey{
        //propeties to rename
        case postalCode = "postal_code"

        // properties we didnt want to rename
        case name
        case city
        case address
        case location
    }
}

struct Location : Codable {
    var lat : Double
    var lon : Double
}

struct Performer:Codable {
    var type: String
    var name: String
    var image: String
}

struct Stats:Codable {
    var price: Int?
    
    //use custom names for properties
    enum CodingKeys:String, CodingKey{
        //propeties to rename
        case price = "average_price"

        // properties we didnt want to rename

    }
}

struct EventsResponseObject:Codable{
    var events: [Event]
}

//struct CurrentUser {
//    var name:String = ""
//}
