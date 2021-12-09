//
//  PokerViewController.swift
//  Blue Chip Poker
//
//  Created by Akash Akkiraju on 11/26/21.
//

import Foundation
import UIKit
import MultiPeer

// Enum class indicating whether the data type being sent through multipeer is GameState or String type
enum DataType: UInt32 {
  case GameState = 1
  case String = 2
}

class PokerViewController: UIViewController, MultiPeerDelegate {

    // player 1 label, cards, and balance
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var p1card1: UIImageView!
    @IBOutlet weak var p1card2: UIImageView!
    @IBOutlet weak var p1Funds: UILabel!
    
    // player 2 label, cards, and balance
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var p2card1: UIImageView!
    @IBOutlet weak var p2card2: UIImageView!
    @IBOutlet weak var p2Funds: UILabel!
    
    // player 3 label, cards, and balance
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var p3card1: UIImageView!
    @IBOutlet weak var p3card2: UIImageView!
    @IBOutlet weak var p3Funds: UILabel!
    
    // label for the money in the pot
    @IBOutlet weak var potLabel: UILabel!
    
    // cards on the table
    @IBOutlet weak var flop1: UIImageView!
    @IBOutlet weak var flop2: UIImageView!
    @IBOutlet weak var flop3: UIImageView!
    @IBOutlet weak var flop4: UIImageView!
    @IBOutlet weak var flop5: UIImageView!
    
    // buttons for actions of fold, bet, raise and check
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!

    // Label which displays the big blind, small blind and the dealer
    @IBOutlet weak var gameStat: UILabel!
    
    // timer label which shows the time left for a player to make a move
    @IBOutlet weak var timer: UILabel!
    
    var curr_state = GameState() // the current state of the poker table
    var big_blind_bet: Int = 2 // the bet amount for the big blind
    var segueVar : Int = 0 // variable which indicates if the player is the host. This variable is set by the
                           //HostViewController
    var players_filtered: [String] = [] // the players in the game. This variable is set by the HostViewController
    var funds_filtered: [Int] = [] // funds of the players. This variable is set by the HostViewController
    var min_time : Int = 45  // time for a player to make his decision.  This variable is set by the                                 //HostViewController
    
    var curr_timer : Timer? // Timer object to run when a player begins his turn
    var check_time: Int = 45 // updating the time to be set for the time label
    
    var alljoined : Int = 0 // variable indicating the number of pople currently joined in the game
    var triggered : Int  = 0 // variable indicating player is waiting for the host to start the next round
    var clicked : Int = 0  // variable indicating whether a button has been clicked in the end round pop-up
    var initial_connected : Int = 0 // number of players initially connected in the game
    var initial_check: Bool = false // check to update the number of players connected for players
                                    // apart from the host
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting the multipeer delegate
        MultiPeer.instance.delegate = self
        
        
        if (segueVar == 1){ // the current player is the host
            
            let devices = players_filtered
            initial_connected = players_filtered.count // set the number of initially connected players
            
            var curr_players = [Player(name: UserDefaults.standard.string(forKey: "username")!)]
            var curr_funds = [100] // default value for balance for the  host
            let balance = UserDefaults.standard.string(forKey: "balance") // get the host balance
            if balance != nil{
                curr_funds[0] = Int(balance ?? "100")! // update the host's balance if found
            }
            var players_in_round = [true] // set host to not have folded
            curr_state.stats[UserDefaults.standard.string(forKey: "username")!] = [0,0] // initialize the stats
            curr_state.players_round_bet.append(-1) // initliaze the bet amount for host to be -1
            
            // iterate through all the players
            for i in 0...(devices.count-1){
                curr_state.stats[devices[i]] = [0,0] // update the stats for this player
                curr_players.append(Player(name: devices[i])) // add a player to the game state
                curr_funds.append(funds_filtered[i]) // add the funds of the player to the game state
                players_in_round.append(true) // set the player to have not folded
                curr_state.players_round_bet.append(-1) // initialze the bet amount of each player to be -1
            }

            
            // set the big blind, dealer, small blind, curr_player, min_time
            curr_state.big_blind_ind = 0%curr_players.count
            curr_state.small_blind_ind = 1%curr_players.count
            curr_state.dealer_ind = 2%curr_players.count
            curr_state.curr_player_ind = 2%curr_players.count
            curr_state.players = curr_players
            curr_state.funds_players = curr_funds
            curr_state.players_round = players_in_round
            curr_state.time_counter = min_time
        
            // shuffle the deck
            curr_state.dealer.currentDeck.shuffle()
            
            // update the players balances after big blind and small blind money taken at the beginning of round
            curr_state.funds_players[curr_state.big_blind_ind] -= big_blind_bet
            curr_state.funds_players[curr_state.small_blind_ind] -= big_blind_bet/2
            
            // set that a previous bet has been made because of the big blind bet
            curr_state.prev_bet = 1
            
            // update the players balances for the first betting round and also the stats after big blind and
            // small blind money taken at the beginning of round
            curr_state.players_round_bet[curr_state.big_blind_ind] = big_blind_bet
            curr_state.players_round_bet[curr_state.small_blind_ind] = big_blind_bet/2
            curr_state.stats[curr_state.players[curr_state.big_blind_ind].name!]![1] -= big_blind_bet
            curr_state.stats[curr_state.players[curr_state.small_blind_ind].name!]![1] -= big_blind_bet/2
            
            // update the money in the pot
            curr_state.money_in_pot += big_blind_bet + big_blind_bet/2

            // deal a hand to each player
            for i in 0...(curr_state.players.count-1){
                curr_state.players[i].cards = curr_state.dealer.dealHand()
            }
            
            // hide all the buttons in order to wait for all the other players to begin their game
            hideAllButtons()
        
        }
        else{ // the current player has joined the game, and is not the host
            
            // send heartbeat message to the host that the player has joined the game
            MultiPeer.instance.send(object: "HI", type: DataType.String.rawValue)
            //hide all the buttons in order to wait for the host to start the game
            hideAllButtons()
            
        }


    }
    
/* -------------------------------------------------------------------------- */
/*                              GAMEPLAY FUNCTIONS                            */
/* -------------------------------------------------------------------------- */
    
    // Update the poker table board and send the updated game state
    func handleBoard(){
        handleAction() // update the gamestate depending on the current stage of the game
        
        // send the updated game state
        MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
        show_curr_player_cards()
    }
    
    // Update the game state depending on the current stage of the game
    func handleAction(){
        // calculate the number of non-folded players
        var non_folded = 0
        var non_folded_id = -1
        for i in 0...curr_state.players.count-1{
            if(curr_state.players_round[i] == true){
                non_folded_id = i
                non_folded += 1
            }
        }
        if(non_folded == 1){ // if only one player left, declare the player as the winner and update stats
            curr_state.win_index = non_folded_id
            curr_state.funds_players[non_folded_id] += curr_state.money_in_pot
            curr_state.showdown = true
            curr_state.total_rounds += 1
            curr_state.stats[curr_state.players[curr_state.win_index].name!]![0] += 1
            curr_state.stats[curr_state.players[curr_state.win_index].name!]![1] += curr_state.money_in_pot
            return
        }
        let curr_bet = max_bet_in_round()
        var end_action = true // variable indicating everyone has equal money in the pot
            for i in 1...curr_state.players.count{
                let temp_player_ind = (curr_state.curr_player_ind+i)%curr_state.players.count
                
                // check if everyone has put in equal money in the pot
                if(curr_state.players_round_bet[temp_player_ind] != curr_bet && curr_state.players_round[temp_player_ind] == true) {
                    end_action = false; // not equal amount put in , so keep continuing the bettng round
                    nextPlayer(index: curr_state.curr_player_ind)
                    break;
                }
            }
            if (end_action == true) {
                resetBets() // betting round has ended, so reset the bets for the new betting round
                self.curr_state.prev_bet = 0
                if (curr_state.flop_done == false) { // update the next player after pre-flop is done
                    curr_state.preflop = false
                    curr_state.dealer.dealFlop() // deal the flop
                    curr_state.flop_done = true
                    // if small blind has folded, find the next player
                    if (curr_state.players_round[curr_state.small_blind_ind] == false) {
                        nextPlayer(index: curr_state.small_blind_ind)
                    }
                    else {
                        curr_state.curr_player_ind = curr_state.small_blind_ind
                    }
                }
                else if (curr_state.turn_done == false){ // update the next player after flop is done
                    curr_state.dealer.dealTurn() // deal the turn
                    curr_state.turn_done = true
                    nextPlayer(index: curr_state.curr_player_ind)
                    // if small blind has folded, find the next player
                    if (curr_state.players_round[curr_state.small_blind_ind] == false) {
                        nextPlayer(index: curr_state.small_blind_ind)
                    }
                    else {
                        curr_state.curr_player_ind = curr_state.small_blind_ind
                    }
                }
                else if (curr_state.river_done == false){ // update the next player after turn is done
                    curr_state.dealer.dealRiver() // deal the river
                    curr_state.river_done = true
                    nextPlayer(index: curr_state.curr_player_ind)
                    // if small blind has folded, find the next player
                    if (curr_state.players_round[curr_state.small_blind_ind] == false) {
                        nextPlayer(index: curr_state.small_blind_ind)
                    }
                    else {
                        curr_state.curr_player_ind = curr_state.small_blind_ind
                    }
                }
                else{ // the round has ended and have to decide a winner
                    var set = false
                    var winner = ""
                    var win_ind = 0
                    for i in 0...(curr_state.players.count-1){
                        if (curr_state.players_round[i] == true){
                            // evaluate the hand of a player
                            curr_state.players[i].hand = curr_state.dealer.evaluateHandAtRiver(player: curr_state.players[i])
                            if (set == false){
                                winner = curr_state.players[i].name! // set a dummy winner
                                win_ind = i
                                set = true
                            }
                        }
                    }
                    
                    // calculate the actual winner here by comparing all the player's winning hands
                    for i in 0...(curr_state.players.count-1){
                        if (curr_state.players_round[win_ind] == true && curr_state.players_round[i] == true){
                            let temp_win = curr_state.dealer.findHeadsUpWinner(player1: curr_state.players[win_ind], player2:curr_state.players[i]).name
                            if(temp_win != winner){
                                win_ind = i
                                winner = temp_win! // update current winner
                            }
                        }
                    }
                    
                    // update the winner and stats for the round
                    curr_state.stats[winner]![0] += 1
                    curr_state.stats[winner]![1] += curr_state.money_in_pot
                    curr_state.win_index = win_ind
                    curr_state.funds_players[win_ind] += curr_state.money_in_pot
                    curr_state.showdown = true
                    curr_state.total_rounds += 1
                }
        }
    }
    

/* -------------------------------------------------------------------------- */
/*                      USER ACTION FUNCTIONS                                 */
/* -------------------------------------------------------------------------- */
    
    // called when the user decided to fold
    @IBAction func callFold(_ sender: Any) {
        curr_state.players_round[curr_state.curr_player_ind] = false // update the array element to signify the
                                                                    // player has folded
        handleBoard() // handle the gameplay after this action
    }

    // called when the user decides to raise
    @IBAction func callRaise(_ sender: Any) {
        bet_pop_up(bet: false)

    }
    
    // called when user clicks on call/check
    @IBAction func callCheck(_ sender: Any) {
        // update the bet money of the player to be 0 if it is initialized to be -1
        if (self.curr_state.players_round_bet[self.curr_state.curr_player_ind] == -1 ){
            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] = 0
        }
        
        // calculate the amount of money to call
        let amount = max_bet_in_round() - curr_state.players_round_bet[curr_state.curr_player_ind]
        curr_state.money_in_pot += amount // update the pot
        potLabel.text = "Pot: $" + String(curr_state.money_in_pot)
        curr_state.funds_players[curr_state.curr_player_ind] -= amount // update the balance of the player
        self.curr_state.stats[self.curr_state.players[self.curr_state.curr_player_ind].name!]![1] -= amount
        self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += amount // update the amount put by
                                                                                //the player in this round
        handleBoard() // handle the gameplay after this action
    }

    // Called when user clicks on bet
    @IBAction func callBet(_ sender: Any) {
        bet_pop_up(bet: true)
    }

    // Helper pop up for either betting or raising
    func bet_pop_up(bet: Bool){
        var alert_txt = "Raise"
        if bet == true { // update alert based whether it's a raise or a bet
            alert_txt = "Bet"
            curr_state.prev_bet = 1 // indicate a bet is being made
        }
        
        // initialize the alert variable
        let alert = UIAlertController(title: alert_txt + "!" , message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the amount (in dollars)"
        }

        // close the pop up if cancel selected
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // bet action is selected
        let betAction = UIAlertAction(title: alert_txt + "!" , style: .default, handler: { alt -> Void in

            // this code runs when the user hits the "Place bet!" button
            var raised: Int? = Int(alert.textFields![0].text!)
            
            // update the bet money of the player to be 0 if it is initialized to be -1
            if (self.curr_state.players_round_bet[self.curr_state.curr_player_ind] == -1 ){
                self.curr_state.players_round_bet[self.curr_state.curr_player_ind] = 0
            }
            
            if (bet == false) {
                // calculate the amount to raise
                raised = raised! + self.max_bet_in_round() - self.curr_state.players_round_bet[self.curr_state.curr_player_ind ]
            }

            // check if there are enough funds and ask the user to try again if not sufficient funds
            if (raised! > self.curr_state.funds_players[self.curr_state.curr_player_ind]){
                let alert_no_funds = UIAlertController(title:  "Not enough funds!" , message: "", preferredStyle: .alert)
                let try_again_action = UIAlertAction(title: "Try again", style: .cancel, handler: { alt -> Void in
                    self.bet_pop_up(bet: bet)
                })
                alert_no_funds.addAction(try_again_action)
                self.present(alert_no_funds, animated: true, completion: nil)
                return
            }
            
            self.curr_state.money_in_pot += raised! // update the money in the pot and the label
            self.potLabel.text = "Pot: $" + String(self.curr_state.money_in_pot)

            // update the money for the balance array, stats, and the amount bet in this current round
            self.curr_state.funds_players[self.curr_state.curr_player_ind] -= raised!
            self.curr_state.stats[self.curr_state.players[self.curr_state.curr_player_ind].name!]![1] -= raised!
            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += raised!
            self.handleBoard()

        })

        alert.addAction(cancelAction)
        alert.addAction(betAction)

        self.present(alert, animated: true, completion: nil) // present the pop-up

    }

/* -------------------------------------------------------------------------- */
/*                      RESET ROUND AND BETS FUNCTIONS                        */
/* -------------------------------------------------------------------------- */
    
    // Update all the game state variables after a round ends
    func resetRound(){
        // update the dealer index
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
        
        
        // deduct money from the new big blind and small blind and update the variables accordingly
        curr_state.prev_bet = 1 // indicate a bet has been made
        curr_state.players_round_bet[curr_state.big_blind_ind] = big_blind_bet
        curr_state.players_round_bet[curr_state.small_blind_ind] = big_blind_bet/2
        curr_state.funds_players[curr_state.big_blind_ind] -= big_blind_bet
        curr_state.funds_players[curr_state.small_blind_ind] -= big_blind_bet/2
        curr_state.stats[curr_state.players[curr_state.big_blind_ind].name!]![1] -= big_blind_bet
        curr_state.stats[curr_state.players[curr_state.small_blind_ind].name!]![1] -= big_blind_bet/2
        curr_state.money_in_pot += big_blind_bet + big_blind_bet/2 // update the money in the pot
    }
    
    // Reset the bets in a betting round after flop, turn, river
    func resetBets(){
        for i in 0...curr_state.players_round_bet.count-1{
            curr_state.players_round_bet[i] = -1
        }
    }
    
/* -------------------------------------------------------------------------- */
/*                    SUMMARY AND ANNOUNCE WINNER FUNCTIONS                    */
/* -------------------------------------------------------------------------- */
    
    func summary(){
        let rounds_won = String(curr_state.stats[UserDefaults.standard.string(forKey: "username")!]![0])
        let funds_won = String(curr_state.stats[UserDefaults.standard.string(forKey: "username")!]![1])
        let total = String(curr_state.total_rounds)
        
        // Pop-ip alert for showing the summary of rounds won, money won
        let alert = UIAlertController(title: "Summary" , message: "Rounds won: " + rounds_won + "/" + total + "\nMoney gained/lost: " + funds_won, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler:  { alt -> Void in
            
            // take you back to the homescreen
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            self.present(nextViewController, animated:true, completion:nil)
        })
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func announceWinner(){
        showdown() // show all the cards on the table
        hideAllButtons() // hide all buttons before the next round starts
        gameStat.text = "Waiting for other players"
        potLabel.text = "Pot: $0"
        
        // check the number of non-folded players
        var non_folded = 0
        for i in 0...curr_state.players.count-1{
            if(curr_state.players_round[i] == true){
                non_folded += 1
            }
        }
        
        // Setting the alert variable and the winner username
        let name = curr_state.players[curr_state.win_index].name!
        var alert = UIAlertController(title: "Round Over!" , message: "Winner of this round is " + name +
                                      "\nDo you wish to continue?", preferredStyle: .alert)
        
        if(non_folded > 1){
            // If more than one non-folded players evaluate all thee hands
            curr_state.dealer.evaluateHandAtRiver(for: &curr_state.players[curr_state.win_index])
            let handName = curr_state.players[curr_state.win_index].handNameDescription!
            let hand = curr_state.players[curr_state.win_index].handDescription!
     
            // Display the winning hand
            alert = UIAlertController(title: "Round Over!" , message: "Winner of this round is " + name +
                                          "\nWinning Hand: " + handName + "\n" + hand + "\nDo you wish to continue?", preferredStyle: .alert)
        }

        self.alljoined = 0 // set this variable to 0 to see how many players want to continue
        MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue) // send the message to reset for                                                   // all the other multipeer connected players
        
        // Handling of the exiting of the game
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler:  { alt -> Void in
            
            // calculate the index of the player who has agreed to quit the game
            var ind = 0
            for i in 0...self.curr_state.players.count-1{
                if self.curr_state.players[i].name == UserDefaults.standard.string(forKey: "username")!{
                    ind = i
                    // update the balance before exiting
                    UserDefaults.standard.set(self.curr_state.funds_players[i], forKey: "balance")
                    break
                }
            }
            
            self.clicked = 1 // variable set to indicate a button has been clicked on the continue/exit screen
            self.curr_state.players.remove(at: ind) //remove the player not wishing to continue
            self.curr_state.funds_players.remove(at: ind) // remove the player balance too
            
            // End the game for all if there is only one player left in the game after removing the player
            if self.curr_state.players.count <= 1{
                // send the message to end game for all mutlipeer connected players
                MultiPeer.instance.send(object: "End", type: DataType.String.rawValue)
                self.summary()
                return
            }
            self.resetRound() // reset the round after removing the player
            self.summary() // display the summary stats of the player exiting
            self.initial_connected = 10 // dummy value for this player to ensure the screen doesn't get updated
                                        // for the exiting player
            
            // Send the curr game state after removing the player and also indicate that a player has been deleted
            MultiPeer.instance.send(object: "Delete", type: DataType.String.rawValue)
            MultiPeer.instance.send(object: self.curr_state, type: DataType.GameState.rawValue)
        })
        
        
        // Handling of the continuing of the game
        let continueAction = UIAlertAction(title:  "Yes!" , style: .default, handler: { alt -> Void in
            self.clicked = 1 // variable set to indicate a button has been clicked on the continue/exit screen
            
            // send the message to all mutipeer players that the player wishes to continue
            MultiPeer.instance.send(object: "Continue", type: DataType.String.rawValue)
            for i in 0...self.curr_state.players.count-1{
                if self.curr_state.players[i].name == UserDefaults.standard.string(forKey: "username")!{
                    // update the balance before continuing
                    UserDefaults.standard.set(self.curr_state.funds_players[i], forKey: "balance")
                    break
                }
            }
            self.hideAllCards() // hide the cards for the player before the next round starts
            
            // check if everyone else is ready to proceed to the next round
            if(self.alljoined >= self.initial_connected){
                if self.triggered == 1{
                    self.resetRound() // if everyone decided to continue, reset the round
                }
                else{
                    self.triggered = 1  // indicate that the current player is ready to continue to the next round
                }
                
                // send the updated game state after choosing to continue
                MultiPeer.instance.send(object: self.curr_state, type: DataType.GameState.rawValue)
                self.show_curr_player_cards()
                self.clicked = 0 // reset the variable to indicate a button has not been clicked yet on the
                                // continue screen
                
                // send the message that the round has been reset and proceed to move to the next round
                MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue)

            }
            
        })

        alert.addAction(cancelAction)
        alert.addAction(continueAction)

        self.present(alert, animated: true, completion: nil) // display the pop up
    }
    
/* -------------------------------------------------------------------------- */
/*                     MULTIPEER COMMUNICATION FUNCTIONS                      */
/* -------------------------------------------------------------------------- */
    
    // Handle receiving of data from other players coneected in the Multipeer instance
    func multiPeer(didReceiveData data: Data, ofType type: UInt32, from peerID: MCPeerID) {
        switch type {
          case DataType.GameState.rawValue:
            let state:GameState = data.convert() as! GameState
                curr_state = state // update the gamestate after recieving
                if initial_check == false{
                    initial_connected = curr_state.players.count - 1 // update the number of players connected
                                                                    // for players who aren't the host
                    initial_check = true
                }
            if initial_check == true && initial_connected == 0{
                // if all players have left the game and there is only one player exit the game by showing a
                // pop up of the summary screen
                summary()
            }
                if triggered == 1{ // indicates whether all the players have joined
                    show_curr_player_cards() // show the player cards
                }
            break
            
          case DataType.String.rawValue:
            let state = data.convert() as! String
            if (state == "HI"){ // receieved a heartbeat message that a player has joined
                alljoined += 1
                if(initial_connected != 0 && alljoined >= initial_connected){
                    // Indicate to all players that all the players have joined and send the updated game state
                    MultiPeer.instance.send(object: "Trigger", type: DataType.String.rawValue)
                    MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                    show_curr_player_cards() // show the curr player cards
                    triggered = 1
                }
            }
            if(state == "Continue"){ // recieved a continue to next round message
                alljoined += 1
                if(alljoined >= initial_connected){ // indicates if everyone in the game has made their decision to
                                                    // continue/leave
                    if(clicked == 1){
                        if triggered == 1{
                            resetRound() // ask the host to rest the round
                        }
                        else{
                            triggered = 1 // indicates the current player is waiting for the host to start the
                                         // next round
                        }
                        // send the updated game states and ask the players to reset for the next round
                        MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                        show_curr_player_cards()
                        clicked = 0
                        MultiPeer.instance.send(object: "Reset", type: DataType.String.rawValue)
                    }
                }
            }
            
            
            if(state == "Trigger"){
                triggered = 1 // Indicate that a player is waiting for the host to start a round
            }
            if(state == "Reset"){
                alljoined = 0 // reset the round and initialze the variable to 0 and update it as other people
                            // choose to continue the round
                clicked = 0
            }
            if(state == "Delete"){ // indicates a player has been deleted/exited
               initial_connected -= 1
            }
            if(state == "End"){ // end the game since everyone exited
                summary()
            }
            break
                    
          default:
            break
        }
    }
    
    // Debugging: Print if the connected device changes
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print(MultiPeer.instance.connectedDeviceNames)
    }
    
/* -------------------------------------------------------------------------- */
/*                                TIMER FUNCTIONS                             */
/* -------------------------------------------------------------------------- */
    
    // start the timer for the player to make his decision
    func startTimer() {
      guard curr_timer == nil else { return }
        check_time = curr_state.time_counter
      curr_timer =  Timer.scheduledTimer(
        timeInterval: TimeInterval(1.0),
          target      : self,
          selector    : #selector(updateCounter),
          userInfo    : nil,
          repeats     : true)
        timer.isHidden = false
    }
    
    // update the time counter and the time label
    @objc func updateCounter() {
        if check_time > 0 {
            check_time -= 1
            timer.text = "Remaining: " + String(check_time) + "s"
        }
        else{
            var non_folded = 0
            for i in 0...curr_state.players.count-1{
                if(curr_state.players_round[i] == true){
                    non_folded += 1
                }
            }
            if non_folded > 1{
                callFold(self)
            }
            else{
                stopTimer()
            }
        }
    }
    
    // stop the timer if it isn't the player's turrn or the move has been made
    func stopTimer() {
      curr_timer?.invalidate()
      curr_timer = nil
        timer.isHidden = true
        timer.text = "Remaining: " + String(curr_state.time_counter) + "s"
    }

    
/* -------------------------------------------------------------------------- */
/*                    DISPLAYING CARDS AND BUTTONS FUNCTIONS                  */
/* -------------------------------------------------------------------------- */
    
    // Display the cards of the current player
    func show_curr_player_cards(){
        
        // call summary function to exit the game if there is only one player left at the table
        if curr_state.players.count == 1{
            summary()
        }
        
        showTableCards() // show all the common table cards like flop, river and turrn
        var index = 0 // index of the current player
        
        for i in 0...(curr_state.players.count-1){
            if(curr_state.players[i].name == UserDefaults.standard.string(forKey: "username")!){
                index = i
            }
            // Update the current player by changing the color of the username of the current player
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
            // hide all the buttons and stop timer if the player isn't the curr player's turn
            hideAllButtons()
            stopTimer()
        }
        else{
            // if the player is the curr player then start the timer and enable the buttons for user action
            stopTimer()
            startTimer()
            buttons_enable()
        }
        
        potLabel.text = "Pot: $" + String(curr_state.money_in_pot) // display the money in the pot
        
        if curr_state.players.count == 2{
            p3card1.isHidden = true
            p3card2.isHidden = true
            player3Label.isHidden = true
            p3Funds.isHidden = true
        }
        
        // show the cards of the current player
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
        if(curr_state.showdown == true){ // if the round has ended, announce the winner in a pop up
            announceWinner()
        }
    }
    
    // show all the common table cards and labels for all the players
    func showTableCards(){
        
        // display big blind, small blind and dealer name
        let small_blind = curr_state.players[curr_state.small_blind_ind].name! + " ($" + String(big_blind_bet/2) + ")"
        let big_blind = curr_state.players[curr_state.big_blind_ind].name! + " ($" + String(big_blind_bet) + ")"
        let dealer_name = curr_state.players[curr_state.dealer_ind].name
        gameStat.text = "Big Blind: " + big_blind +
        "\nSmall Blind: " + small_blind + "\nDealer: " + dealer_name!
        
        // pre-flop stage: don't show any cards
        if(curr_state.flop_done == false){
            flop1.image = UIImage(named: "back_w")
            flop2.image = UIImage(named: "back_w")
            flop3.image = UIImage(named: "back_w")
            flop4.image = UIImage(named: "back_w")
            flop5.image = UIImage(named: "back_w")
        }
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        
        // Reveal 3 cards for the flop stage
        if(curr_state.flop_done == true){
            flop1.image = flop_cards?[0]
            flop2.image = flop_cards?[1]
            flop3.image = flop_cards?[2]
        }
        
        // Reveal 1 card for the turn stage
        if(curr_state.turn_done == true){
            flop4.image = flop_cards?[3]
        }
        // Reveal 1 card for the river stage
        if(curr_state.river_done == true){
            flop5.image = flop_cards?[4]
        }
        
        // Display the balances and names of all the players in the game
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
            if (curr_state.players_round[i] == false){ // if a player has folded
                // show that a player has folded by indicating that in the
                // label of the username and hiding the cards
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
    
    // display all the cards on the table for the final showdown
    func showdown(){
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
    
    // Hides all the cards on the table to just show the back of the cards
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
    
    // hides all the buttons on the table and the timer
    func hideAllButtons(){
        betButton.isHidden = true
        foldButton.isHidden = true
        raiseButton.isHidden = true
        checkButton.isHidden = true
        timer.isHidden = true
        timer.text = "Remaining: " + String(curr_state.time_counter) + "s"
    }

    // enable the buttons on the table depending on whether a prev bet has been made and the timer is also enabled
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
        timer.isHidden = false
    }
    
    // display the images on the table based on the cards the player has
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
    
/* -------------------------------------------------------------------------- */
/*                                MISCELLANEOUS                               */
/* -------------------------------------------------------------------------- */
    
    // Calculate the max bet in the current betting round to either call/raise
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
    
    // set the next player in the poker table after the current player has made his turn
    func nextPlayer(index: Int){
        var i = 1
        while (i <= curr_state.players.count &&
               curr_state.players_round[(index + i)%curr_state.players.count] == false){
            i += 1
        }
        
        curr_state.curr_player_ind =  (index + i) % curr_state.players.count
    }
    
    
    // Transition back to the Home/MainView Controller
    @IBAction func Homescreen(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    // only support landscape view
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    // enable autorotate
    override var shouldAutorotate: Bool {
        return true
    }
    
}
