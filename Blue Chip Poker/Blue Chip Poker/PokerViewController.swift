//
//  PokerViewController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/26/21.
//

import Foundation
import UIKit
import MultiPeer

class GameState: NSObject, NSCoding{
    
    var dealer: Dealer = Dealer()
    var players : [Player] = []
    var dealer_ind : Int = 0
    var big_blind_ind : Int = 0
    var small_blind_ind : Int = 0
    var funds_players : [Int] = []
    var money_in_pot : Int = 0
    var curr_player_ind : Int = 0
    var players_round : [Bool] = []
    var prev_bet : Int = 0
    var flop_done : Bool = false
    var turn_done : Bool = false
    var river_done : Bool = false
    
    override init(){}
    
    required convenience init?(coder: NSCoder) {
        self.init()
        dealer = coder.decodeObject(forKey: "dealer") as! Dealer
        players = coder.decodeObject(forKey: "players") as! [Player]
        dealer_ind = coder.decodeInteger(forKey: "dealer_ind")
        big_blind_ind = coder.decodeInteger(forKey: "big_blind_ind")
        small_blind_ind = coder.decodeInteger(forKey: "small_blind_ind")
        funds_players = coder.decodeObject(forKey: "funds_players") as! [Int]
        money_in_pot = coder.decodeInteger(forKey: "money_in_pot")
        curr_player_ind = coder.decodeInteger(forKey: "curr_player_ind")
        players_round = coder.decodeObject(forKey: "players_round") as! [Bool]
        prev_bet = coder.decodeInteger(forKey: "prev_bet")
        flop_done = coder.decodeBool(forKey: "flop_done")
        turn_done = coder.decodeBool(forKey: "turn_done")
        river_done = coder.decodeBool(forKey: "river_done")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(dealer, forKey: "dealer")
        coder.encode(players, forKey: "players")
        coder.encode(dealer_ind, forKey: "dealer_ind")
        coder.encode(big_blind_ind, forKey: "big_blind_ind")
        coder.encode(small_blind_ind, forKey: "small_blind_ind")
        coder.encode(funds_players, forKey: "funds_players")
        coder.encode(money_in_pot, forKey: "money_in_pot")
        coder.encode(curr_player_ind, forKey: "curr_player_ind")
        coder.encode(players_round, forKey: "players_round")
        coder.encode(prev_bet, forKey: "prev_bet")
        coder.encode(flop_done, forKey: "flop_done")
        coder.encode(turn_done, forKey: "turn_done")
        coder.encode(river_done, forKey: "river_done")
    }
}


enum DataType: UInt32 {
  case GameState = 1
  case String = 2
}



class PokerViewController: UIViewController, MultiPeerDelegate {

    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var p1card1: UIImageView!
    @IBOutlet weak var p1card2: UIImageView!
    
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var p2card1: UIImageView!
    @IBOutlet weak var p2card2: UIImageView!
    
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var p3card1: UIImageView!
    @IBOutlet weak var p3card2: UIImageView!
    
    
    @IBOutlet weak var potLabel: UILabel!
    
    @IBOutlet weak var flop1: UIImageView!
    @IBOutlet weak var flop2: UIImageView!
    @IBOutlet weak var flop3: UIImageView!
    @IBOutlet weak var flop4: UIImageView!
    @IBOutlet weak var flop5: UIImageView!
    
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!

    
    var curr_state = GameState()
    var segueVar : Int = 0
    var alljoined : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MultiPeer.instance.delegate = self
        print("Poker %d", MultiPeer.instance.connectedDeviceNames)
        
        
        if (segueVar == 1){
            
            let devices = MultiPeer.instance.connectedDeviceNames
            
            var curr_players = [Player(name: UIDevice.current.name)]
            var curr_funds = [100]
            var players_in_round = [true]
            
            for i in 0...(devices.count-1){
                curr_players.append(Player(name: devices[i]))
                curr_funds.append(100)
                players_in_round.append(true)
            }
            
            print(curr_funds.count)
            
            curr_state.big_blind_ind = (0-2)%curr_players.count
            curr_state.small_blind_ind = (0-1)%curr_players.count
            curr_state.curr_player_ind = 1
            curr_state.players = curr_players
            curr_state.funds_players = curr_funds
            curr_state.players_round = players_in_round
        
            curr_state.dealer.currentDeck.shuffle()

            for i in 0...(curr_state.players.count-1){
                curr_state.players[i].cards = curr_state.dealer.dealHand()
            }
            
            MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
            show_curr_player_cards()
        
        }
        else{
            MultiPeer.instance.send(object: "HI", type: DataType.String.rawValue)
            
        }


    }
    
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue:
            let state:GameState = data.convert() as! GameState
                curr_state = state
                print("RECEIVED")
                show_curr_player_cards()
            break
            
          case DataType.String.rawValue:
            let state = data.convert() as! String
            if (state == "HI" && segueVar == 1){
                alljoined += 1
                if(alljoined == MultiPeer.instance.connectedDeviceNames.count){
                    MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                }
            }
            break
                    
          default:
            break
        }
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print(MultiPeer.instance.connectedDeviceNames)
    }
    
    func resetRound(){

        curr_state.dealer_ind = (curr_state.dealer_ind+1) % curr_state.players.count
        curr_state.flop_done = false
        curr_state.turn_done = false
        curr_state.river_done = false
        curr_state.players_round = [Bool]()
        curr_state.money_in_pot = 0
        curr_state.prev_bet = 0
        curr_state.big_blind_ind = (curr_state.dealer_ind-2)%curr_state.players.count
        curr_state.small_blind_ind = (curr_state.dealer_ind-1)%curr_state.players.count
        curr_state.curr_player_ind = (curr_state.dealer_ind + 1)%curr_state.players.count
        curr_state.dealer = Dealer(evaluator: Evaluator())
        for i in 0...(curr_state.players.count-1){
            curr_state.players[i].cards = curr_state.dealer.dealHand()
            curr_state.players_round.append(true)
            if(i == 0){
                p1card1.image = UIImage(named: "back_w")
                p1card2.image = UIImage(named: "back_w")
            }
            if(i == 1){
                p2card1.image = UIImage(named: "back_w")
                p2card2.image = UIImage(named: "back_w")
            }
            if (i == 2){
                p3card1.image = UIImage(named: "back_w")
                p3card2.image = UIImage(named: "back_w")
            }
        }
    }

    func handleTurn(){
        // check if dealer has to raise/check before revealing flop and when to move to next betting round
        // Game over label
        if (curr_state.dealer_ind == curr_state.curr_player_ind){
            if (curr_state.flop_done == false){
                curr_state.dealer.dealFlop()
                curr_state.flop_done = true
            }
            else if (curr_state.turn_done == false){
                curr_state.dealer.dealTurn()
                curr_state.turn_done = true
            }
            else if (curr_state.river_done == false){
                curr_state.dealer.dealRiver()
                curr_state.river_done = true
            }
            else{
                // check for folded players before
                // make it a for loop and reveal all cards and print best hand
                
                for i in 0...(curr_state.players.count-1){
                    curr_state.players[i].hand = curr_state.dealer.evaluateHandAtRiver(player: curr_state.players[i])
                }
                
                var winner = curr_state.players[0].name
                var win_ind = 0
                for i in 1...(curr_state.players.count-1){
                    let temp_win = curr_state.dealer.findHeadsUpWinner(player1: curr_state.players[win_ind], player2:curr_state.players[i]).name
                    if(temp_win != winner){
                        win_ind = i
                        winner = temp_win
                    }
                }
                curr_state.funds_players[win_ind] += curr_state.money_in_pot

                print(winner)
  
                // pop up and remove any players not willinnng to continue

                resetRound()
            }
        }
        MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
        show_curr_player_cards()
    }
    
    
    func showdown(){
        // Don't show folded cards
        for i in 0...(curr_state.players.count-1){
            let p_cards = getImages(for: curr_state.players[i].cards)
            if(i == 0){
                p1card1.image = p_cards?[0]
                p1card2.image = p_cards?[1]
            }
            if(i == 1){
                p2card1.image = p_cards?[0]
                p2card2.image = p_cards?[1]
            }
            if (i == 2){
                p3card1.image = p_cards?[0]
                p3card2.image = p_cards?[1]
            }
        }
    }
    

    func show_curr_player_cards(){
        // Show folded beside folded usernames and big blind, small blind, and current player
        
        showTableCards()
        var index = 0
        
        for i in 0...(curr_state.players.count-1){
            if(curr_state.players[i].name == UIDevice.current.name){
                index = i
                break
            }
        }
        
        if (curr_state.curr_player_ind != index){
            hideAllButtons()
        }
        else{
            buttons_enable()
        }
        
        potLabel.text = "Pot: $" + String(curr_state.money_in_pot)
        
        if curr_state.players.count == 2{
            p3card1.isHidden = true
            p3card2.isHidden = true
            player3Label.isHidden = true
        }
        
        let p_cards = getImages(for: curr_state.players[index].cards)
        if(index == 0){
            p1card1.image = p_cards?[0]
            p1card2.image = p_cards?[1]
        }
        if(index == 1){
            p2card1.image = p_cards?[0]
            p2card2.image = p_cards?[1]
        }
        if (index == 2){
            p3card1.image = p_cards?[0]
            p3card2.image = p_cards?[1]
        }
    }


    func hideAllButtons(){
        betButton.isHidden = true
        foldButton.isHidden = true
        raiseButton.isHidden = true
        checkButton.isHidden = true
    }

    func buttons_enable(){
        if (curr_state.prev_bet == 0){
            foldButton.isHidden = true
            raiseButton.isHidden = true
            betButton.isHidden = false
            checkButton.isHidden = false
        }
        else{
            betButton.isHidden = true
            foldButton.isHidden = false
            checkButton.isHidden = false
            raiseButton.isHidden = false
        }
    }

    func bet_pop_up(bet: Bool){
        var alert_txt = "Raise"
        if bet == true {
            alert_txt = "Bet"
        }
        let alert = UIAlertController(title: alert_txt + "!" , message: "Amount should be a minimum of $" + String(curr_state.prev_bet), preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the amount (in dollars)"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let betAction = UIAlertAction(title: alert_txt + "!" , style: .default, handler: { alt -> Void in

            // this code runs when the user hits the "Place bet!" button

            let raised = Int(alert.textFields![0].text!)
            
            if (raised! < self.curr_state.funds_players[self.curr_state.curr_player_ind]){
                // Notification
            }
            
            self.curr_state.money_in_pot += raised!
            self.potLabel.text = "Pot: $" + String(self.curr_state.money_in_pot)
            self.curr_state.funds_players[self.curr_state.curr_player_ind] -= raised!
            self.curr_state.prev_bet = raised!
            self.nextPlayer()
            print(raised!)

        })

        alert.addAction(cancelAction)
        alert.addAction(betAction)

        self.present(alert, animated: true, completion: nil)

    }
    
    func nextPlayer(){
        var i = 1
        while (i <= curr_state.players.count &&
               curr_state.players_round[(curr_state.curr_player_ind + i)%curr_state.players.count] == false){
            i += 1
        }
        
        curr_state.curr_player_ind =  (curr_state.curr_player_ind + i) % curr_state.players.count
        handleTurn()
    }
    
    @IBAction func callFold(_ sender: Any) {
        curr_state.players_round[curr_state.curr_player_ind] = false
        nextPlayer()
    }

    @IBAction func callRaise(_ sender: Any) {
        let raised = 0
        if (raised <= curr_state.prev_bet){
            // TODO:- Notification
        }
        bet_pop_up(bet: false)

    }

    @IBAction func callCheck(_ sender: Any) {

        curr_state.money_in_pot += curr_state.prev_bet
        potLabel.text = "Pot: $" + String(curr_state.money_in_pot)
        curr_state.funds_players[curr_state.curr_player_ind] -= curr_state.prev_bet
        nextPlayer()
    }


    @IBAction func callBet(_ sender: Any) {
        bet_pop_up(bet: true)
    }


    func getImages(for cards: [Card]) -> [UIImage]? {
        var imgs = [UIImage]()
        for card in cards {
            let name = card.fileName
            guard let img = UIImage(named: name) else {
                return nil
            }
            imgs.append(img)
        }
        return imgs
    }

    func showTableCards(){
        if(curr_state.flop_done == false){
            flop1.image = UIImage(named: "back_w")
            flop2.image = UIImage(named: "back_w")
            flop3.image = UIImage(named: "back_w")
            flop4.image = UIImage(named: "back_w")
            flop5.image = UIImage(named: "back_w")
        }
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        if(curr_state.flop_done == true){
            flop1.image = flop_cards?[0]
            flop2.image = flop_cards?[1]
            flop3.image = flop_cards?[2]
        }
        if(curr_state.turn_done == true){
            flop4.image = flop_cards?[3]
        }
        if(curr_state.river_done == true){
            flop5.image = flop_cards?[4]
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
}
