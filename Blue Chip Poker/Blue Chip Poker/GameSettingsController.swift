//
//  GameSettingsController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/30/21.
//

import Foundation
import UIKit

class GameSettingsController: UIViewController{
    
    @IBOutlet weak var numPlayerslabel: UILabel! // number of players selected on the slider
    @IBOutlet weak var amtTextField: UITextField! // text field for specifying the min amount for each player
    @IBOutlet weak var timeLabel: UILabel! // time selected on the slider
    
    
    @IBOutlet weak var playerValue: UISlider! // slider for choosing the number of players that the host can invite
    @IBOutlet weak var timeValue: UISlider! // slider for choosing the max time for a player to make a decision
    
    
    override func viewDidLoad() {
        // display the navigation bar
        setNavigationBar()
        super.viewDidLoad()
    }
    
    // update the numPlayers label to signify the change in slider value
    @IBAction func playerSlider(_ sender: Any) {
        numPlayerslabel.text = String(Int(playerValue.value)) + " players"
        
    }
    
    // update the time label to signify the change in slider value
    @IBAction func timeSlider(_ sender: Any) {
        timeLabel.text = String(Int(timeValue.value)) + " seconds"
    }
    
    // update the variables on the HostviewController to search for the players that have the min amount
    // and also update the min time for a decision
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? HostViewController else { return }
        if(amtTextField.text != ""){
            let amt: Int? = Int(amtTextField.text!)
            VC.min_amt = amt! // update the min amount
        }
        VC.num_players = Int(playerValue.value) // update the min players that can join
        VC.time_limit = Int(timeValue.value) // update the max time allowed for a player to make a decision
    }
    
    // Transition back to the host screen when go back is clicked
    @objc func HostScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HostViewController") as! HostViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func setNavigationBar() {

        let screenSize: CGRect = UIScreen.main.bounds
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))
        let frame = CGRect(x: screenSize.width - 200, y: 0, width: 200, height: navigationBar.frame.height)

        // get the username from the local iPhone storage
        let defaults = UserDefaults.standard
        var username = "username"
        if (defaults.string(forKey: "username") != nil){
            username = defaults.string(forKey: "username")!
        }
        
        // get the balance from the local iPhone storage
        var balance = 100
        if (defaults.string(forKey: "balance") != nil){
            balance = Int(defaults.string(forKey: "balance")!)!
        }

        // display the balance label
        let secondLabel = UILabel(frame: frame)
        secondLabel.text = "Balance: $" + String(balance)
        secondLabel.textColor = .white

        // display the username at the center of the navigation bar
        navigationBar.addSubview(secondLabel)
        let navItem = UINavigationItem(title: username)
        
        // style attributes for the navigation bar
        let back = UIBarButtonItem(title: "< Back", style: .plain, target: nil, action: #selector(HostScreen))
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
