//
//  Globle.swift
//  firebasePrac
//
//  Created by mac on 30/06/22.
//

import SwiftUI

class Global {
    static var data = Global()
    init () {
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-d"
        
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.locale = NSLocale.current
        timeFormatter.dateFormat = "h:mm a"
    }
    
    static let screenWidth = UIScreen.main.bounds.width
    let dateFormatter = DateFormatter()
    
    let timeFormatter = DateFormatter()
    
}
