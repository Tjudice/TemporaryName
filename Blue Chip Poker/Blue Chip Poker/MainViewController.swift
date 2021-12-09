//
//  ViewController.swift
//  BlueChipPoker
//
//  Created by Akash Akkiraju on 11/22/21.
//

import UIKit
import MultiPeer
import SwiftUI

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var results : [String] = [] // Invites for the user to join the nearby poker tables
    @IBOutlet weak var tableView: UITableView! // table displaying the nearby poker tables to join
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display navigation bar and set delegates for table view
        setNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        // seet delegates for multipeer instance
        MultiPeer.instance.delegate = self
        MultiPeer.instance.initialize(serviceType: "demo-app")
        
        // start looking for nearby players
        MultiPeer.instance.startAccepting()
    }
    
    
    // Ask for username for a first time user
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "username") == nil){
            newuser()
        }
    }
    
    // Determines how many cells in the table to display
    func resultRows() -> Int {
        if results.isEmpty {
            return 1
        } else {
            return min(results.count, 5)
        }
    }
    
    // signifies the number of cells to display in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultRows()
    }

    // Displays all the nearby poker tables that the current user has been invited to
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "joinGameCell") ?? UITableViewCell(style: .default, reuseIdentifier: "joinGameCell")
        // Display the results that we've found, if any. Otherwise, show "Nearby Invites..."
        if results.isEmpty {
            cell.textLabel?.text = "Nearby Invites:"
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .clear
        } else {
            let peer = results[indexPath.row]
            cell.textLabel?.text = peer
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    
    // Joins the selected user's poker table and transitions to the PokerViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !results.isEmpty{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PokerViewController") as! PokerViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    // Move to the Host View controller upon clicking the create game button
    @IBAction func host_game(_ sender: Any) {
        performSegue(withIdentifier: "host_segue", sender: self)
    }
    
    // Indicates to the PokerView Controller if the user is joining a table instead of creating one
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? PokerViewController else { return }
        VC.segueVar = 2 // this variable is set to 2 to signify that the user joined an existing poker table
    }
    
    // Link to a page displaying the rules of Poker
    @IBAction func linkToPoker(_ sender: Any) {
        if let url = NSURL(string: "https://bicyclecards.com/how-to-play/basics-of-poker/") {
        UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)

        }
    }
    
    // pop-up for the first time user to enter their new username
    func newuser(){
        let defaults = UserDefaults.standard
        let alert = UIAlertController(title: "Welcome new user!" , message: "Please choose a username: ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your new username"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .cancel, handler: { alt -> Void in
            if alert.textFields![0].text != ""{
                defaults.set(alert.textFields![0].text, forKey: "username")
                defaults.set(100, forKey: "balance")
                self.setNavigationBar()
            }
            
        })
        alert.addAction(confirmAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    // present the navigation bar which includes the username and balance of the current user
    func setNavigationBar() {

        let screenSize: CGRect = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let firstFrame = CGRect(x: 100, y: 0, width: 300, height: navigationBar.frame.height)
        let secondFrame = CGRect(x: screenSize.width - 200, y: 0, width: 200, height: navigationBar.frame.height)

        // check for username stored in local iPhone storage
        let defaults = UserDefaults.standard
        var username = "username"
        if (defaults.string(forKey: "username") != nil){
            username = defaults.string(forKey: "username")!
        }
        
        // check for balance stored in local iPhone storage
        var balance = 100
        if (defaults.string(forKey: "balance") != nil){
            balance = Int(defaults.string(forKey: "balance")!)!
        }
        
        // display username label
        let firstLabel = UILabel(frame: firstFrame)
        firstLabel.text = "Welcome " + username + "!"
        firstLabel.textColor = .white

        // display balance label
        let secondLabel = UILabel(frame: secondFrame)
        secondLabel.text = "Balance: $" + String(balance)
        secondLabel.textColor = .white

        // set style attributes for the navigation bar
        navigationBar.addSubview(firstLabel)
        navigationBar.addSubview(secondLabel)
        navigationBar.backgroundColor = .black
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
        self.view.addSubview(navigationBar)
    }
    
    // Only show in landscape mode
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    // enable auto rotate
    override var shouldAutorotate: Bool {
        return true
    }
}

extension MainViewController: MultiPeerDelegate {
    
    // handling of data recieved from other multipeer connections
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue: // not relevant on this controller
            break
        case DataType.String.rawValue:
            let state = data.convert() as! String
            let components = state.components(separatedBy: " ")
            
            // sending the user data of username and balance to host
            if state == "requestUserdata"{
                let defaults = UserDefaults.standard
                
                var username = "username"
                if (defaults.string(forKey: "username") != nil){
                    username = defaults.string(forKey: "username")!
                }
                var balance = 100
                if (defaults.string(forKey: "balance") != nil){
                    balance = Int(defaults.string(forKey: "balance")!)!
                }
                
                // sending the data to host
                MultiPeer.instance.send(object: "Userdata " + username + " " + String(balance), type: DataType.String.rawValue)
            }
            
            // Updating the table view of invites showing the nearby players that the current user can join
            if (components[0] == "Host" && components[2] == UserDefaults.standard.string(forKey: "username")!){
                results = [components[1]]
                tableView.reloadData()
            }
            break
        default:
            break
        }
    }

    // Debugging : Prints the new connected devices to the multipeer instance
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
    }
}
