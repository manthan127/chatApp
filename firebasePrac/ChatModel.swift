//
//  ChatModel.swift
//  firebasePrac
//
//  Created by mac on 24/06/22.
//

import Foundation
import FirebaseFirestore

struct ChatModel: Hashable {
    var id: String
    init(data: [String: Any], id: String) {
        self.id = id
        self.uid = data["uid"] as! String
        self.message = data["message"] as! String
        self.time = (data["time"] as! Timestamp).dateValue()
    }
    var uid: String
    var message: String
    var time: Date
}
