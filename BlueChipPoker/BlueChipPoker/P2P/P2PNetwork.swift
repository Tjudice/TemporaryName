
//  P2PNetwork.swift
//  BlueChipPoker
//
//  Created by Cameron Berkowitz on 10/27/21.
//

import SwiftUI
import P2PShare

class CreateGameController: UIViewController {
    
//    @IBAction func send(_ sender: UITextField) {
//        messageTextField.resignFirstResponder()
//        guard let message = messageTextField.text,
//            !message.isEmpty,
//            let data = message.data(using: .unicode)
//            else { return }
//        session.sendToAllPeers(data: data)
//    }
    
    @IBOutlet var peersTableView: UITableView!
    
    @IBAction func search(_ sender: Any) {
        peersTableView.dataSource = playersDataSource
        
        let config = MultipeerSessionConfig(myPeerInfo: myPlayerInfo,
                                            bonjourService: "_demo._tcp",
                                            presharedKey: "12345",
                                            identity: "DEMO_IDENTITY")
        session = MultipeerSession(config: config, queue: .main)
        
        session.peersChangeHandler = { [weak self] players in
            self?.updateplayers(players)
    }
        session.startSharing()
    }
    
    private let myPlayerInfo = PeerInfo(["name": UIDevice.current.name])
    
    private var players: [PeerInfo] = []
//    private var messages: [Message] = []
    
    private var session: MultipeerSession!
    
//    private lazy var messagesDataSource = makeMessagesDataSource()
    private lazy var playersDataSource = makeplayersDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension CreateGameController {
    
    enum Section: CaseIterable {
        case main
    }
    
//    func makeMessagesDataSource() -> UITableViewDiffableDataSource<Section, Message> {
//        return UITableViewDiffableDataSource(tableView: messagesTableView) { (tableView, indexPath, message) -> UITableViewCell? in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Message Cell", for: indexPath)
//            cell.textLabel?.text = message.text
//            return cell
//        }
//    }
    
    func makeplayersDataSource() -> UITableViewDiffableDataSource<Section, PeerInfo> {
        return UITableViewDiffableDataSource(tableView: peersTableView) { (tableView, indexPath, peer) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Peer Cell", for: indexPath)
            cell.textLabel?.text = peer.info["name"]
            return cell
        }
    }
    
//    func addMessage(_ text: String) {
//        messages.append(Message(text: text))
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Message>()
//        snapshot.appendSections(Section.allCases)
//        snapshot.appendItems(messages)
//        messagesDataSource.apply(snapshot)
//    }
    
    func updateplayers(_ players: [PeerInfo]) {
        self.players = players
        var snapshot = NSDiffableDataSourceSnapshot<Section, PeerInfo>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(players)
        playersDataSource.apply(snapshot)
    }
}

extension PeerInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peerID)
    }
}

//struct Message: Hashable {
//    let id = UUID()
//    let text: String
//}

//struct GameState: Hashable{
//    let players = [String]()
//}

