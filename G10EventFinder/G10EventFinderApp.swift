//
//  G10EventFinderApp.swift
//  G10EventFinder
//
//  Created by Graphic on 2023-07-07.
//

import SwiftUI

@main
struct G10EventFinderApp: App {
    let persistenceController = PersistenceController.shared
    let locationHelper = LocationHelper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationHelper)
        }
    }
}
