//
//  UserVM.swift
//  firebasePrac
//
//  Created by mac on 20/06/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

// sdWebImage, kingfisher

struct Keys {
    static let userId = "user"
    static let userCollectionId = "users"
    static let fieldsList = ["User Name", "First Name", "Last Name"]
    static let storageImages = "images"
    static let chatKey = "chats"
}

struct FirebaseRefs {
    static let fireAuthRef = Auth.auth()
    static let fireStoreRef = Firestore.firestore()
    static let storageRef = Storage.storage().reference()
    static let userCollectionRef = FirebaseRefs.fireStoreRef.collection(Keys.userCollectionId)
    static let chatsRef = FirebaseRefs.fireStoreRef.collection(Keys.chatKey)
}

class UserVM: ObservableObject {
    @Published var user: User! {
        didSet {
            UserVM.globUser = self.user
        }
    }
    
    static var globUser: User!
    var userListener: ListenerRegistration?
    
    @Published var errorMsg: String = ""
    @Published var usersList: [User] = []
    
    init() {
        if let uid = FirebaseRefs.fireAuthRef.currentUser?.uid {
            let documentRef = FirebaseRefs.userCollectionRef.document(uid)
            
            documentRef.getDocument { (snapshot, error) in
                guard error == nil else {
                    self.errorMsg = error!.localizedDescription
                    return
                }
                if let data = snapshot?.data() {
                    self.user = User(data, uid: uid)
                }
            }
            
            self.setListener(documentRef: documentRef)
            
            getImage(id: uid)
        }
    }
    
    func signup(email: String, password: String, userData: [String: Any]) {
        var userData = userData
        
        FirebaseRefs.fireAuthRef.createUser(withEmail: email, password: password) { (authResult, error) in
            guard error == nil else {
                self.errorMsg = error!.localizedDescription
                return
            }
            
            if let authResult = authResult {
                let documentRef = FirebaseRefs.userCollectionRef
                    .document(authResult.user.uid)
                
                userData["email"] = authResult.user.email!
                
                documentRef.setData(userData)
                
                self.user = User(userData, uid: authResult.user.uid)
                self.setListener(documentRef: documentRef)
            }
        }
    }
    
    func login(email: String, password: String) {
        FirebaseRefs.fireAuthRef.signIn(withEmail: email, password: password) { (authResult, error) in
            guard error == nil else {
                self.errorMsg = error!.localizedDescription
                return
            }
            
            if let authResult = authResult {
                let documentRef = FirebaseRefs.userCollectionRef
                    .document(authResult.user.uid)
                
                documentRef.getDocument { (snapshot, error) in
                    guard error == nil else {
                        self.errorMsg = error!.localizedDescription
                        return
                    }
                    if let data = snapshot?.data() {
                        self.user = User(data, uid: authResult.user.uid)
                        self.getImage(id: self.user.uid)
                    }
                }
                
                self.setListener(documentRef: documentRef)
            }
        }
    }
    
    func setListener(documentRef: DocumentReference) {
        self.userListener = documentRef.addSnapshotListener { (snapshot, Error) in
            if let chatsUsers = snapshot?.data()?[Keys.chatKey] {
                self.user?.chatUsers = chatsUsers as! [String : String]
            }
        }
    }
    
    func updateData(data: [String: Any]) {
        FirebaseRefs.userCollectionRef
            .document(self.user.uid)
            .updateData(data)
    }
    
    func uploadImage() {
        if let data = user.profilePic!.jpegData(compressionQuality: 0.2) {
            FirebaseRefs.storageRef.child(Keys.storageImages).child(user.uid).putData(data, metadata: nil) { (metadata, error) in
                guard error == nil else {return print(error!.localizedDescription)}
            }
        }
    }
    
    func getImage(id: String) {
        FirebaseRefs.storageRef.child(Keys.storageImages).child(id).getData(maxSize: 1000_000) { (data, error) in
            if let data = data {
                if let image = UIImage(data: data) {
                    self.user?.profilePic = image
                }
            }
        }
    }
    
    var last: QueryDocumentSnapshot?
    
    func fetchUsers() {
        func getUsers(snapshot: QuerySnapshot?, error: Error?){
            guard error == nil else {
                return print(error!.localizedDescription)
            }
            
            guard let snapshot = snapshot else {return}
            guard snapshot.documents.count > 0 else {return}
            
            if let l = snapshot.documents.last {
                self.last = l
            } else {
                return
            }
            
            self.usersList.append(contentsOf: snapshot.documents.compactMap {
                return $0.documentID == self.user.uid ? nil : User($0.data(), uid: $0.documentID)
            })
            
            for u in usersList.indices where usersList[u].profilePic == nil {
                FirebaseRefs.storageRef.child(Keys.storageImages).child(usersList[u].uid).getData(maxSize: 1000_000) { (data, error) in
                    if let data = data, let image = UIImage(data: data) {
                        self.usersList[u].profilePic = image
                    }
                }
            }
        }
        
        if last == nil {
            FirebaseRefs.userCollectionRef.limit(to: 10).getDocuments { (snapshot, error) in
                getUsers(snapshot: snapshot, error: error)
            }
        }
        else {
            FirebaseRefs.userCollectionRef.limit(to: 10).start(afterDocument: last!).getDocuments { (snapshot, error) in
                getUsers(snapshot: snapshot, error: error)
            }
        }
    }
    
    func logOut() {
        try? FirebaseRefs.fireAuthRef.signOut()
        if FirebaseRefs.fireAuthRef.currentUser?.uid == nil {
            self.userListener?.remove()
            user = nil
            last = nil
            usersList = []
            errorMsg = ""
        }
    }
}
