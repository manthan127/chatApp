//
//  ContantView.swift
//  firebasePrac
//
//  Created by mac on 23/06/22.
//

import SwiftUI

struct ContantView: View {
    @EnvironmentObject var userVM: UserVM
    
    var body: some View {
        VStack(spacing: 0) {
            if userVM.user != nil {
                HStack{
                    NavigationLink(
                        destination: UserDetailsView(user: userVM.user),
                        label: {
                            Image(uiImage: userVM.user?.profilePic ?? UIImage(systemName: "person.fill")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 75, height: 75)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .padding()
                        })
                    Spacer()
                    Text(userVM.user.userName)
                        .font(.title2)
                    Spacer()
                }.background(Color.gray.opacity(0.6).ignoresSafeArea(edges: .top))
            }
            
            usersListView
        }
        .navigationBarHidden(true)
        .onAppear {
            if userVM.user != nil && userVM.usersList == [] {
                userVM.fetchUsers()
            }
        }
    }
    
    var usersListView: some View {
        ScrollView {
            LazyVStack {
                ForEach(userVM.usersList, id: \.self.uid) { user in
                    HStack {
                        NavigationLink(
                            destination: UserDetailsView(user: user),
                            label: {
                                Image(uiImage: user.profilePic ?? UIImage(systemName: "person.fill")!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 75)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                                
                            })
                            .frame(width: 75, height: 75)
                        NavigationLink(
                            destination: chatScreenView(difUser: user),
                            label: {
                                Spacer()
                                Text("\(user.userName)")
                                Spacer()
                            })
                    }
                    .padding(10)
                    .border(Color.black, width: 1)
                    .onAppear {
                        if user == userVM.usersList.last {
                            userVM.fetchUsers()
                        }
                    }
                }
            }
        }
    }
}

struct ContantView_Previews: PreviewProvider {
    static var previews: some View {
        ContantView()
            .environmentObject(UserVM())
    }
}
