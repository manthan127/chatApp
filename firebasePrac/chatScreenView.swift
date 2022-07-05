//
//  chatScreenView.swift
//  firebasePrac
//
//  Created by mac on 23/06/22.
//

import SwiftUI



struct chatScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var difUser: User
    
    @State var message: String = ""
    @State var showSendButton: Bool = false
    
    @StateObject var chatsVM: ChatVM
    
    init(difUser: User) {
        self._difUser = State(wrappedValue: difUser)
        
        self._chatsVM = StateObject(wrappedValue: ChatVM(difUser: difUser))
    }
    
    var body: some View {
        VStack {
            userDetails
            
            if chatsVM.chats.isEmpty {
                Spacer()
                Text("no Message sent or received")
                Spacer()
            }
            else {
                chatListView
            }
            
            textFieldAndSendButton
        }
        .navigationBarHidden(true)
    }
    
    var chatListView: some View {
        ScrollViewReader { scrollVal in
            ScrollView {
                LazyVStack {
                    if chatsVM.chats.count >= 30 {
                        Rectangle()
                            .fill(Color.clear)
                            .onAppear {
                                chatsVM.fetchChats()
                            }
                    }
                    ForEach(chatsVM.dic.keys.sorted(), id: \.self) { date in
                        Text(date)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(15)
                        ForEach(chatsVM.dic[date]!, id:\.self) { chat in
                            showChat(txt: chat)
                                .id(chat.id)
                        }
                    }
                }
            }
            .onChange(of: chatsVM.lastId) { _ in
                if chatsVM.chats.count <= 60 {
                    scrollVal.scrollTo(chatsVM.chats.last?.id)
                } else {
                    scrollVal.scrollTo(chatsVM.lastId)
                }
            }
            .onChange(of: chatsVM.chats) { nId in
                withAnimation {
                    scrollVal.scrollTo(chatsVM.newId)
                }
            }
        }
    }
    
    struct showChat: View {
        let txt: ChatModel
        
        var body: some View {
            let isUser = txt.uid == UserVM.globUser.uid
            return HStack {
                if isUser {
                    Spacer()
                }
                Text(txt.message)
                    .font(.headline)
                    .padding(EdgeInsets(top: 12, leading: 12, bottom: 19, trailing: 45))
                    .overlay(
                        Text(chatTime(date: txt.time))
                            .font(.caption2)
                            .padding(2)
                            .padding(.trailing, 8),
                        alignment: .bottomTrailing)
                    .background(isUser ? Color.blue : Color.red)
                    .cornerRadius(10)
                    .padding(isUser ? .trailing : .leading)
                                    .frame(maxWidth: Global.screenWidth/8*7, alignment: isUser ? .trailing : .leading)
                    .padding( isUser ? .leading : .trailing, 5)
                
                if !isUser {
                    Spacer()
                }
            }
        }
        
        func chatTime(date: Date)->String {
            return Global.data.timeFormatter.string(from: date)
        }
    }
    
    var userDetails: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 0.5) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Image(uiImage: difUser.profilePic ?? UIImage(systemName: "person.fill")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            Text(difUser.userName)
                .font(.title)
            Spacer()
        }
        .padding(.bottom)
        .background(Color.gray.opacity(0.7).ignoresSafeArea(edges: .top))
    }
    
    
    var textFieldAndSendButton: some View {
        HStack {
            TextField("Enter Message", text: $message) { keyboardOnScreen in
                self.showSendButton = keyboardOnScreen
            } onCommit: {
                send()
            }
            .frame(height: 50)
            .padding(.leading)
            .border(Color.black, width: 1)
            
            if showSendButton {
                Button {
                    send()
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
    
    func send() {
        if message.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            chatsVM.send(message: self.message)
        }
        message = ""
    }
}


struct chatScreenView_Previews: PreviewProvider {
    static var previews: some View {
        chatScreenView(difUser: User([:], uid: ""))
    }
}
