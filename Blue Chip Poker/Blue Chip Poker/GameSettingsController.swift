//
//  GameSettingsController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/30/21.
//

import Foundation
import UIKit

class GameSettingsController: UIViewController{
    
    @IBOutlet weak var numPlayerslabel: UILabel!
    @IBOutlet weak var amtTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var playerValue: UISlider!
    @IBOutlet weak var timeValue: UISlider!
    
    @IBAction func playerSlider(_ sender: Any) {
        numPlayerslabel.text = String(Int(playerValue.value)) + " players"
        
    }
    
    @IBAction func timeSlider(_ sender: Any) {
        timeLabel.text = String(Int(timeValue.value)) + " seconds"
    }
    
    override func viewDidLoad() {
        setNavigationBar()
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let VC = segue.destination as? HostViewController else { return }
        if(amtTextField.text != ""){
            let amt: Int? = Int(amtTextField.text!)
            VC.min_amt = amt!
        }
        VC.num_players = Int(playerValue.value)
        VC.time_limit = Int(timeValue.value)
    }
    
    @objc func HostScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HostViewController") as! HostViewController
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
