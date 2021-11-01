//
//  MainController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/1/21.
//

import UIKit

class MainController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LinkToPoker(_ sender: Any) {
        if let url = NSURL(string: "https://bicyclecards.com/how-to-play/basics-of-poker/") {
        UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)

        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
