//
//  SignUpView.swift
//  G10EventFinder
//
//  Created by super on 2023-07-12.
//

import SwiftUI
import CoreData

struct SignUpView: View {
    // We use the @Environment property wrapper to access the managed object context
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name : String = ""
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    @State private var contactNum : String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = "Alert Message"
    
    
    var body: some View {
        VStack{
                Image(systemName: "person.circle")
                    .font(.system(size:120))
                    .foregroundColor(.gray)
                    .padding(.top,20)
            VStack(spacing: 0) {
                TextField("Name", text: self.$name)
                    .textInputAutocapitalization(.none)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .padding(.top, 35).padding(.horizontal)
                            .foregroundColor(.gray)
                    )
                
                TextField("Email", text: self.$email)
                    .textInputAutocapitalization(.none)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .padding(.top, 35).padding(.horizontal)
                            .foregroundColor(.gray)
                    )
                
                SecureField("Password", text: self.$password)
                    .textInputAutocapitalization(.none)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .padding(.top, 35).padding(.horizontal)
                            .foregroundColor(.gray)
                    )
                
                SecureField("Confirm Password", text: self.$confirmPassword)
                    .textInputAutocapitalization(.none)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .padding(.top, 35).padding(.horizontal)
                            .foregroundColor(.gray)
                    )
                
                TextField("Contact Number", text: self.$contactNum)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .padding(.top, 35).padding(.horizontal)
                            .foregroundColor(.gray)
                    )
            }
            .padding(.horizontal, 20)
            .disableAutocorrection(true)

            
            Button(action: {
                //validate the data such as no mandatory inputs, password rules, etc.
                
                self.signUp()
                
            }){
                Text("Create Account")
                    .padding()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(self.password != self.confirmPassword || self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty)
            Spacer()
        }//vstack
        .navigationTitle("SignUp Form")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }//alert
    }
    
    // Function to handle the sign-up action
    private func signUp() {
        // Check if a user with the same username already exists
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            guard users.isEmpty else {
                print(#function, "Error: Email already used.")
                self.alertMessage = "Error: Email already used."
                self.showAlert = true
                // User already exists
                return
            }
            
            // Create a new user object and set its properties
            let newUser = User(context: viewContext)
            newUser.name = self.name
            newUser.email = self.email.lowercased()
            newUser.password = self.password
            newUser.contactNum = self.contactNum
            
            // Save the new user
            try viewContext.save()
            self.dismiss()
        } catch {
            // Error creating user
            print(#function, "Error creating user!")
        }
    }//signup
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
