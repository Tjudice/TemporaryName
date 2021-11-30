//
//  UserInfo.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/26/21.
//

import Foundation
import Combine

enum UserDefaultKeys : String{
    case username = "username"
    case balance = "balance"
}

class UserInfo: ObservableObject {
    
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: UserDefaultKeys.username.rawValue)
        }
    }
    
    @Published var balance: Int {
        didSet {
            UserDefaults.standard.set(balance, forKey: UserDefaultKeys.balance.rawValue)
        }
    }
    
    init() {
        self.username = UserDefaults.standard.object(forKey: UserDefaultKeys.username.rawValue) as? String ?? "Username"
        self.balance = UserDefaults.standard.object(forKey: UserDefaultKeys.balance.rawValue) as? Int ?? 100
    }
}
