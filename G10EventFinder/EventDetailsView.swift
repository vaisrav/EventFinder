//
//  EventDetailsView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import SwiftUI
import MapKit
import CoreData


struct EventDetailsView: View {
    
    // We use the @Environment property wrapper to access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    
    var selectedEvent : Event
    @Binding var currentUser : String
    
    @State var showAlert:Bool = false
    @State var alertMessage:String = ""
    
//    var currentUser:String = "sam@gbc.com"
    
    var body: some View {
        
        //heading
//        Text(selectedEvent.title)
//            .font(.headline)
//            .bold()
        
        Group {
            
            AsyncImage(
                url: URL(string: selectedEvent.performers[0].image),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 200)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                },
                placeholder: {
                    ProgressView()
                }
            )
            
//            images scroll
//
//            ScrollView(.horizontal, showsIndicators: true) {
//                LazyHStack(alignment: .bottom) {
//                    ForEach(selectedEvent.performers, id: \.name) { photo in
//                        AsyncImage(
//                            url: URL(string: photo.image),
//                            content: { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(maxHeight: 200)
//                                    .clipped()
//                            },
//                            placeholder: {
//                                ProgressView()
//                            }
//                        )
//                    }
//                }
//            }
            
            //details
            VStack(alignment: .leading){
//                HStack(alignment: .bottom){
                Text(selectedEvent.title)
                    .bold()
//                    .padding(.top,1)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 24))
                Text("\(selectedEvent.type)").italic().font(.system(size: 15)).padding(.bottom,4)
                ZStack(alignment: .top) {
                    HStack(alignment: .top) {
                        VStack {
                            Text("Performers:")
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .leading) {
                            ForEach(selectedEvent.performers, id: \.name) { performer in
                                    Text("▷ \(String(performer.name.prefix(25)))")
                            }
                        }
                    }
                }//zstack
                .padding(.bottom,5)
                HStack{
                    Text("🗓️")
                    Text("\(selectedEvent.dateFormatter(includeTime: true))")
                }
                .padding(.bottom,5)
                HStack(alignment: .top){
                    Text("📍")
                    Text("\(selectedEvent.venue.name), \(selectedEvent.venue.city)")
                }
            }//vstack-details
            .padding(.top,5)
            .padding(.bottom,10)
            
            // Attend event button
            Button(){
                //TODO: add to my events
                
                self.addToSavedEvents()
                
                self.showAlert = true
            } label :{
                Text("Save Event")
                    .padding(4)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom,10)
            
            //maps
            MyMap(lat: selectedEvent.venue.location.lat, lng: selectedEvent.venue.location.lon)
//                .frame(height: 100)
            
        }.padding(.horizontal, 30)
        .alert(isPresented: $showAlert){
            Alert(
                title: Text("Message"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }//alert
    } //body
    
    func addToSavedEvents() {

        let fetchRequest: NSFetchRequest<MySavedEvent> = MySavedEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userEmail == %@", currentUser)

        do {
            let myEvents = try viewContext.fetch(fetchRequest)
            if (myEvents.contains(where: {$0.name == selectedEvent.title})){
                print(#function, "Error: Event already saved.")
                self.alertMessage = "Error: Event already saved!"
                return
            }
            // Create a new user object and set its properties
            let newSavedEvent = MySavedEvent(context: viewContext)
            newSavedEvent.name = self.selectedEvent.title
            newSavedEvent.userEmail = self.currentUser
            if let price = self.selectedEvent.stats.price {
                newSavedEvent.price = String(price)
            } else {
                newSavedEvent.price = ""
            }
            newSavedEvent.venueName = "\(self.selectedEvent.venue.name), \(self.selectedEvent.venue.city)"
            newSavedEvent.datetime = self.selectedEvent.dateFormatter(includeTime: false)
            newSavedEvent.png = self.selectedEvent.performers[0].image
            newSavedEvent.id = UUID()

            // Save the new user
            try viewContext.save()
            alertMessage = "Success! Event saved to my Events."
        } catch {
            // Error creating user
            print(#function, "Error saving event!")

        }
    }
}

struct MyMap : UIViewRepresentable{

    typealias UIViewType = MKMapView

    //private var location : CLLocation
    private var lat : Double
    private var  lng : Double
    let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)

    init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }

    func makeUIView(context: Context) -> MKMapView {

        let sourceCoordinates: CLLocationCoordinate2D
        let region : MKCoordinateRegion

        sourceCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        region = MKCoordinateRegion(center: sourceCoordinates, span: span)

        let map = MKMapView(frame: .infinite)
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isUserInteractionEnabled = true
        map.showsUserLocation = true
        map.setRegion(region, animated: true)

        return map
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        //code

        let sourceCoordinates: CLLocationCoordinate2D
        let region : MKCoordinateRegion

        sourceCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        region = MKCoordinateRegion(center: sourceCoordinates, span: span)

        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = sourceCoordinates
        mapAnnotation.title = "Event Location"

        uiView.setRegion(region, animated: true)
        uiView.addAnnotation(mapAnnotation)
    }
}


//struct EventDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventDetailsView()
//    }
//}
