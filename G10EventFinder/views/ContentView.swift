//
//  ContentView.swift
//  G10EventFinder
//
//  Created by Graphic on 2023-07-07.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State private var root : RootView = .Login
    @State var currentUser: String = ""
    
    // The body property contains the structure of our view
    var body: some View {
        NavigationView{
            switch root {
            case .Login:
                SignInView(rootScreen: $root, currentUser: $currentUser)
            case .Home:
                TabView{
                    HomeView(rootScreen: $root, currentUser: $currentUser)
                        .tabItem{
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .padding(.vertical, 10)
                    ProfileView(currentUser: $currentUser)
                        .tabItem{
                            Image(systemName: "magnifyingglass")
                            Text("Search User")
                        }
                        .padding(.vertical, 10)
                    FriendsListView(currentUser: $currentUser)
                        .tabItem{
                            Image(systemName: "person.fill")
                            Text("My friends")
                        }
                        .padding(.vertical, 10)
                    FavouritesView(rootScreen: $root, currentUser: $currentUser)
                        .tabItem {
                            Image(systemName: "heart")
                            Text("My Events")
                        }
                        .padding(.vertical, 10)
                }//tabview
            }// switch
        }//navView
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController(inMemory: true)
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

