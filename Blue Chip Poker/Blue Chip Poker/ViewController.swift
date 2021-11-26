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
        
        let eval = Evaluator()
                        
        var d = Deck()
        d.shuffle()
        
        var p1 = Player(name: "James")
        var p2 = Player(name: "Akash")
        var p3 = Player(name: "Jake")
        
        var dealer = Dealer(evaluator: eval)
        
        p1.cards = dealer.dealHand()
        p2.cards = dealer.dealHand()
        p3.cards = dealer.dealHand()
        
        
        print(p1.cardsNames)
        print(p2.cardsNames)
        print(p3.cardsNames)
        _ = dealer.dealFlop()
        _ = dealer.dealTurn()
        _ = dealer.dealRiver()
        
        print(dealer.currentGame)
        
        dealer.evaluateHandAtRiver(for: &p1)
        dealer.evaluateHandAtRiver(for: &p2)
        dealer.evaluateHandAtRiver(for: &p3)

        print(dealer.findHeadsUpWinner(player1: p1, player2: dealer.findHeadsUpWinner(player1: p2, player2: p3)))
    
        
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
