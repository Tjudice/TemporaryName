//
//  PokerViewController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/26/21.
//

import Foundation
import UIKit

struct GameState{
    var eval : Evaluator = Evaluator()
    var dealer: Dealer = Dealer()
    var curr_deck : Deck = Deck()
    var dealer_ind : Int = 0
    var big_blind_ind : Int = 0
    var small_blind_ind : Int = 0
    var players : [Player] = []
    var funds_players : [Int] = []
    var money_in_pot : Int = 0
    var curr_player_ind : Int = 0
    var players_round : [Bool] = []
    var prev_bet : Int = 0
}



class PokerViewController: UIViewController {
    
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var p1card1: UIImageView!
    @IBOutlet weak var p1card2: UIImageView!
    
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var p2card1: UIImageView!
    @IBOutlet weak var p2card2: UIImageView!
    
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var p3card1: UIImageView!
    @IBOutlet weak var p3card2: UIImageView!
    
    @IBOutlet weak var flop1: UIImageView!
    @IBOutlet weak var flop2: UIImageView!
    @IBOutlet weak var flop3: UIImageView!
    @IBOutlet weak var flop4: UIImageView!
    @IBOutlet weak var flop5: UIImageView!
    
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    //    var eval : Evaluator = Evaluator()
//    var deck : Deck = Deck()
//    var dealer : Dealer = Dealer()
    var curr_state : GameState = GameState()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var p1 = Player(name: "James")
        var p2 = Player(name: "Akash")
        var p3 = Player(name: "Jake")
        
        let curr_players = [p1, p2, p3]
        let curr_funds = [100, 100, 100]
        let players_in_round = [true, true, false]
    
        curr_state = GameState(eval: Evaluator(), dealer: Dealer(), curr_deck: Deck(), dealer_ind: 0, big_blind_ind:(0-2)%curr_players.count , small_blind_ind: (0-1)%curr_players.count, players: curr_players, funds_players: curr_funds, money_in_pot: 0, curr_player_ind: 0, players_round: players_in_round, prev_bet: 0)
        
        curr_state.dealer = Dealer(evaluator: curr_state.eval)
        
        curr_state.curr_deck.shuffle()
        

        p1.cards = curr_state.dealer.dealHand()
        let p1_cards = getImages(for: p1.cards)
        p1card1.image = p1_cards?[0]
        p1card2.image = p1_cards?[1]
        
        
        p2.cards = curr_state.dealer.dealHand()
        p3.cards = curr_state.dealer.dealHand()
        
        dealFlop()
        dealTurn()
        dealRiver()
        
//        _ = dealer.dealFlop()
//        _ = dealer.dealTurn()
//        _ = dealer.dealRiver()
        
//        print(dealer.currentGame)
//
//        dealer.evaluateHandAtRiver(for: &p1)
//        dealer.evaluateHandAtRiver(for: &p2)
//        dealer.evaluateHandAtRiver(for: &p3)
//
//        print(dealer.findHeadsUpWinner(player1: p1, player2: dealer.findHeadsUpWinner(player1: p2, player2: p3)))
        
        
    }
    
    func buttons_enable(){
        if (curr_state.prev_bet == 0){
            foldButton.isHidden = true
            raiseButton.isHidden = true
            betButton.isHidden = false
        }
        else{
            betButton.isHidden = true
            foldButton.isHidden = false
            raiseButton.isHidden = false
        }
    }
    
    
    @IBAction func callFold(_ sender: Any) {
        curr_state.players_round[curr_state.curr_player_ind] = false
        curr_state.curr_player_ind =  (curr_state.curr_player_ind + 1) % curr_state.players.count
        buttons_enable()
    }
    
    @IBAction func callRaise(_ sender: Any) {
        let raised = 0
        if (raised <= curr_state.prev_bet){
            // TODO:- Notification
        }
        curr_state.money_in_pot += raised
        curr_state.funds_players[curr_state.curr_player_ind] -= raised
        curr_state.curr_player_ind =  (curr_state.curr_player_ind + 1) % curr_state.players.count
        curr_state.prev_bet = raised
        buttons_enable()
    }
    
    @IBAction func callCheck(_ sender: Any) {
        
        curr_state.money_in_pot += curr_state.prev_bet
        curr_state.funds_players[curr_state.curr_player_ind] -= curr_state.prev_bet
        curr_state.curr_player_ind =  (curr_state.curr_player_ind + 1) % curr_state.players.count
        buttons_enable()
    }
    
    @IBAction func callBet(_ sender: Any) {
        let raised = 0
        
        curr_state.money_in_pot += raised
        curr_state.funds_players[curr_state.curr_player_ind] -= raised
        curr_state.curr_player_ind =  (curr_state.curr_player_ind + 1) % curr_state.players.count
        curr_state.prev_bet = raised
        buttons_enable()
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
    
    func dealFlop(){
        curr_state.dealer.dealFlop()
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        flop1.image = flop_cards?[0]
        flop2.image = flop_cards?[1]
        flop3.image = flop_cards?[2]
    }
    
    func dealTurn(){
        curr_state.dealer.dealTurn()
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        flop4.image = flop_cards?[3]
    }
    
    func dealRiver(){
        curr_state.dealer.dealRiver()
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        flop5.image = flop_cards?[4]
    }
    
}
