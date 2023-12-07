//
//  FavouritesView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import SwiftUI
import CoreData

struct FavouritesView: View {
    
    @Binding var rootScreen : RootView
    @Binding var currentUser : String
    
    @Environment(\.managedObjectContext) private var viewContext
    
    //TODO: Fetchrequest here

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \MySavedEvent.id, ascending: true)], animation: .default)
    var fetchedResults: FetchedResults<MySavedEvent>
    
    @State private var favList: [MySavedEvent] = []
    
    var body: some View {
        NavigationView{
            VStack{
                Text("My Events").font(.title2)
                if(favList.isEmpty){
                    List{
                        Text("Your events list is empty!")
                    }
                }else{
                    List{
                        ForEach(favList, id:\.name){ currEvent in
                            HStack{
                                AsyncImage(
                                    url: URL(string:currEvent.png),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 100)
                                        //                                         .padding(5)
                                    },
                                    placeholder: {
                                        ProgressView().padding(10)
                                    }
                                ).border(Color.black)
                                VStack(alignment: .leading){
                                    Text("\(currEvent.name)").bold().lineLimit(2)
                                    Text("\(currEvent.datetime)")
                                    Text("\(currEvent.venueName)").lineLimit(1)
                                }
                            }
                            //                        HStack{
                            //                            AsyncImage(
                            //                                url: URL(string:currEvent.performers[0].image),
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
                            //                            VStack(alignment:.leading){
                            //                                Text("\(currEvent.name)").bold()
                            //                                Text("\(currEvent.datetime)")
                            //                                Text("\(currEvent.venueName)")
                            //                                Spacer()
                            //                                if let EventPrice = currEvent.stats.price{
                            //                                    Text("$ \(EventPrice)").italic()
                            //                                }else{
                            //                                    Text("NA").italic()
                            //                                }
                            //                            }.frame(height:60)
                            //                            .padding(.horizontal, 5)
                            //                        }//HStack
                            //                        .padding(.vertical)
                            //                        .frame(height: 80)
                        }//forEach
                        .onDelete(perform: deleteCurrentItem)
                    }//list
                }
            }//vstack
            .onAppear(){
                updateFetchRequest()
            }
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button(action: {
                        resetData()
                    }, label: {
                        Image(systemName: "repeat")
                    })
                    EditButton()
                }
            }//toolbar
        }//navView
    }//body
    
    private func resetData() {
       for event in favList {
           viewContext.delete(event)
       }
        // persist changes
           do {
               try viewContext.save()
           } catch {}
           
        updateFetchRequest()
       }

    
    private func updateFetchRequest() {
        let fetchRequest: NSFetchRequest<MySavedEvent> = MySavedEvent.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MySavedEvent.id, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", currentUser)
        
        do {
            favList = try viewContext.fetch(fetchRequest)
        } catch {
            // Handle the error
        }
    }
    
    private func deleteCurrentItem(offsets: IndexSet) {
       print("Deleting current item")
       
       // 1. get a reference to the item in the list that should be deleted
       for index in offsets {
           let EventToDelete = favList[index]
           // 2. delete it from core data
           viewContext.delete(EventToDelete)
       }
              
       // 3. perist your changes
       do {
           try viewContext.save()
       }
       catch {
           print("Error occured!")
       }
   }
}

//struct FavouritesView_Previews: PreviewProvider {
//    static var previews: some View {
//        FavouritesView()
//    }
//}
