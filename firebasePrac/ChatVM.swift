//
//  chatVM.swift
//  firebasePrac
//
//  Created by mac on 28/06/22.
//

import Foundation
import FirebaseFirestore

class ChatVM: ObservableObject {
    @Published var chats: [ChatModel] = [] {
        didSet {
            print(chats.count)
        }
    }
    
    var difUser: User
    
    var chatsId: String?
    
    @Published var lastId: String?
    @Published var newId: String?
    @Published var dic: [String : [ChatModel]] = [:]
    
    init (difUser: User) {
        self.difUser = difUser
        
        if let chatsId = UserVM.globUser.chatUsers[self.difUser.uid] {
            self.chatsId = chatsId
            fetchChats()
        }
    }
    
    func send(message: String) {
        if let chatsId = self.chatsId {
            FirebaseRefs.chatsRef.document(chatsId).collection("list").addDocument(data: [
                "uid" : UserVM.globUser.uid,
                "message" : message,
                "time" : Date()
            ])
        }
        else {
            self.chatsId = FirebaseRefs.chatsRef.document().documentID
            
            UserVM.globUser.chatUsers[self.difUser.uid] = chatsId
            FirebaseRefs.userCollectionRef.document(UserVM.globUser.uid).updateData([Keys.chatKey : UserVM.globUser.chatUsers])
            
            FirebaseRefs.userCollectionRef.document(self.difUser.uid).setData([Keys.chatKey : [UserVM.globUser.uid : chatsId]], merge: true)
            
            let data: [String : Any] = [
                "uid" : UserVM.globUser.uid,
                "message" : message,
                "time" : Date()
            ]

            FirebaseRefs.chatsRef.document(chatsId!).collection("list").addDocument(data: data)
        }
    }
    
    var chatStart: DocumentSnapshot?
    
    func fetchChats(){
        guard let chatsId = UserVM.globUser.chatUsers[difUser.uid] else {return}
        
        func fetch(_ snapshot: QuerySnapshot?, _ error: Error?) {
            guard let snapshot = snapshot else {return print(error?.localizedDescription ?? "-err fetching chat-")}
            guard snapshot.documents.count > 0 else {return}
            
            chatStart = snapshot.documents.first
            let tempChats = snapshot.documents.map { ChatModel(data: $0.data(), id: $0.documentID)}
            
            var time = Set<String>()

            for i in tempChats {
                let t = Global.data.dateFormatter.string(from: i.time)
                time.insert(t)
                self.dic[t, default: []].append(i)
            }
            
            for i in time {
                dic[i] = dic[i]?.sorted(by: { a, b in
                    a.time < b.time
                })
            }
            
            self.chats = tempChats + chats
            
            self.lastId = tempChats.last?.id
        }
        
        if chatStart == nil {
            FirebaseRefs.chatsRef.document(chatsId).collection("list")
                .order(by: "time").limit(toLast: 30)
                .getDocuments { (snapshot, error) in
                    fetch(snapshot, error)
                    self.setChatListener()
                }
        } else {            
            FirebaseRefs.chatsRef.document(chatsId).collection("list")
                .order(by: "time").limit(toLast: 30)
                .end(beforeDocument: chatStart!)
                .getDocuments { (snapshot, error) in
                    fetch(snapshot, error)
                }
        }
    }
    
    func setChatListener() {
        guard let chatsId = self.chatsId else {return}
        
        FirebaseRefs.chatsRef.document(chatsId).collection("list").order(by: "time").limit(toLast: 1)
            .addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {return print(error?.localizedDescription ?? "-err-")}
                if let last = snapshot.documents.last {
                    if last.documentID != self.chats.last?.id {
                        let x = ChatModel(data: last.data(), id: last.documentID)
                        
                        let t = Global.data.dateFormatter.string(from: x.time)
                        self.dic[t, default: []].append(x)
                        
                        self.chats.append(x)
                        self.newId = x.id
                    }
                    return
                }
            }
    }
}
