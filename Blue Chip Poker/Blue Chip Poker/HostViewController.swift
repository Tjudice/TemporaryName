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
    var funds : [Int] = []

    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var min_amt: Int = 0
    var num_players: Int = 2
    var time_limit: Int = 25
    var selected_players: [String] = []
    
    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        MultiPeer.instance.delegate = self
//        MultiPeer.instance.initialize(serviceType: "demo-app")
        MultiPeer.instance.autoConnect()
        connectedLabel.text = "Players in the game: 1/" + String(num_players)
        MultiPeer.instance.send(object: "requestUserdata", type: DataType.String.rawValue)
        tableView.reloadData()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !results.isEmpty{
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == UITableViewCell.AccessoryType.checkmark{
                cell!.accessoryType = UITableViewCell.AccessoryType.none
                selected_players.remove(at: selected_players.firstIndex(of: (cell?.textLabel?.text)!)!)
            }
            else{
                cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
                selected_players.append((cell?.textLabel?.text)!)
            }
            cell?.isSelected = false

            let cells = self.tableView.visibleCells
            if selected_players.count+1 > num_players{
                for c in cells {
                    if c != cell && c.accessoryType == UITableViewCell.AccessoryType.checkmark{
                        c.isSelected = false
                        c.accessoryType = UITableViewCell.AccessoryType.none
                        selected_players.remove(at: selected_players.firstIndex(of: (c.textLabel?.text)!)!)

                        break
                    }
                }
            }
            connectedLabel.text = "Players in the game: " + String(selected_players.count+1) + "/" + String(num_players)
        }
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
        
        if selected_players.count + 1 == num_players{
            performSegue(withIdentifier: "game_segue", sender: self)
        }
        print(MultiPeer.instance.connectedDeviceNames)
   
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if selected_players.count + 1 != num_players && identifier == "game_segue"{
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? PokerViewController else { return }
        VC.segueVar = 1
        var selected_funds:[Int] = []
        for i in 0...selected_players.count-1{
            selected_funds.append(funds[results.firstIndex(of: selected_players[i])!])
            MultiPeer.instance.send(object: "Host " + UserDefaults.standard.string(forKey: "username")! + " " + selected_players[i], type: DataType.String.rawValue)
        }

        VC.players_filtered = selected_players
        VC.funds_filtered = selected_funds
        VC.min_time = time_limit
        
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
    
    @objc func HomeScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func setNavigationBar() {

        let screenSize: CGRect = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let frame = CGRect(x: screenSize.width - 200, y: 0, width: 200, height: navigationBar.frame.height)

        let defaults = UserDefaults.standard
        var username = "username"
        if (defaults.string(forKey: "username") != nil){
            username = defaults.string(forKey: "username")!
        }
        var balance = 100
        if (defaults.string(forKey: "balance") != nil){
            balance = Int(defaults.string(forKey: "balance")!)!
        }

        let secondLabel = UILabel(frame: frame)
        secondLabel.text = "Balance: $" + String(balance)
        secondLabel.textColor = .white

        navigationBar.addSubview(secondLabel)
        let navItem = UINavigationItem(title: username)
        let back = UIBarButtonItem(title: "< Home", style: .plain, target: nil, action: #selector(HomeScreen))
        navItem.leftBarButtonItem = back
        navigationBar.setItems([navItem], animated: false)
        navigationBar.backgroundColor = .black
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
        self.view.addSubview(navigationBar)
    }
    
}

extension HostViewController: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue:
            break
        case DataType.String.rawValue:
            let state = data.convert() as! String
//            if state == "requestHost"{
//                MultiPeer.instance.send(object: "Host " + UserDefaults.standard.string(forKey: "username")!, type: DataType.String.rawValue)
//            }
            
            let components = state.components(separatedBy: " ")
            if components[0] == "Userdata"{
                let username = components[1]
                let balance = components[2]
                if Int(balance)! >= min_amt{
                    if !results.contains(username){
                        results.append(username)
                        funds.append(Int(balance)!)
                    }
                }
//                MultiPeer.instance.send(object: "Host " + UserDefaults.standard.string(forKey: "username")!, type: DataType.String.rawValue)
                tableView.reloadData()
            }
            break
        default:
            break
        }
    }

    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
        MultiPeer.instance.send(object: "requestUserdata", type: DataType.String.rawValue)
    }
}
