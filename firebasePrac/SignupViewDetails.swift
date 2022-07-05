//
//  DetailsView.swift
//  firebasePrac
//
//  Created by mac on 21/06/22.
//

import SwiftUI

struct SignupViewDetails: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var newUser: Bool
    
    @State var requiredDetails = ["", "", ""]
    let requiredDetailsList = Keys.fieldsList
    @State var userData: [String: Any] = [:]
    
    @State var nextScreen = false
    
    @State var errMsg = ""
    
    var body: some View {
        ZStack {
            if nextScreen {
                NavigationLink("",
                    destination: SignupView(userData: userData,
                        dismiss: {
                            newUser = false
                            presentationMode.wrappedValue.dismiss()
                        }),
                    isActive: $nextScreen)
            }
            
            VStack {
                Text("Personal Details")
                
                ForEach(requiredDetails.indices) { i in
                    TextField("Enter \(requiredDetailsList[i])", text: $requiredDetails[i])
                        .frame(height: 50)
                        .padding(.leading)
                        .border(Color.black, width: 1)
                }
                
                Text(errMsg)
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Button {
                    guard !requiredDetails
                            .map({$0.trimmingCharacters(in: .whitespaces)}).contains("") else {
                        return errMsg = "all Fields are mendatory"
                    }
                    
                    nextScreen = true
                    
                    
                    requiredDetails.indices.forEach{
                        userData[requiredDetailsList[$0]] = requiredDetails[$0]
                    }
                } label: {
                    Text("Next")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                }
                
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("already have an account?? login")
                        .font(.footnote)
                }
                
            }
        }
        .onAppear {
            self.errMsg = ""
        }
        .navigationBarHidden(true)
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SignupViewDetails(newUser: .constant(false))
    }
}
