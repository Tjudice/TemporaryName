//
//  ViewController.swift
//  BlueChipPoker
//
//  Created by Akash Akkiraju on 10/28/21.
//


import UIKit
import P2PShare

class ViewController: UIViewController {

    @IBOutlet private var peersTableView: UITableView!
    
    private let myPlayerInfo = PeerInfo(["name": UIDevice.current.name])
    
    private var players: [PeerInfo] = []
    
    private var session: MultipeerSession!
    
    private lazy var playersDataSource = makeplayersDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peersTableView.dataSource = playersDataSource
        
        let config = MultipeerSessionConfig(myPeerInfo: myPlayerInfo,
                                            bonjourService: "_demo._tcp",
                                            presharedKey: "12345",
                                            identity: "BLUE_CHIP_POKER")
        session = MultipeerSession(config: config, queue: .main)
        
        session.peersChangeHandler = { [weak self] players in
            self?.updateplayers(players)
        }
        
        session.startSharing()
    }
}

private extension ViewController {
    
    enum Section: CaseIterable {
        case main
    }
    
    func makeplayersDataSource() -> UITableViewDiffableDataSource<Section, PeerInfo> {
        return UITableViewDiffableDataSource(tableView: peersTableView) { (tableView, indexPath, peer) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Peer Cell", for: indexPath)
            cell.textLabel?.text = peer.info["name"]
            cell.accessoryType = .checkmark
            return cell
        }
    }
    
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
