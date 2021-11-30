//
//  ViewController.swift
//  multipeer
//
//  Created by Akash Akkiraju on 11/22/21.
//

import UIKit
import MultiPeer
import SwiftUI

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var results : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        MultiPeer.instance.delegate = self
        MultiPeer.instance.initialize(serviceType: "demo-app")
        MultiPeer.instance.startAccepting()
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinGameCell") ?? UITableViewCell(style: .default, reuseIdentifier: "joinGameCell")
        // Display the results that we've found, if any. Otherwise, show "searching..."
        if results.isEmpty {
            cell.textLabel?.text = "Searching for games..."
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("NOWWWW")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PokerViewController") as! PokerViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func host_game(_ sender: Any) {
        performSegue(withIdentifier: "host_segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? PokerViewController else { return }
        VC.segueVar = 2
    }
    
    @IBAction func linkToPoker(_ sender: Any) {
        if let url = NSURL(string: "https://bicyclecards.com/how-to-play/basics-of-poker/") {
        UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)

        }
    }
}

extension MainViewController: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        return
    }

    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
        results = MultiPeer.instance.connectedDeviceNames
        tableView.reloadData()
    }
}
