
//  P2PSession.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/1/21.
//

import Foundation
import P2PShare
import SwiftUI

final class P2PSession : ObservableObject{
    //static let shared = P2PSession()
    private let session: MultipeerSession!
    private let myPlayerInfo = PeerInfo(["name": UIDevice.current.name])
    @Published private(set) var playersInSesh: [PeerInfo] = []
    @Published private(set) var playersFound: [PeerInfo] = []
    
    init(){
        let config = MultipeerSessionConfig(myPeerInfo: myPlayerInfo,
                                            bonjourService: "_demo._tcp",
                                            presharedKey: "12345",
                                            identity: "DEMO_IDENTITY")
        session = MultipeerSession(config: config, queue: .main)
        playersInSesh.append(myPlayerInfo)
        session.startSharing()
    }
    
    func findPlayers(){
        session.peersChangeHandler = { [weak self] players in
            self?.playersFound = players
        }    }
    
    /*func updatePlayersFound(_ playersFound: [PeerInfo]){
        self.playersFound = playersFound
        var snapshot = NSDiffableDataSourceSnapshot<Section, PeerInfo>()
        snapshot.appendSections()
        snapshot.appendItems(playersFound)
        peersDataSource.apply(snapshot)
    }*/
    

}







//    private var messages: [Message] = []


//    private lazy var messagesDataSource = makeMessagesDataSource()
//private lazy var playersDataSource = makeplayersDataSource()
