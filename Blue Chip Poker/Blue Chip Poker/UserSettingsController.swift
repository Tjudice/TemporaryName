//
//  UserSettingsController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/30/21.
//

import Foundation
import UIKit

class UserSettingsController: UIViewController{
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var balanceTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
    
    @IBAction func changeUsername(_ sender: Any) {
        if (usernameTextField.text != ""){
            let defaults = UserDefaults.standard 
            defaults.set(usernameTextField.text, forKey: "username")
            setNavigationBar()
        }
    }
    
    @IBAction func addBalance(_ sender: Any) {
        if (balanceTextField.text != ""){
            let defaults = UserDefaults.standard
            let curr_value = Int(defaults.string(forKey: "balance")!)!
            let balance: Int? = Int(balanceTextField.text ?? "0")
            defaults.set(Int(curr_value + balance!), forKey: "balance")
            setNavigationBar()
        }
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
