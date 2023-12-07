//
//  HomeView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationHelper : LocationHelper
    
    @Binding var rootScreen : RootView
    @Binding var currentUser : String
    
    @State var eventslist:[Event] = []
    
    @State var searchText:String = ""
    @State var searchLat:String = ""
    @State var searchLng:String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = "Alert Message"
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Upcoming Events").font(.title2)
                Section{
                    HStack{
                        TextField("Search by City", text: $searchText)
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
                            self.locationHelper.doForwardGeocoding(address: searchText, completionHandler: {
                                    (coordinates, error) in
                                
                                if (error == nil && coordinates != nil){
                                    
                                    self.loadDataFromAPI(lat: String(coordinates!.coordinate.latitude) , lng: String(coordinates!.coordinate.longitude))
                                    
//                                    print(#function, "Lat : \(coordinates?.coordinate.latitude) \n Lng : \(coordinates?.coordinate.longitude)")
                                    self.searchLat = "\(coordinates?.coordinate.latitude)"
                                    self.searchLng = "\(coordinates?.coordinate.longitude)"
//
//                                    print(#function, "searchLat : \(searchLat), searchLng: \(searchLng)")
//                                    self.loadDataFromAPI(lat: searchLat, lng: searchLat)
                                }else{
                                    print("Coordinates for given address is not available")
                                    alertMessage = "Given address is not available"
                                    showAlert = true
                                }
                            })
//                            self.searchByCity()
//                            self.loadDataFromAPI(lat: searchLat, lng: searchLat)
                        }label: {
                                Image(systemName: "magnifyingglass")
                        }.buttonStyle(.borderedProminent)
                    }
                }.padding(.horizontal)
                Section{
                    List{
                        if(eventslist.isEmpty){
                            Text("No events found for this location!")
                        }else{
                            ForEach(eventslist, id:\.id){
                                currEvent in
                                //Each Row UI
                                //                    Section{
                                NavigationLink(destination: EventDetailsView(selectedEvent : currEvent, currentUser: $currentUser)){
                                    HStack{
                                        AsyncImage(
                                            url: URL(string:currEvent.performers[0].image),
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: 100)
                                                //    .padding(5)
                                            },
                                            placeholder: {
                                                ProgressView().padding(10)
                                            }
                                        ).border(Color.black)
                                        VStack(alignment:.leading){
                                            Text("\(currEvent.title)").bold()
                                            Text("\(currEvent.dateFormatter(includeTime: false))")
                                            Spacer()
                                            HStack{
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text("\(Int(currEvent.popularity * 100))%")
                                                Spacer()
                                                if let EventPrice = currEvent.stats.price{
                                                    Text("$ \(EventPrice)").italic()
                                                }else{
                                                    Text("NA").italic()
                                                }
                                            }
                                        }.frame(height:60)
                                            .padding(.horizontal, 5)
                                    }//HStack
                                }//navLink
                                //                        }
                            }//forEach
                        }
                    }//list
                }//section
                
            } //vStack
            .onAppear(){
                self.locationHelper.checkPermission()
                if(searchText == ""){
                    self.loadDataFromAPI(lat: String(self.locationHelper.currentLocation!.coordinate.latitude), lng: String(self.locationHelper.currentLocation!.coordinate.longitude))
                }
            }
            .navigationBarItems(leading: userProfile)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button(action: {
                        //sign out
                    //  TODO: cleared stored current user
                        self.currentUser = ""
                        
                        //dismiss current screen and show login screen
                        self.rootScreen = .Login
                    }, label: {
                        Text("SignOut").foregroundColor(.red)
                        Image(systemName: "power")
                            .foregroundColor(.red)
                    })
                }
            }//toolbar
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(self.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }//alert
        }//navView
    }//body
    
    
    private var userProfile: some View {
        HStack{
            Image(systemName: "person.crop.circle")
                .foregroundColor(.blue)
            Text(currentUser.capitalized.components(separatedBy: "@").first ?? "")
                .foregroundColor(.blue)
        }
    }
    
    func loadDataFromAPI(lat:String = "45.5019", lng:String = "-73.5674"){
        print(#function, "Getting data from API!!")
        print(#function, "Lat: \(lat)\nLng: \(lng)")
        // 1. specify API url
//        let websiteAddress:String = "https://jsonplaceholder.typicode.com/users"
        let websiteAddress:String = "https://api.seatgeek.com/2/events?lat=\(lat)&lon=\(lng)&client_id=MzQ3MjYzMzJ8MTY4ODU4ODM5NS42MzI5Njc1"
        guard let apiURL = URL(string: websiteAddress) else {
            print("ERROR: Cannot convert your api address to an URL object")
            return
        }
        
        // 2. create a network request object
        let request = URLRequest(url:apiURL)
        
        // 3. Using the network request object, connect to the api
        // 4. Handle the results from the API (if any)
        // - deal with any errors
        
        let task = URLSession.shared.dataTask(with: request) {
            (data:Data?, response, error:Error?) in


            //error when connecting to the network
            // to see this error use a url that does not exist
            if error != nil {
                print("ERROR: Network error: \(error)")
                return
            }
            // check if IOS was able to retrieve data from the api
            // if yes, then convert the data to an array of objects
            // if conversion successful, then output it to the console

            if let jsonData = data {
                if let decodedResponse = try? JSONDecoder().decode(EventsResponseObject.self, from: jsonData){
                    DispatchQueue.main.async{
                        print(decodedResponse)
                        
                        //output to user interface
                        self.eventslist = decodedResponse.events
                    }
                }
                else{
                    //something in the api doesnt match what you defined in the object
                    // ex: typing error in the name of attribute
                    print(#function, "ERROR! Error converting data to JSON")
                }
            }
            else{
                print(#function, "Did not receive data from the API")
            }

        }
        task.resume()
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
