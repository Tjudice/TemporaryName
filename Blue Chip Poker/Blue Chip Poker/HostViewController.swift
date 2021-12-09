//
//  HostViewController.swift
//  BlueChipPoker
//
//  Created by Akash Akkiraju on 11/22/21.
//

import Foundation
import UIKit
import MultiPeer

class HostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var results : [String] = [] // Nearby players looking for poker tables to join
    var funds : [Int] = [] // balances of the nearby players to check if they have the min amount

    @IBOutlet weak var connectedLabel: UILabel! // Displays the number of player invites sent
    @IBOutlet weak var tableView: UITableView! // Displays the players nearby looking for poker tables to join
    
    var min_amt: Int = 0 // Min amount for nearby players to join
    var num_players: Int = 2 // Number of players to search for to join
    var time_limit: Int = 45 // Time limit for every player's turn
    var selected_players: [String] = [] // array of the usernames that the host has selected to invite
    
    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display the navigation bar and assign the table view delegates
        setNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        // Multi peer instance now allows for hosting and joining nearby players
        MultiPeer.instance.delegate = self
        MultiPeer.instance.autoConnect()
        connectedLabel.text = "Players in the game: 1/" + String(num_players)
        MultiPeer.instance.send(object: "requestUserdata", type: DataType.String.rawValue)
        tableView.reloadData()
        
    }
    
    // Update the players that have been selected by the host to invite
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
            
            // remove one player if host has selected more than the min number of players
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
            // update the number of people connected in the game label
            connectedLabel.text = "Players in the game: " + String(selected_players.count+1) + "/" + String(num_players)
        }
    }
    
    // display the nearby users looking for a poker table to join to
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinGameCell") ?? UITableViewCell(style: .default, reuseIdentifier: "joinGameCell")
        // Display the results that we've found, if any. Otherwise, show "Finding players..."
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
    
    // Transition to the poker table after the invites have been sent to nearby players
    @IBAction func game_start(_ sender: Any) {
        MultiPeer.instance.stopSearching()
        
        // check if the min number of players have joined the table to start the game
        if selected_players.count + 1 == num_players{
            performSegue(withIdentifier: "game_segue", sender: self)
        }
        print(MultiPeer.instance.connectedDeviceNames)
   
    }
    
    // Determines whether the host has invited the min number of players to start the game
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Doesn't transition to PokerViewController if min players have not joined
        if selected_players.count + 1 != num_players && identifier == "game_segue"{
            return false
        }
        return true // returns true if the host is transitioning to the game settings page
    }
    
    // update some variables in the Poker table controller before performing the transition to PokerViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? PokerViewController else { return }
        VC.segueVar = 1
        var selected_funds:[Int] = []
        
        // send the invites to the selected players to join this poker table
        for i in 0...selected_players.count-1{
            selected_funds.append(funds[results.firstIndex(of: selected_players[i])!])
            MultiPeer.instance.send(object: "Host " + UserDefaults.standard.string(forKey: "username")! + " " + selected_players[i], type: DataType.String.rawValue)
        }

        VC.players_filtered = selected_players // players that are joining the game apart from the host
        VC.funds_filtered = selected_funds // balances of the players that are joining the game
        VC.min_time = time_limit // min decision time for the player to make their move
        
    }
    
    // only allow for landscape orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    // enable autorotate
    override var shouldAutorotate: Bool {
        return true
    }
    
    // Returns the number of rows to display in the results table
    func resultRows() -> Int {
        if results.isEmpty {
            return 1
        } else {
            return min(results.count, 5)
        }
    }
    
    // Determines the number of rows to display in the results table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultRows()
    }
    
    // Take the user back to the Home/ MainViewController
    @objc func HomeScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    // display the navigation bar
    func setNavigationBar() {

        let screenSize: CGRect = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let frame = CGRect(x: screenSize.width - 200, y: 0, width: 200, height: navigationBar.frame.height)

        // get the username of the player from local iPhone storage
        let defaults = UserDefaults.standard
        var username = "username"
        if (defaults.string(forKey: "username") != nil){
            username = defaults.string(forKey: "username")!
        }
        
        // get the balance of the player from local iPhone storage
        var balance = 100
        if (defaults.string(forKey: "balance") != nil){
            balance = Int(defaults.string(forKey: "balance")!)!
        }
        
        // display the balance
        let secondLabel = UILabel(frame: frame)
        secondLabel.text = "Balance: $" + String(balance)
        secondLabel.textColor = .white

        navigationBar.addSubview(secondLabel)
        let navItem = UINavigationItem(title: username) // display the username
        let back = UIBarButtonItem(title: "< Home", style: .plain, target: nil, action: #selector(HomeScreen))
        
        // style attributes for navigation bar
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
          case DataType.GameState.rawValue: // not relevant in this view controller
            break
        case DataType.String.rawValue:
            // recieve user data from players nearby and update the table results to reflect that
            let state = data.convert() as! String
            let components = state.components(separatedBy: " ")
            if components[0] == "Userdata"{
                let username = components[1]
                let balance = components[2]
                if Int(balance)! >= min_amt{  // check if the user has a min amount
                    if !results.contains(username){
                        results.append(username)
                        funds.append(Int(balance)!)
                    }
                }
                tableView.reloadData() // reload the table to display new results
            }
            break
        default:
            break
        }
    }
    
    // Request the userdata of players nearby looking for a poker table to join
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
        MultiPeer.instance.send(object: "requestUserdata", type: DataType.String.rawValue)
    }
}
