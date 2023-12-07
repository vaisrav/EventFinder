//
//  ProfileView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-13.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    // We use the @Environment property wrapper to access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var currentUser : String
    
    @State var searchText:String = ""
    
    @State private var foundUser: User? = nil
    @State private var favList: [MySavedEvent] = []
    @State private var attendees : [MySavedEvent] = []
    
    @State var showAlert:Bool = false
    @State var alertMessage:String = ""
    
    var body: some View {
            VStack(alignment: .leading){
                
                HStack{
                    TextField("Search User", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                        )
                        .font(.headline)
                        .autocapitalization(.none)
                    Button(){
                        self.findUser()
                    }label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    if let user = foundUser {
                        HStack{
                            //image
                            let firstLetter = String(user.name.prefix(1)).lowercased()
                            Image(systemName: "\(firstLetter).circle.fill")
                                .font(.system(size:100))
                            
                            VStack(alignment: .leading){
                                //name
                                Text("\(user.name.capitalized)").font(.largeTitle)
                                
                                //im attending \(number) events!
                                Text("im attending \(favList.count) events!")
                                
                                //add frnd Button
                                Button() {
            //                    TODO: add friend function here
                                    addFriend()
                                } label: {
                                    Text("Add Friend")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.vertical, 30)
                        }
                            
                        //title: user's next event
                        Text("\(user.name.capitalized)'s Next Event : ")
                            .font(.headline)
                        
                        Group{
                            //eventname
                            Text("\(favList[0].name)").padding(.vertical, 5)
                            
                            //date, venue, state
                            HStack{
                                Text("📍")
                                Text("\(favList[0].datetime), \(favList[0].venueName)")
                                    .padding(.vertical, 5)
                            }
                            
                            //event attendees
                            HStack{
//                                ForEach(attendees, id:\.name) {
//                                    attendee in
//                                        Text(attendee.userEmail)
//                                        let firstLetter = String(attendee.userEmail.prefix(1)).lowercased()
//                                        Image(systemName: "\(firstLetter).circle.fill")
//                                            .font(.system(size:30))
//                                        }
                                        Text("\(attendees.count) people are attending this event!")
                                }
                        }//group
                    } else{
//                        Text("User not found")
                    }
                }//vstack
                .padding()
                if (!favList.isEmpty){
                    Spacer()
                }
            }
            .padding()
            .alert(isPresented: $showAlert){
                Alert(
                    title: Text("Message"),
                    message: Text(self.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }//alert
        }
    
    func findUser() {
        // Fetch the user with the provided username from CoreData
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", self.searchText.lowercased())
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                print("User found: \(user.name)")
                foundUser = user
                
                // Fetch the user's first event from attending events with the provided email from CoreData
                let fetchRequest: NSFetchRequest<MySavedEvent> = MySavedEvent.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MySavedEvent.datetime, ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "userEmail == %@", user.email)
                do {
                    favList = try viewContext.fetch(fetchRequest)
                    print(#function, "\(favList.count)")
                    
                    if(favList.count != 0){
                        //Fetch the event's attendees with provided event name
                        let fetchRequest3: NSFetchRequest<MySavedEvent> = MySavedEvent.fetchRequest()
                        fetchRequest3.sortDescriptors = [NSSortDescriptor(keyPath: \MySavedEvent.datetime, ascending: true)]
                        fetchRequest3.predicate = NSPredicate(format: "name == %@", favList[0].name)
                        do {
                            attendees = try viewContext.fetch(fetchRequest3)
                            print(#function, "\(attendees.count)")
                            print(attendees)
                        } catch{
                            //handle error here
                        }
                    }else{
                        print(#function, "User doesnt have saved events")
                    }
                } catch {
                    print(#function, "unable to fetch user's events")
                }
            } else {
                // User not found
                print(#function, "user not found!")
                alertMessage = "No user found! Check email entered."
                showAlert = true
                return
            }
            
        } catch {
            // Error fetching user
            print(#function, "Error fetching user")
        }
    }
    
    func addFriend(){
        // adding friend user
        let fetchRequest: NSFetchRequest<Friend> = Friend.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", currentUser)

        do {
            let myFriends = try viewContext.fetch(fetchRequest)
            if (myFriends.contains(where: {$0.friendEmail == foundUser!.email})){
                print(#function, "Error: Friend already added.")
                self.alertMessage = "Error: User already in your friend list!"
                self.showAlert = true
                return
            }
            // Create a new user object and set its properties
            let newFriend = Friend(context: viewContext)
            newFriend.name = foundUser!.name
            newFriend.friendEmail = foundUser!.email
            newFriend.userEmail = currentUser

            // Save the new user
            try viewContext.save()
            print(#function, "Success! \(foundUser!.name) saved to my Friends.")
            self.alertMessage = "Success! \(foundUser!.name) saved to my Friends."
            self.showAlert = true
        } catch {
            // Error creating user
            print(#function, "Error adding friend!")

        }
    }
    
}
    

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
