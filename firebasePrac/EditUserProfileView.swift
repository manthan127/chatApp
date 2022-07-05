//
//  EditUserProfileView.swift
//  firebasePrac
//
//  Created by mac on 22/06/22.
//

import SwiftUI

struct EditUserProfileView: View {
    @EnvironmentObject var userVM: UserVM
    @State var tempUser: User
    
    let requiredDetailsList = Keys.fieldsList
    @State var varList: [Binding<String>] = [] //[$tempUser.userName, $tempUser.firstName, $tempUser.lastName]
    @State var editList = [false, false, false]
    
    @State var showSheet = false
    @State var showAlert = false
    
    @State var errMsg = ""
    
    @State var photoChanged = false
    
    var body: some View {
        VStack {
            Button {
                showAlert = true
            } label: {
                Image(uiImage: tempUser.profilePic ?? UIImage(systemName: "person.fill")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding()
            }
            
            
            if photoChanged {
                Button {
                    userVM.user.profilePic = tempUser.profilePic
                    userVM.uploadImage()
                    photoChanged = false
                } label: {
                    Text("Upload")
                        .font(.caption)
                        .padding()
                }
            }
            
            ForEach(varList.indices, id: \.self) { i in
                dataDisplay(title: requiredDetailsList[i], data: varList[i], edit: $editList[i])
            }
            
            Button("Logout") {
                userVM.logOut()
            }
            
            Button {
                guard !varList.map({$0.wrappedValue.trimmingCharacters(in: .whitespaces)}).contains("") else {
                    return errMsg = "fill all the non optional Fields"
                }
                
                let data = [
                    "User Name" : tempUser.userName,
                    "First Name" : tempUser.firstName,
                    "Last Name" : tempUser.lastName
                ]
                userVM.updateData(data: data)
                
                editList = Array(repeating: false, count: editList.count)
                userVM.user = tempUser
                
                if photoChanged {
                    userVM.uploadImage()
                    photoChanged = false
                }
                
            } label: {
                Text("Save")
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color.blue)
            }
            
            Text(errMsg)
                .foregroundColor(.red)
                .font(.subheadline)
        }
        .onAppear {
            varList = [$tempUser.userName, $tempUser.firstName, $tempUser.lastName]
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Chose Source"),
                  primaryButton: .default(Text("Camera"), action: {
//                    ImagePicker(image: $image, sourceType: .camera)
                  }), secondaryButton: .default(Text("Photo Library"), action: {
                    showSheet = true
                  }))
        })
        .sheet(isPresented: $showSheet) {
            ImagePicker(image: $tempUser.profilePic, sourceType: .photoLibrary, changingPhoto: {
                self.photoChanged = true
            })
        }
    }
}

struct dataDisplay: View {
    let title: String
    @Binding var data: String
    @Binding var edit: Bool
    
    var body: some View{
        HStack {
            if edit {
                VStack {
                    TextField("Enter " + title, text: $data)
                        .frame(height: 50)
                        .padding(.leading)
                        .border(Color.black, width: 1)
                    Text("Enter " + title)
                        .font(.caption)
                }
                
            } else {
                Text("\(title): \(data)")
                Spacer()
                
            }
            Button {
                edit.toggle()
            } label: {
                Text(edit ? "done" : "Edit")
            }
        }
        .padding()
    }
}

struct EditUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserProfileView(tempUser: User([:], uid: "s"))
    }
}
