//
//  HostViewController.swift
//  NewMC
//
//  Created by Akash Akkiraju on 11/22/21.
//

import Foundation
import UIKit
import MultiPeer

class HostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var results : [String] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        MultiPeer.instance.delegate = self
//        MultiPeer.instance.initialize(serviceType: "demo-app")
        MultiPeer.instance.autoConnect()
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinGameCell") ?? UITableViewCell(style: .default, reuseIdentifier: "joinGameCell")
        // Display the results that we've found, if any. Otherwise, show "searching..."
        if results.isEmpty {
            cell.textLabel?.text = "Finding players..."
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .black
        } else {
            let peer = results[indexPath.row]
            cell.textLabel?.text = peer
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .black
        }
        return cell

    }
    
    @IBAction func game_start(_ sender: Any) {
        MultiPeer.instance.stopSearching()
        print(MultiPeer.instance.connectedDeviceNames)
        performSegue(withIdentifier: "game_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? PokerViewController else { return }
        VC.segueVar = 1
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    func resultRows() -> Int {
        if results.isEmpty {
            return 1
        } else {
            return min(results.count, 5)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultRows()
    }
    
}

extension HostViewController: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        return
    }

    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
        results = MultiPeer.instance.connectedDeviceNames
        tableView.reloadData()
    }
}
