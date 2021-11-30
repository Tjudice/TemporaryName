//
//  GameViewModel.swift
//  BlueChipPoker
//
//  Created by Ameer Mubarez on 11/30/21.
//

import Foundation
import MultiPeer

enum DataType: UInt32 {
    case GameState = 1
    case String = 2
}

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
    }
}

class GameViewModel: ObservableObject, MultiPeerDelegate {
    
    //@IBOutlet weak var player1Label: UILabel!
    //@IBOutlet weak var p1card1: UIImageView!
    //@IBOutlet weak var p1card2: UIImageView!
    @Published var player1Label : String
    @Published var p1card1 : String
    @Published var p1card2 : String
    
    
    
    //@IBOutlet weak var player2Label: UILabel!
    //@IBOutlet weak var p2card1: UIImageView!
    //@IBOutlet weak var p2card2: UIImageView!
    @Published var player2Label : String
    @Published var p2card1 : String
    @Published var p2card2 : String
    
    
    //@IBOutlet weak var player3Label: UILabel!
    //@IBOutlet weak var p3card1: UIImageView!
    // @IBOutlet weak var p3card2: UIImageView!
    @Published var player3Label : String
    @Published var p3card1 : String
    @Published var p3card2 : String
    
    
    
    //@IBOutlet weak var potLabel: UILabel!
    @Published var potLabel : String
    
    // @IBOutlet weak var flop1: UIImageView!
    // @IBOutlet weak var flop2: UIImageView!
    // @IBOutlet weak var flop3: UIImageView!
    // @IBOutlet weak var flop4: UIImageView!
    // @IBOutlet weak var flop5: UIImageView!
    @Published var flop1 : String
    @Published var flop2 : String
    @Published var flop3 : String
    @Published var flop4 : String
    @Published var flop5 : String
    
    
    
    /*
     @IBOutlet weak var foldButton: UIButton!
     @IBOutlet weak var betButton: UIButton!
     @IBOutlet weak var raiseButton: UIButton!
     @IBOutlet weak var checkButton: UIButton!
     */
    @Published var foldButtonHidden : Bool
    @Published var raiseButtonHidden : Bool
    @Published var betButtonHidden : Bool
    @Published var checkButtonHidden : Bool
    
    //@IBOutlet weak var gameStat: UILabel!
    @Published var gameStat : String
    
    var curr_state = GameState()
    var segueVar : Int
    var alljoined : Int = 0
    var triggered : Int  = 0
    
    /*override func viewDidLoad() {
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
     
     for i in 0...(curr_state.players.count-1){
     curr_state.players[i].cards = curr_state.dealer.dealHand()
     }
     
     MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
     hideAllButtons()
     
     }
     else{
     MultiPeer.instance.send(object: "HI", type: DataType.String.rawValue)
     hideAllButtons()
     
     }
     
     
     }*/
    
    init(segueVar : Int){
        player1Label = ""
        p1card1 = "back_w"
        p1card2 = "back_w"
        
        player2Label = ""
        p2card1 = "back_w"
        p2card2 = "back_w"
        
        player3Label = ""
        p3card1 = "back_w"
        p3card2 = "back_w"
        
        flop1 = "back_w"
        flop2 = "back_w"
        flop3 = "back_w"
        flop4 = "back_w"
        flop5 = "back_w"
        
        potLabel = "Pot: $0"
        
        gameStat = ""
        
        self.segueVar = segueVar
        
        foldButtonHidden = false
        raiseButtonHidden = false
        betButtonHidden = false
        checkButtonHidden = false
        MultiPeer.instance.delegate = self
        startGame()
    }
    
    func startGame(){
        MultiPeer.instance.delegate = self
        print("Poker %d", MultiPeer.instance.connectedDeviceNames)
        
        if (segueVar == 1){
            let devices = MultiPeer.instance.connectedDeviceNames
            
            var curr_players : [Player] = []
            var curr_funds = [100]
            var players_in_round = [true]
            
            for i in 0...(devices.count-1){
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
            
            for i in 0...(curr_state.players.count-1){
                curr_state.players[i].cards = curr_state.dealer.dealHand()
            }
            
            MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
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
            print("RECEIVED")
            show_curr_player_cards()
            break
            
        case DataType.String.rawValue:
            let state = data.convert() as! String
            if (state == "HI" && segueVar == 1){
                alljoined += 1
                if(alljoined == MultiPeer.instance.connectedDeviceNames.count){
                    MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                    alljoined = 0
                    show_curr_player_cards()
                }
            }
            if (state == "Continue" && segueVar == 1){
                alljoined += 1
                if(alljoined == MultiPeer.instance.connectedDeviceNames.count && triggered == 1){
                    resetRound()
                    curr_state.showdown = false
                    MultiPeer.instance.send(object: curr_state, type: DataType.GameState.rawValue)
                    alljoined = 0
                    triggered = 0
                    show_curr_player_cards()
                }
            }
            break
            
        default:
            break
        }
    }
    
    
    func hideAllCards(){
        flop1 = "back_w"
        flop2 = "back_w"
        flop3 = "back_w"
        flop4 = "back_w"
        flop5 = "back_w"
        for i in 0...(curr_state.players.count-1){
            if(i == 0){
                p1card1 = "back_w"
                p1card2 = "back_w"
            }
            if(i == 1){
                p2card1 = "back_w"
                p2card2 = "back_w"
            }
            if (i == 2){
                p3card1 = "back_w"
                p3card2 = "back_w"
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
        curr_state.prev_bet = 0
        curr_state.win_index = -1
        curr_state.big_blind_ind = (curr_state.big_blind_ind+1)%curr_state.players.count
        curr_state.small_blind_ind = (curr_state.small_blind_ind+1)%curr_state.players.count
        curr_state.dealer_ind = (curr_state.dealer_ind+1)%curr_state.players.count
        curr_state.curr_player_ind = (curr_state.dealer_ind + 1)%curr_state.players.count
        curr_state.dealer = Dealer(evaluator: Evaluator())
        curr_state.players_round_bet = [Int]()
        for i in 0...(curr_state.players.count-1){
            curr_state.players[i] = Player(name: curr_state.players[i].name!)
            curr_state.players[i].cards = curr_state.dealer.dealHand()
            curr_state.players_round.append(true)
            curr_state.players_round_bet.append(-1)
            if(i == 0){
                p1card1 = "back_w"
                p1card2 = "back_w"
            }
            if(i == 1){
                p2card1 = "back_w"
                p2card2 = "back_w"
            }
            if (i == 2){
                p3card1 = "back_w"
                p3card2 = "back_w"
            }
        }
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
            return
        }
        var curr_bet = self.curr_state.prev_bet
        if (curr_bet == -1) {
            curr_state.players_round_bet[curr_state.curr_player_ind] = 0
            curr_bet = 0
        }
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
                
                curr_state.win_index = win_ind
                curr_state.funds_players[win_ind] += curr_state.money_in_pot
                curr_state.showdown = true
            }
            
        }
    }
    
    func announceWinner(){
        showdown()
        hideAllButtons()
        gameStat = "Waiting for other players"
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
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title:  "Yes!" , style: .default, handler: { alt -> Void in
            if(self.segueVar == 1){
                self.triggered = 1
            }
            
            MultiPeer.instance.send(object: "Continue", type: DataType.String.rawValue)
            self.hideAllCards()
            if(self.alljoined == MultiPeer.instance.connectedDeviceNames.count && self.triggered == 1){
                self.resetRound()
                self.curr_state.showdown = false
                MultiPeer.instance.send(object: self.curr_state, type: DataType.GameState.rawValue)
                self.alljoined = 0
                self.triggered = 0
                self.show_curr_player_cards()
            }
            
        })
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        //self.present(alert, animated: true, completion: nil)
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
                p1card1 = p_cards[0]
                p1card2 = p_cards[1]
            }
            if(i == 1 && curr_state.players_round[i] != false){
                p2card1 = p_cards[0]
                p2card2 = p_cards[1]
            }
            if (i == 2 && curr_state.players_round[i] != false){
                p3card1 = p_cards[0]
                p3card2 = p_cards[1]
            }
        }
    }
    
    
    func show_curr_player_cards(){
        // Show folded beside folded usernames and big blind, small blind, and current player
        
        showTableCards()
        print("show cards func")
        var index = 0
        
        for i in 0...(curr_state.players.count-1){
            if(curr_state.players[i].name == UIDevice.current.name){
                index = i
            }
            /*if(curr_state.curr_player_ind == 0){
             player1Label.textColor = .tintColor
             player2Label.textColor = .white
             player3Label.textColor = .white
             }
             if(curr_state.curr_player_ind == 1){
             player2Label.textColor = .tintColor
             player1Label.textColor = .white
             player3Label.textColor = .cyan
             }
             if(curr_state.curr_player_ind == 2){
             player3Label.textColor = .tintColor
             player2Label.textColor = .white
             player1Label.textColor = .white
             }*/
        }
        
        if (curr_state.curr_player_ind != index){
            hideAllButtons()
        }
        else{
            buttons_enable()
        }
        
        potLabel = "Pot: $" + String(curr_state.money_in_pot)
        
        /*if curr_state.players.count == 2{
         p3card1.isHidden = true
         p3card2.isHidden = true
         player3Label.isHidden = true
         }*/
        
        let p_cards = getImages(for: curr_state.players[index].cards)
        if(index == 0){
            p1card1 = p_cards[0]
            p1card2 = p_cards[1]
        }
        if(index == 1){
            p2card1 = p_cards[0]
            p2card2 = p_cards[1]
        }
        if (index == 2){
            p3card1 = p_cards[0]
            p3card2 = p_cards[1]
        }
        if(curr_state.showdown == true){
            announceWinner()
        }
    }
    
    
    func hideAllButtons(){
        betButtonHidden = true
        foldButtonHidden = true
        raiseButtonHidden = true
        checkButtonHidden = true
    }
    
    func buttons_enable(){
        if (curr_state.prev_bet == 0){
            foldButtonHidden = true
            raiseButtonHidden = true
            betButtonHidden = false
            checkButtonHidden = false
        }
        else{
            betButtonHidden = true
            foldButtonHidden = false
            checkButtonHidden = false
            raiseButtonHidden = false
        }
    }
    
    func bet_pop_up(bet: Bool){
        var alert_txt = "Raise"
        var alert = UIAlertController(title: alert_txt + "!" , message: "", preferredStyle: .alert)
        if bet == true {
            alert_txt = "Bet"
            alert = UIAlertController(title: alert_txt + "!" , message: "Amount should be a minimum of $" + String(curr_state.prev_bet), preferredStyle: .alert)
        }
        
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
            let temp = self.curr_state.prev_bet
            self.curr_state.prev_bet = raised!
            if (bet == false) {
                raised = raised! + temp
            }
            
            if (raised! > self.curr_state.funds_players[self.curr_state.curr_player_ind]){
                let alert_no_funds = UIAlertController(title:  "Not enough funds!" , message: "", preferredStyle: .alert)
                let try_again_action = UIAlertAction(title: "Try again", style: .cancel, handler: { alt -> Void in
                    self.bet_pop_up(bet: bet)
                })
                alert_no_funds.addAction(try_again_action)
                //self.present(alert_no_funds, animated: true, completion: nil)
                self.curr_state.prev_bet = temp
                return
            }
            
            self.curr_state.money_in_pot += raised!
            self.potLabel = "Pot: $" + String(self.curr_state.money_in_pot)
            
            self.curr_state.funds_players[self.curr_state.curr_player_ind] -= raised!
            
            
            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += raised!
            self.handleBoard()
            //self.nextPlayer()
            print(raised!)
            
        })
        
        alert.addAction(cancelAction)
        alert.addAction(betAction)
        
        //self.present(alert, animated: true, completion: nil)
        
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
    
    func callFold() {
        curr_state.players_round[curr_state.curr_player_ind] = false
        handleBoard()
    }
    
    func callRaise() {
        bet_pop_up(bet: false)
        
    }
    
    func callCheck() {
        let amount = self.curr_state.prev_bet
        curr_state.money_in_pot += amount
        potLabel = "Pot: $" + String(curr_state.money_in_pot)
        if (self.curr_state.players_round_bet[self.curr_state.curr_player_ind] == -1 ){
            self.curr_state.players_round_bet[self.curr_state.curr_player_ind] = 0
        }
        curr_state.funds_players[curr_state.curr_player_ind] -= amount
        self.curr_state.players_round_bet[self.curr_state.curr_player_ind] += amount
        handleBoard()
    }
    
    
    func callBet() {
        bet_pop_up(bet: true)
    }
    
    
    func getImages(for cards: [Card]) -> [String] {
        var imgs = [String]()
        for card in cards {
            //let name = card.fileName
            /*guard let img = UIImage(named: name) else {
             return nil
             }*/
            imgs.append(card.fileName)
        }
        return imgs
    }
    
    func showTableCards(){
        
        let small_blind_name = curr_state.players[curr_state.small_blind_ind].name
        let big_blind_name = curr_state.players[curr_state.big_blind_ind].name
        let dealer_name = curr_state.players[curr_state.dealer_ind].name
        gameStat = "Big Blind: " + big_blind_name! +
        "\nSmall Blind: " + small_blind_name! + "\nDealer: " + dealer_name!
        
        if(curr_state.flop_done == false){
            flop1 = "back_w"
            flop2 = "back_w"
            flop3 = "back_w"
            flop4 = "back_w"
            flop5 = "back_w"
        }
        let flop_cards = getImages(for: curr_state.dealer.table.dealtCards)
        if(curr_state.flop_done == true){
            flop1 = flop_cards[0]
            flop2 = flop_cards[1]
            flop3 = flop_cards[2]
        }
        if(curr_state.turn_done == true){
            flop4 = flop_cards[3]
        }
        if(curr_state.river_done == true){
            flop5 = flop_cards[4]
        }
        for i in 0...(curr_state.players.count-1){
            if (curr_state.players_round[i] == false){
                if(i == 0){
                    p1card1 = "back_w"
                    p1card2 = "back_w"
                    player1Label = curr_state.players[i].name! + "(Folded)"
                    //player1Label.textColor = .white
                }
                if(i == 1){
                    p2card1 = "back_w"
                    p2card2 = "back_w"
                    player2Label = curr_state.players[i].name! + "(Folded)"
                    //player2Label.textColor = .white
                }
                if (i == 2){
                    p3card1 = "back_w"
                    p3card2 = "back_w"
                    player3Label = curr_state.players[i].name! + "(Folded)"
                    //player3Label.textColor = .white
                }
            }
            else{
                if(i == 0){
                    player1Label = curr_state.players[i].name!
                }
                if(i == 1){
                    player2Label = curr_state.players[i].name!
                }
                if (i == 2){
                    player3Label = curr_state.players[i].name!
                }
            }
        }
    }
}

