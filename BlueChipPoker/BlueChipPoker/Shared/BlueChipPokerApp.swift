//
//  BlueChipPokerApp.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI
import MultiPeer

@main
struct BlueChipPokerApp: App {
   // @StateObject var p2pSesh : P2PSession = P2PSession()
    @StateObject var userInfo : UserInfo = UserInfo()
    @StateObject var mpSesh : MultiPeerViewModel = MultiPeerViewModel()
    var body: some Scene {
        WindowGroup {
            MenuView()
                .environmentObject(mpSesh)
                .environmentObject(userInfo)
        }
    }
}
