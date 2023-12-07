//
//  SignInView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import SwiftUI
import CoreData

struct SignInView: View {
    
    // We use the @Environment property wrapper to access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var linkSelection : Int? = nil
    
    @Binding var rootScreen : RootView
    @Binding var currentUser : String
    
    @State private var showLoginPrompt: Bool = false
    
    var body: some View {
        VStack{
            Image(systemName: "map.circle.fill")
                .font(.system(size:150))
                .foregroundColor(.gray)
                .padding(.top,20)
            
            Text("Event Finder")
                .font(.title)
                .padding(.bottom, 30)
            
            NavigationLink(destination: SignUpView(), tag : 1, selection: self.$linkSelection){}
            
            Section{
                TextField("Enter Email", text: self.$email)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
//                        .background(Color.white)
                    .cornerRadius(10)
                    .font(.system(size: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 2)
                    )
                    .padding(.horizontal)
//                        .padding(.vertical)
                
                SecureField("Enter Password", text: self.$password)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
//                        .background(Color.white)
                    .cornerRadius(10)
                    .font(.system(size: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 2)
                    )
                    .padding(.horizontal)
                    .padding(.vertical)
            }
            .autocorrectionDisabled(true)
                Button(action: {
                    //validate the data
                    
                    if email.isEmpty || password.isEmpty {
                        // Show an alert or provide an error message to the user
                        self.showLoginPrompt = true
                        return
                    }
                    
                    self.login()
                    //sign in using Firebase Auth
//                    self.authHelper.signIn(email: self.email, password: self.password, withCompletion: { isSuccessful in
//                        if (isSuccessful){
//                            //show to home screen
//                            self.rootScreen = .Home
//                        }else{
//                            //show the alert with invalid username/password prompt
//                            print(#function, "invalid username/password")
//                        }
//                    })
                    
                }){
                    HStack{
                        Spacer()
                        Text("Sign In")
                            .font(.title2)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                        Spacer()
                    }
                }
                .background(Color.blue)
                .cornerRadius(10)
//                    .frame(maxWidth: .infinity)
                .padding()
                
//                Button(action: {
//                    //take user to SignUp screen
//                    self.linkSelection = 1
//                }){
//                    Text("Sign Up")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .bold()
//                        .padding()
//                        .background(Color.black)
//                        .cornerRadius(10)
//                }.padding(.vertical)
            
            HStack{
                Text("new user?")
                Button(action: {
                    //take user to SignUp screen
                    self.linkSelection = 1
                }){
                    Text("Sign Up")
                        .font(.callout)
                        .foregroundColor(.blue)
                        .bold()
                        .padding(.trailing)
                }.padding(.vertical)
            }//button HStack
            
        }//VStack
        .padding(30)
        .alert(isPresented: $showLoginPrompt) {
            Alert(
                title: Text("Invalid Credentials!"),
                message: Text("Please check the user name and password"),
                dismissButton: .default(Text("OK"))
            )
        }//alert
        .onAppear(){
//            self.email = "sam@gbc.com"
//            self.password = "12345"
        }
    }//body
    
    // Function to handle the login action
    private func login() {
        // Fetch the user with the provided username from CoreData
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", self.email.lowercased())
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            guard let user = users.first else {
                // User not found
                print(#function, "user not found!")
                showLoginPrompt = true
                return
            }
            // Check if the password matches
            if user.password == self.password {
                print(#function, "SUCCESS! Login successful! \(self.email)")
//           TODO:     store loggedin User
                self.currentUser = user.email
                self.rootScreen = .Home
                
            } else {
                // Incorrect password
                print(#function, "Invalid password")
                showLoginPrompt = true
            }
        } catch {
            // Error fetching user
            print(#function, "Error fetching user")
        }
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
