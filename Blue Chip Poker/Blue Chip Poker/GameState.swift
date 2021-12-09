//
//  GameState.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 12/8/21.
//

import Foundation


// Class that keeps the upto state of the poker table
class GameState: NSObject, NSCoding{
    
    var dealer: Dealer = Dealer() // current dealer for the game
    var players : [Player] = []  // array of players in the game
    var dealer_ind : Int = 0 // index of the dealer player in the players array
    var big_blind_ind : Int = 0 // index of the big blind player in the players array
    var small_blind_ind : Int = 0 // index of the small blind player in the players array
    var funds_players : [Int] = [] // array of the balances of the players in the players array
    var money_in_pot : Int = 0 // the amount of money in the pot
    var curr_player_ind : Int = 0 // index of the current player in the players array
    var players_round : [Bool] = [] // array which tells if a  player in the players array has folded
    var prev_bet : Int = 0 // variable which indicates whether a previous bet has been placed
    var flop_done : Bool = false // checks whether the flop has been shown
    var turn_done : Bool = false // checks whether the turn has been shown
    var river_done : Bool = false // checks whether the river has been shown
    var preflop : Bool = true // checks whether it is the first betting round before flop
    var showdown : Bool = false // indicates wheether the round has ended to show all players cards
    var win_index : Int = -1 // index of the winning player in the players array
    var players_round_bet : [Int] = [] // the amount of money bet by each player in a betting rounf
    var stats : [String : [Int]] = [:] // a dictionary with username of the player as key and
                                       //[rounds won ,balance] as the value
    var total_rounds = 0  // number of rounds played
    var time_counter = 45 // min time for the a player to make his decision
    
    override init(){}
    
    // initializes all the game state variables after decoding an encoded game state
    // object through the multipeer instance
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
        time_counter  = coder.decodeInteger(forKey: "time_counter")
    }
    
    // encodes all the game state variables to make it easier to send through the multipeer instance
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
        coder.encode(time_counter, forKey: "time_counter")
    }
}
