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
        setNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "joinGameCell")
        
        MultiPeer.instance.delegate = self
        MultiPeer.instance.initialize(serviceType: "demo-app")
        MultiPeer.instance.startAccepting()
//        MultiPeer.instance.send(object: "requestHost", type: DataType.String.rawValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "username") == nil){
            newuser()
        }
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func setNavigationBar() {

        let screenSize: CGRect = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let firstFrame = CGRect(x: 100, y: 0, width: 300, height: navigationBar.frame.height)
        let secondFrame = CGRect(x: screenSize.width - 200, y: 0, width: 200, height: navigationBar.frame.height)

        
        let defaults = UserDefaults.standard
        var username = "username"
        if (defaults.string(forKey: "username") != nil){
            username = defaults.string(forKey: "username")!
        }
        var balance = 100
        if (defaults.string(forKey: "balance") != nil){
            balance = Int(defaults.string(forKey: "balance")!)!
        }

        let firstLabel = UILabel(frame: firstFrame)
        firstLabel.text = "Welcome " + username + "!"
        firstLabel.textColor = .white

        let secondLabel = UILabel(frame: secondFrame)
        secondLabel.text = "Balance: $" + String(balance)
        secondLabel.textColor = .white

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
}

extension MainViewController: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue:
            break
        case DataType.String.rawValue:
            let state = data.convert() as! String
            let components = state.components(separatedBy: " ")
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
                MultiPeer.instance.send(object: "Userdata " + username + " " + String(balance), type: DataType.String.rawValue)
            }
            if (components[0] == "Host" && components[2] == UserDefaults.standard.string(forKey: "username")!){
                results = [components[1]]
                tableView.reloadData()
            }
//            if state == "GameStarted"{
//                results = []
//                tableView.reloadData()
//            }
            break
        default:
            break
        }
    }

    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
//        MultiPeer.instance.send(object: "requestHost", type: DataType.String.rawValue)
    }
}
