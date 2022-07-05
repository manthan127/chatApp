//
//  FieldView.swift
//  firebasePrac
//
//  Created by mac on 21/06/22.
//

import SwiftUI

struct Field: View {
    @State var message: String
    @Binding var text: String
    @State var isPass: Bool = true
    
    var body: some View{
        VStack {
            if isPass {
                passField(message: message, text: $text)
            } else {
                TextField(message, text: $text)
                    .keyboardType(.emailAddress)
            }
        }
        .frame(height: 50)
        .padding(.leading)
        .border(Color.black, width: 1)
    }
}


struct passField: View {
    @State var message: String
    @Binding var text: String
    @State var showPass = false
    
    var body: some View {
        HStack{
            if showPass {
                TextField(message, text: $text)
            } else {
                SecureField(message, text: $text)
            }
            Button {
                showPass.toggle()
            } label: {
                Image(systemName: showPass ? "eye" : "eye.slash")
            }
        }
    }
}
