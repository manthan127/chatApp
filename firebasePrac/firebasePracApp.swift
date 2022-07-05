//
//  firebasePracApp.swift
//  firebasePrac
//
//  Created by mac on 20/06/22.
//

import SwiftUI
import FirebaseCore



@main
struct firebasePracApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var userVM: UserVM = UserVM()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if userVM.user == nil {
                    if FirebaseRefs.fireAuthRef.currentUser?.uid == nil {
                        LoginView()
                    } else {
                        Text("")
                    }
                } else {
                    ContantView()
                }
            }
            .environmentObject(userVM)
        }
    }
}


