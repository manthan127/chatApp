//
//  signinView.swift
//  firebasePrac
//
//  Created by mac on 20/06/22.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var userVM: UserVM
    
    let userData: [String: Any]
    @State var email = ""
    @State var password = ""
    @State var confPassword = ""
    
    @State var disable = false
    
    var dismiss: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Field(message: "Enter email", text: $email, isPass: false)
                
                Field(message: "Enter password", text: $password)
                                
                Field(message: "conform password", text: $confPassword)
                
                Text(userVM.errorMsg)
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Button {
                    userVM.errorMsg = ""
                    guard password == confPassword else {
                        confPassword = ""
                        userVM.errorMsg = "confirm password "
                        return
                    }
                    
                    if email != "" && !email.contains("@gmail.com"){
                        email += "@gmail.com"
                    }
                    disable = true
                    
                    userVM.signup(email: email, password: password, userData: userData)
                } label: {
                    Text("Signup")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                }
                
                Button {
                    userVM.errorMsg = ""
                    dismiss()
                } label: {
                    Text("already have an account?? login")
                        .font(.footnote)
                }
                
            }
            if userVM.errorMsg == "" && disable {
                Color.gray
                    .opacity(0.5)
                    .ignoresSafeArea()
            }
        }
        .disabled(userVM.errorMsg == "" && disable)
        
    }
}

struct signinView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(userData: [:], dismiss: {})
            .environmentObject(UserVM())
    }
}
