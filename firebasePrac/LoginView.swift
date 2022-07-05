//
//  loginView.swift
//  firebasePrac
//
//  Created by mac on 20/06/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userVM: UserVM
    @State var email = ""
    @State var password = ""
    
    @State var newUser = false
    @State var disable = false
    
    var body: some View {
        ZStack {
            if newUser {
                NavigationLink("", destination: SignupViewDetails(newUser: $newUser),isActive: $newUser)
            }
            
            VStack {
                Field(message: "Enter email", text: $email, isPass: false)
                
                Field(message: "Enter password", text: $password)
                
                Text(userVM.errorMsg)
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Button {
                    userVM.errorMsg = ""
                    if email != "" && !email.contains("@gmail.com"){
                        email += "@gmail.com"
                    }
                    disable = true
                    userVM.login(email: email, password: password)
                } label: {
                    Text("login")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.blue)
                }
                
                Button {
                    userVM.errorMsg = ""
                    newUser = true
                } label: {
                    Text("don't have an account?? create new account")
                        .font(.footnote)
                }
                
            }
            if userVM.errorMsg == "" && disable {
                Color.gray
                    .opacity(0.5)
                    .ignoresSafeArea()
            }
        }
        .onDisappear {
            disable = false
            email = ""
            password = ""
        }
        .disabled(userVM.errorMsg == "" && disable)
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
