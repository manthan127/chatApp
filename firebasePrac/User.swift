//
//  userMoel.swift
//  firebasePrac
//
//  Created by mac on 20/06/22.
//

import Foundation
import UIKit

struct User: Hashable {
    init(_ data: [String: Any], uid: String) {
        self.uid = uid
        self.email = data["email"] as? String ?? "no email found on server"
        self.userName = data["User Name"] as? String ?? "Guest"
        self.firstName = data["First Name"] as? String ?? "no First Name found on server"
        self.lastName = data["Last Name"] as? String ?? "no Last Name found on server"
        self.chatUsers = data["chats"] as? [String: String] ?? [:]
    }
    
    var email: String
    var uid: String
    var userName: String
    var firstName: String
    var lastName: String
    var profilePic: UIImage?
    var chatUsers: [String: String]
}
