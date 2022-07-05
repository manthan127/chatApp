//
//  UseretailsView.swift
//  firebasePrac
//
//  Created by mac on 21/06/22.
//

import SwiftUI

struct UserDetailsView: View {
    @EnvironmentObject var userVM: UserVM
    @State var user: User
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {                
                Text("Profile")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                Image(uiImage: user.profilePic ?? UIImage(systemName: "person.fill")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding()
                    
                
                printDetail(title: "ID", detail: user.uid)
                printDetail(title: "Email", detail: user.email)
                printDetail(title: "User Name", detail: user.userName)
                printDetail(title: "First Name", detail: user.firstName)
                printDetail(title: "Last Name", detail: user.lastName)
                
                Spacer()
            }
        }
        .navigationBarItems(trailing: editButtton())
    }
    
    func editButtton() -> some View {
        Group{
            if user == userVM.user {
                NavigationLink(destination: EditUserProfileView(tempUser: user)) {
                    Text("Edit")
                }
            }
        }
    }
    
    func printDetail(title: String, detail: String?) -> some View {
        HStack {
            Text(title + " :")
            Text(detail ?? "")
        }
        .padding(8)
    }
    
}

struct UseretailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(user: User([:], uid: "eff3qR4wWsweFW4cefa"))
    }
}
