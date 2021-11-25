//
//  BlueChipPokerApp.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 10/31/21.
//

import SwiftUI

@main
struct BlueChipPokerApp: App {
    @StateObject var p2pSesh : P2PSession = P2PSession()
    var body: some Scene {
        WindowGroup {
            MenuView()
                .environmentObject(p2pSesh)
        }
    }
}
