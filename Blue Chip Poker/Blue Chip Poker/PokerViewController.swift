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
    var preflop : Bool = true
    var showdown : Bool = false
    var win_index : Int = -1
    var players_round_bet : [Int] = []
    var stats : [String : [Int]] = [:]
    var total_rounds = 0
    
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
        preflop = coder.decodeBool(forKey: "preflop")
        showdown = coder.decodeBool(forKey: "showdown")
        win_index = coder.decodeInteger(forKey: "win_index")
        players_round_bet = coder.decodeObject(forKey: "players_round_bet") as! [Int]
        stats = coder.decodeObject(forKey: "stats") as! [String : [Int]]
        total_rounds = coder.decodeInteger(forKey: "total_rounds")
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
        coder.encode(preflop, forKey: "preflop")
        coder.encode(showdown, forKey: "showdown")
        coder.encode(players_round_bet, forKey: "players_round_bet")
        coder.encode(win_index, forKey: "win_index")
        coder.encode(stats, forKey: "stats")
        coder.encode(total_rounds, forKey: "total_rounds")
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
    @IBOutlet weak var p1Funds: UILabel!
    
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var p2card1: UIImageView!
    @IBOutlet weak var p2card2: UIImageView!
    @IBOutlet weak var p2Funds: UILabel!
    
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var p3card1: UIImageView!
    @IBOutlet weak var p3card2: UIImageView!
    @IBOutlet weak var p3Funds: UILabel!
    
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

    @IBOutlet weak var gameStat: UILabel!
    
    var curr_state = GameState()
    var segueVar : Int = 0
    var alljoined : Int = 0
    var triggered : Int  = 0
    var clicked : Int = 0
    var initial_connected : Int = 0
    var big_blind_bet: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MultiPeer.instance.delegate = self
        print("Poker %d", MultiPeer.instance.connectedDeviceNames)
        initial_connected = MultiPeer.instance.connectedDeviceNames.count
        
        
        if (segueVar == 1){
            
            let devices = MultiPeer.instance.connectedDeviceNames
            
            var curr_players = [Player(name: UIDevice.current.name)]
            var curr_funds = [100]
            var players_in_round = [true]
            curr_state.stats[UIDevice.current.name] = [0,0]
            
            for i in 0...(devices.count-1){
                curr_state.stats[devices[i]] = [0,0]
                curr_players.append(Player(name: devices[i]))
                curr_funds.append(100)
                players_in_round.append(true)
                curr_state.players_round_bet.append(-1)
            }
            curr_state.players_round_bet.append(-1)
            
            print(curr_funds.count)
            
            curr_state.big_blind_ind = 0%curr_players.count
            curr_state.small_blind_ind = 1%curr_players.count
            curr_state.dealer_ind = 2%curr_players.count
            curr_state.curr_player_ind = 3%curr_players.count
            curr_state.players = curr_players
            curr_state.funds_players = curr_funds
            curr_state.players_round = players_in_round
        
            curr_state.dealer.currentDeck.shuffle()
            curr_state.funds_players[curr_state.big_blind_ind] -= big_blind_bet
            curr_state.funds_players[curr_state.small_blind_ind] -= big_blind_bet/2
            curr_state.prev_bet = 1
            curr_state.players_round_bet[curr_state.big_blind_ind] = big_blind_bet
            curr_state.players_round_bet[curr_state.small_blind_ind] = big_blind_bet/2
            curr_state.stats[curr_state.players[curr_state.big_blind_ind].name!]![1] -= big_blind_bet
            curr_state.stats[curr_state.players[curr_state.small_blind_ind].name!]![1] -= big_blind_bet/2
            curr_state.money_in_pot += big_blind_bet + big_blind_bet/2

            for i in 0...(curr_state.players.count-1){
                curr_state.players[i].cards = curr_state.dealer.dealHand()
            }
            
            //triggered = 1
            MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
            MultiPeer.instance.send(object: "HI", type: DataType.String.rawValue)
            hideAllButtons()
        
        }
        else{
            MultiPeer.instance.send(object: "HI", type: DataType.String.rawValue)
            hideAllButtons()
            
        }


    }
    
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue:
            let state:GameState = data.convert() as! GameState
                curr_state = state
                if triggered == 1{
                    show_curr_player_cards()
                }
            break
            
          case DataType.String.rawValue:
            let state = data.convert() as! String
            if (state == "HI"){
                alljoined += 1
                if(alljoined >= initial_connected){
                    MultiPeer.instance.send(object: "Trigger", type: DataType.String.rawValue)
                    MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                    show_curr_player_cards()
                    triggered = 1
                }
            }
            if(state == "Continue"){
                alljoined += 1
                if(alljoined >= initial_connected){
                    if(clicked == 1){
                        if triggered == 1{
                            resetRound()
                        }
                        else{
                            triggered = 1
                        }
                        MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                        show_curr_player_cards()
                        clicked = 0
                        MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue)
                    }
                }
            }
            
            
            if(state == "Trigger"){
                triggered = 1
            }
            if(state == "Reset"){
                alljoined = 0
                clicked = 0
            }
            if(state == "Delete"){
               initial_connected -= 1
                triggered = 0
            }
            if(state == "End"){
                summary()
            }
            break
                    
          default:
            break
        }
    }
    
    func hideAllCards(){
        flop1.image = UIImage(named: "back_w")
        flop2.image = UIImage(named: "back_w")
        flop3.image = UIImage(named: "back_w")
        flop4.image = UIImage(named: "back_w")
        flop5.image = UIImage(named: "back_w")
        
        for i in 0...(curr_state.players.count-1){
            if(i == 0){
                p1card1.image = UIImage(named: "back_w")
                p1card2.image = UIImage(named: "back_w")
                player1Label.textColor = .white
            }
            if(i == 1){
                p2card1.image = UIImage(named: "back_w")
                p2card2.image = UIImage(named: "back_w")
                player2Label.textColor = .white
            }
            if (i == 2){
                p3card1.image = UIImage(named: "back_w")
                p3card2.image = UIImage(named: "back_w")
                player3Label.textColor = .white
            }
        }
        
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print(MultiPeer.instance.connectedDeviceNames)
    }
    
    func resetRound(){

        curr_state.dealer_ind = (curr_state.dealer_ind+1) % curr_state.players.count
        curr_state.preflop = true
        curr_state.flop_done = false
        curr_state.turn_done = false
        curr_state.river_done = false
        curr_state.players_round = [Bool]()
        curr_state.money_in_pot = 0
        curr_state.win_index = -1
        curr_state.big_blind_ind = (curr_state.big_blind_ind+1)%curr_state.players.count
        curr_state.small_blind_ind = (curr_state.small_blind_ind+1)%curr_state.players.count
        curr_state.dealer_ind = (curr_state.dealer_ind+1)%curr_state.players.count
        curr_state.curr_player_ind = (curr_state.dealer_ind + 1)%curr_state.players.count
        curr_state.dealer = Dealer(evaluator: Evaluator())
        curr_state.players_round_bet = [Int]()
        curr_state.showdown = false
        for i in 0...(curr_state.players.count-1){
            curr_state.players[i] = Player(name: curr_state.players[i].name!)
            curr_state.players[i].cards = curr_state.dealer.dealHand()
            curr_state.players_round.append(true)
            curr_state.players_round_bet.append(-1)
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
        curr_state.prev_bet = 1
        curr_state.players_round_bet[curr_state.big_blind_ind] = big_blind_bet
        curr_state.players_round_bet[curr_state.small_blind_ind] = big_blind_bet/2
        curr_state.funds_players[curr_state.big_blind_ind] -= big_blind_bet
        curr_state.funds_players[curr_state.small_blind_ind] -= big_blind_bet/2
        curr_state.stats[curr_state.players[curr_state.big_blind_ind].name!]![1] -= big_blind_bet
        curr_state.stats[curr_state.players[curr_state.small_blind_ind].name!]![1] -= big_blind_bet/2
        curr_state.money_in_pot += big_blind_bet + big_blind_bet/2
    }
    
    func resetBets(){
        for i in 0...curr_state.players_round_bet.count-1{
            curr_state.players_round_bet[i] = -1
        }
    }
    
    func handleAction(){
        var non_folded = 0
        var non_folded_id = -1
        for i in 0...curr_state.players.count-1{
            if(curr_state.players_round[i] == true){
                non_folded_id = i
                non_folded += 1
            }
        }
        if(non_folded == 1){
            curr_state.win_index = non_folded_id
            // pop up and remove any players not willinnng to continue
            curr_state.funds_players[non_folded_id] += curr_state.money_in_pot
            //resetRound()
            curr_state.showdown = true
            curr_state.total_rounds += 1
            curr_state.stats[curr_state.players[curr_state.win_index].name!]![0] += 1
            curr_state.stats[curr_state.players[curr_state.win_index].name!]![1] += curr_state.money_in_pot
            return
        }
        let curr_bet = max_bet_in_round()
        var end_action = true
            for i in 1...curr_state.players.count{
                let temp_player_ind = (curr_state.curr_player_ind+i)%curr_state.players.count
                if(curr_state.players_round_bet[temp_player_ind] != curr_bet && curr_state.players_round[temp_player_ind] == true) {
                    end_action = false;
                    nextPlayer(index: curr_state.curr_player_ind)
                    break;
                }
            }
            if (end_action == true) {
                resetBets()
                self.curr_state.prev_bet = 0
                if (curr_state.flop_done == false) {
                    curr_state.preflop = false
                    curr_state.dealer.dealFlop()
                    curr_state.flop_done = true
                    print(curr_state.small_blind_ind)
                    if (curr_state.players_round[curr_state.small_blind_ind] == false) {
                        nextPlayer(index: curr_state.small_blind_ind)
                    }
                    else {
                        curr_state.curr_player_ind = curr_state.small_blind_ind
                    }
                }
                else if (curr_state.turn_done == false){
                    curr_state.dealer.dealTurn()
                    curr_state.turn_done = true
                    nextPlayer(index: curr_state.curr_player_ind)
                }
                else if (curr_state.river_done == false){
                    curr_state.dealer.dealRiver()
                    curr_state.river_done = true
                    nextPlayer(index: curr_state.curr_player_ind)
                }
                else{
                    // check for folded players before
                    // make it a for loop and reveal all cards and print best hand
                    var set = false
                    var winner = ""
                    var win_ind = 0
                    for i in 0...(curr_state.players.count-1){
                        if (curr_state.players_round[i] == true){
                            curr_state.players[i].hand = curr_state.dealer.evaluateHandAtRiver(player: curr_state.players[i])
                            if (set == false){
                                winner = curr_state.players[i].name!
                                win_ind = i
                                set = true
                            }
                        }
                    }
                    
                    for i in 0...(curr_state.players.count-1){
                        if (curr_state.players_round[win_ind] == true && curr_state.players_round[i] == true){
                            let temp_win = curr_state.dealer.findHeadsUpWinner(player1: curr_state.players[win_ind], player2:curr_state.players[i]).name
                            if(temp_win != winner){
                                win_ind = i
                                winner = temp_win!
                            }
                        }
                    }
                    curr_state.stats[winner]![0] += 1
                    curr_state.stats[winner]![1] += curr_state.money_in_pot
                    curr_state.win_index = win_ind
                    curr_state.funds_players[win_ind] += curr_state.money_in_pot
                    curr_state.showdown = true
                    curr_state.total_rounds += 1
                }
                
        }
    }
    
    func summary(){
        let rounds_won = String(curr_state.stats[UIDevice.current.name]![0])
        let funds_won = String(curr_state.stats[UIDevice.current.name]![1])
        let total = String(curr_state.total_rounds)
        let alert = UIAlertController(title: "Summary" , message: "Rounds won: " + rounds_won + "/" + total + "\nMoney gained/lost: " + funds_won, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler:  { alt -> Void in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            self.present(nextViewController, animated:true, completion:nil)
        })
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func announceWinner(){
        showdown()
        hideAllButtons()
        gameStat.text = "Waiting for other players"
        potLabel.text = "Pot: $0"
        var non_folded = 0
        for i in 0...curr_state.players.count-1{
            if(curr_state.players_round[i] == true){
                non_folded += 1
            }
        }
        let name = curr_state.players[curr_state.win_index].name!
        var alert = UIAlertController(title: "Round Over!" , message: "Winner of this round is " + name +
                                      "\nDo you wish to continue?", preferredStyle: .alert)
        if(non_folded > 1){
            curr_state.dealer.evaluateHandAtRiver(for: &curr_state.players[curr_state.win_index])
            let handName = curr_state.players[curr_state.win_index].handNameDescription!
            let hand = curr_state.players[curr_state.win_index].handDescription!
     
            alert = UIAlertController(title: "Round Over!" , message: "Winner of this round is " + name +
                                          "\nWinning Hand: " + handName + "\n" + hand + "\nDo you wish to continue?", preferredStyle: .alert)
        }

        self.alljoined = 0
        MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:  { alt -> Void in
            var ind = 0
            for i in 0...self.curr_state.players.count-1{
                if self.curr_state.players[i].name == UIDevice.current.name{
                    ind = i
                    break
                }
            }
            self.clicked = 1
            self.curr_state.players.remove(at: ind)
            self.curr_state.funds_players.remove(at: ind)
            if self.curr_state.players.count <= 1{
                MultiPeer.instance.send(object: "End", type: DataType.String.rawValue)
                self.summary()
                return
            }
            self.resetRound()
            self.summary()
            self.initial_connected = 10
            MultiPeer.instance.send(object: "Delete", type: DataType.String.rawValue)
            MultiPeer.instance.send(object: self.curr_state, type: DataType.GameState.rawValue)
        })
        let continueAction = UIAlertAction(title:  "Yes!" , style: .default, handler: { alt -> Void in
            self.clicked = 1
            MultiPeer.instance.send(object: "Continue", type: DataType.String.rawValue)
            self.hideAllCards()
            if(self.alljoined >= self.initial_connected){
                if self.triggered == 1{
                    self.resetRound()
                }
                else{
                    self.triggered = 1
                }
                MultiPeer.instance.send(object: self.curr_state, type: DataType.GameState.rawValue)
                self.show_curr_player_cards()
                self.clicked = 0
                MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue)
            }
            print(MultiPeer.instance.connectedDeviceNames.count)
            
        })

        alert.addAction(cancelAction)
        alert.addAction(continueAction)

        self.present(alert, animated: true, completion: nil)
    }

    func handleBoard(){
        // check if dealer has to raise/check before revealing flop and when to move to next betting round
        // Game over label
        handleAction()
        MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
        show_curr_player_cards()
    }
    
    
    func showdown(){
        // Don't show folded cards
        for i in 0...(curr_state.players.count-1){
            let p_cards = getImages(for: curr_state.players[i].cards)
            if(i == 0 && curr_state.players_round[i] != false){
                p1card1.image = p_cards?[0]
                p1card2.image = p_cards?[1]
            }
            if(i == 1 && curr_state.players_round[i] != false){
                p2card1.image = p_cards?[0]
                p2card2.image = p_cards?[1]
            }
            if (i == 2 && curr_state.players_round[i] != false){
                p3card1.image = p_cards?[0]
                p3card2.image = p_cards?[1]
            }
        }
    }
    

    func show_curr_player_cards(){
        // Show folded beside folded usernames and big blind, small blind, and current player
        if curr_state.players.count == 1{
            summary()
        }
        
        showTableCards()
        var index = 0
        
        for i in 0...(curr_state.players.count-1){
            if(curr_state.players[i].name == UIDevice.current.name){
                index = i
            }
            if(curr_state.curr_player_ind == 0){
                player1Label.textColor = .orange
                player2Label.textColor = .white
                player3Label.textColor = .white
            }
            if(curr_state.curr_player_ind == 1){
                player2Label.textColor = .orange
                player1Label.textColor = .white
                player3Label.textColor = .white
            }
            if(curr_state.curr_player_ind == 2){
                player3Label.textColor = .orange
                player2Label.textColor = .white
                player1Label.textColor = .white
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
            p3Funds.isHidden = true
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
        if(curr_state.showdown == true){
            announceWinner()
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
            curr_state.prev_bet = 1
        }
        let alert = UIAlertController(title: alert_txt + "!" , message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the amount (in dollars)"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let betAction = UIAlertAction(title: alert_txt + "!" , style: .default, handler: { alt -> Void in

            // this code runs when the user hits the "Place bet!" button
            var raised: Int? = Int(alert.textFields![0].text!)
            
            if (self.curr_state.players_round_bet[self.curr_state.curr_player_ind] == -1 ){
                self.curr_state.players_round_bet[self.curr_state.curr_player_ind] = 0
            }
//            let temp = self.curr_state.prev_bet
//            self.curr_state.prev_bet = raised!
            if (bet == false) {
                raised = raised! + self.max_bet_in_round() - self.curr_state.players_round_bet[self.curr_state.curr_player_ind ]
            }

            if (raised! > self.curr_state.funds_players[self.curr_state.curr_player_ind]){
                let alert_no_funds = UIAlertController(title:  "Not enough funds!" , message: "", preferredStyle: .alert)
                let try_again_action = UIAlertAction(title: "Try again", style: .cancel, handler: { alt -> Void in
                    self.bet_pop_up(bet: bet)
                })
                alert_no_funds.addAction(try_again_action)
                self.present(alert_no_funds, animated: true, completion: nil)
//                self.curr_state.prev_bet = temp
                return
            }
            self.curr_state.money_in_pot += raised!
            self.potLabel.text = "Pot: $" + String(self.curr_state.money_in_pot)

            self.curr_state.funds_players[self.curr_state.curr_player_ind] -= raised!
            self.curr_state.stats[self.curr_state.players[self.curr_state.curr_player_ind].name!]![1] -= raised!
            

            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += raised!
            self.handleBoard()
            //self.nextPlayer()
            print(raised!)

        })

        alert.addAction(cancelAction)
        alert.addAction(betAction)

        self.present(alert, animated: true, completion: nil)

    }
    
    func nextPlayer(index: Int){
        var i = 1
        while (i <= curr_state.players.count &&
               curr_state.players_round[(index + i)%curr_state.players.count] == false){
            i += 1
        }
        
        curr_state.curr_player_ind =  (index + i) % curr_state.players.count
        //handleBoard()
    }
    
    @IBAction func callFold(_ sender: Any) {
        curr_state.players_round[curr_state.curr_player_ind] = false
        handleBoard()
    }

    @IBAction func callRaise(_ sender: Any) {
        bet_pop_up(bet: false)

    }
    
    func max_bet_in_round() -> Int{
        var ans = -1
        for i in 0...self.curr_state.players.count-1{
            if(curr_state.players_round[i] == true){
                if curr_state.players_round_bet[i] > ans{
                    ans = curr_state.players_round_bet[i]
                }
            }
        }
        return ans
    }

    @IBAction func callCheck(_ sender: Any) {
        if (self.curr_state.players_round_bet[self.curr_state.curr_player_ind] == -1 ){
            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] = 0
        }
        let amount = max_bet_in_round() - curr_state.players_round_bet[curr_state.curr_player_ind]
        curr_state.money_in_pot += amount
        potLabel.text = "Pot: $" + String(curr_state.money_in_pot)
        curr_state.funds_players[curr_state.curr_player_ind] -= amount
        self.curr_state.stats[self.curr_state.players[self.curr_state.curr_player_ind].name!]![1] -= amount
        self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += amount
        handleBoard()
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
        
        let small_blind = curr_state.players[curr_state.small_blind_ind].name! + " ($" + String(big_blind_bet/2) + ")"
        let big_blind = curr_state.players[curr_state.big_blind_ind].name! + " ($" + String(big_blind_bet) + ")"
        let dealer_name = curr_state.players[curr_state.dealer_ind].name
        gameStat.text = "Big Blind: " + big_blind +
        "\nSmall Blind: " + small_blind + "\nDealer: " + dealer_name!
        
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
        for i in 0...(curr_state.players.count-1){
            if(i==0){
                p1Funds.text = "$" + String(curr_state.funds_players[i])
            }
            if(i==1){
                p2Funds.text = "$" + String(curr_state.funds_players[i])
            }
            if(i==2){
                p3Funds.text = "$" + String(curr_state.funds_players[i])
            }
            if (curr_state.players_round[i] == false){
                if(i == 0){
                    p1card1.image = UIImage(named: "back_w")
                    p1card2.image = UIImage(named: "back_w")
                    player1Label.text = curr_state.players[i].name! + "(Folded)"
                }
                if(i == 1){
                    p2card1.image = UIImage(named: "back_w")
                    p2card2.image = UIImage(named: "back_w")
                    player2Label.text = curr_state.players[i].name! + "(Folded)"
                }
                if (i == 2){
                    p3card1.image = UIImage(named: "back_w")
                    p3card2.image = UIImage(named: "back_w")
                    player3Label.text = curr_state.players[i].name! + "(Folded)"
                }
            }
            else{
                if(i == 0){
                    player1Label.text = curr_state.players[i].name!
                }
                if(i == 1){
                    player2Label.text = curr_state.players[i].name!
                }
                if (i == 2){
                    player3Label.text = curr_state.players[i].name!
                }
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
}
