//
//  FriendsListView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-13.
//

import SwiftUI
import CoreData

struct FriendsListView: View {
    
    @Binding var currentUser : String
    
    @Environment(\.managedObjectContext) private var viewContext
    
    //TODO: Fetchrequest here

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Friend.userEmail, ascending: true)], animation: .default)
    var fetchedResults: FetchedResults<Friend>
    
    @State private var friendList: [Friend] = []
    
    var body: some View {
        NavigationView{
            
        VStack{
            Text("My Friends").font(.title2)
            if(friendList.isEmpty){
                List{
                    Text("Your friends list is empty!")
                }
            }else{
                List{
                    ForEach(friendList, id:\.name){ currFriend in
                        HStack{
//                            AsyncImage(
//                                url: URL(string:currEvent.png),
//                                content: { image in
//                                    image.resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                         .frame(maxWidth: 100)
////                                         .padding(5)
//                                },
//                                placeholder: {
//                                    ProgressView().padding(10)
//                                }
//                            ).border(Color.black)
                            VStack(alignment: .leading){
                                Text("\(currFriend.name)").bold()
                                Text("\(currFriend.friendEmail)")
                            }
                        }
                    }//forEach
                    .onDelete(perform: deleteCurrentItem)
                }//list
            }
        }//vstack
        .onAppear(){
            updateFetchRequest()
        }
        .toolbar {
            ToolbarItemGroup(placement:.navigationBarTrailing){
                
                // button to reset everything to default
                Button {
                    resetData()
                } label: {
                    Image(systemName: "repeat")
                }
                
                // built in edit button (used to delete individual items)
                EditButton()
            }
        }//toolbar
            
        }//navView
        
    }//body
    
    private func resetData() {
       for friend in friendList {
           viewContext.delete(friend)
       }
        // persist changes
           do {
               try viewContext.save()
           } catch {}
           
        updateFetchRequest()
       }
    
    private func updateFetchRequest() {
        let fetchRequest: NSFetchRequest<Friend> = Friend.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Friend.userEmail, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", currentUser)
        
        do {
            friendList = try viewContext.fetch(fetchRequest)
        } catch {
            // Handle the error
        }
    } // updatefetchreq - fxn
    
    private func deleteCurrentItem(offsets: IndexSet) {
       print("Deleting current item")
       
       // 1. get a reference to the item in the list that should be deleted
       for index in offsets {
           let FriendToDelete = friendList[index]
           // 2. delete it from core data
           viewContext.delete(FriendToDelete)
       }
              
       // 3. perist your changes
       do {
           try viewContext.save()
       }
       catch {
           print("Error occured!")
       }
   } // deleteCurrentItem - fxn
}

//struct FriendsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendsListView()
//    }
//}
