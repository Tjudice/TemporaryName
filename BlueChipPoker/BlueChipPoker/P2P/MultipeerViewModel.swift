//
//  MultipeerViewModel.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/30/21.
//

import MultiPeer
import SwiftUI
import Foundation

class MultiPeerViewModel: ObservableObject, MultiPeerDelegate{
    
    @Published var results : [String] = []
    
    init(){
        beginSearching()
    }

    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        return
    }
    
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
        results = MultiPeer.instance.connectedDeviceNames
    }
    

    func beginSearching(){
        MultiPeer.instance.delegate = self
        MultiPeer.instance.initialize(serviceType: "demo-app")
        MultiPeer.instance.startAccepting()
    }
    
    func host_game() {
        MultiPeer.instance.startInviting()
    }
    
    func start_game() {
        MultiPeer.instance.stopSearching()
    }
    
    func return_to_menu(){
        MultiPeer.instance.stopInviting()
    }
    
    
    func linkToPoker() {
        if let url = NSURL(string: "https://bicyclecards.com/how-to-play/basics-of-poker/")
        {
            UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    }
    
}
