import Foundation

public class Dealer: NSObject, NSCoding, SPHCardsDebug {
    public func encode(with coder: NSCoder) {
        coder.encode(currentDeck, forKey: "currentDeck")
        coder.encode(table, forKey: "table")
        coder.encode(scores, forKey: "scores")
        coder.encode(currentHandWinner, forKey: "currentHandWinner")
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        self.currentDeck = coder.decodeObject(forKey: "currentDeck") as! Deck
        self.table = coder.decodeObject(forKey: "table") as! Table
        self.scores = coder.decodeObject(forKey: "scores") as! [String:Int]
        self.currentHandWinner = coder.decodeObject(forKey: "currentHandWinner") as? Player
    }
    

    var evaluator: Evaluator

    var currentDeck: Deck

    var table: Table

    var verbose = false

    override init() {
        currentDeck = Deck()
        table = Table()
        evaluator = Evaluator()
    }
    
    init(deck: Deck) {
        currentDeck = deck
        table = Table()
        evaluator = Evaluator()
    }
    
    init(evaluator: Evaluator) {
        currentDeck = Deck()
        table = Table()
        self.evaluator = evaluator
    }
    
    init(deck: Deck, evaluator: Evaluator) {
        currentDeck = deck
        table = Table()
        self.evaluator = evaluator
    }

    var currentGame: String { return table.currentGame }

    var flop: String { return table.flop }

    var turn: String { return table.turn }

    var river: String { return table.river }

    var currentHandWinner: Player? {
        didSet {
            if currentHandWinner != nil {
                if scores[currentHandWinner!.name!] == nil {
                    scores[currentHandWinner!.name!] = 1
                } else {
                    scores[currentHandWinner!.name!]! += 1
                }
            } else {
                scores = [:]
            }
        }
    }

    var scores = [String:Int]()

    func changeDeck() {
        currentDeck = Deck()
    }

    func shuffleDeck() {
        currentDeck.shuffle()
    }
    
    func removeCards(from player: inout Player) {
        player.cards = []
    }

    func deal(number: Int) -> [Card] {
        return currentDeck.takeCards(number: number)
    }

    func dealHand() -> [Card] {
        return deal(number: 2)
    }

    func dealHand(to player: inout Player) {
        player.cards = dealHand()
    }
    
    func deal(cards: [String]) -> [Card] {
        let upCardChars = cards.map({$0.uppercased().map({String($0)})})
        var cardsToDeal = [Card]()
        for cardChars in upCardChars {
            let cardObj = Card(suit: cardChars[1], rank: cardChars[0])
            guard let index = currentDeck.cards.index(of: cardObj) else {
                break
            }
            currentDeck.cards.remove(at: index)
            cardsToDeal.append(cardObj)
        }
        return cardsToDeal
    }
    
    func deal(cards: [String], to player: inout Player) {
        player.cards = deal(cards: cards)
    }
    
    func deal(cards: [Card], to player: inout Player) {
        var cardsToDeal = [Card]()
        for card in cards {
            guard let indexToRemove = currentDeck.cards.index(of: card) else {
                break
            }
            currentDeck.cards.remove(at: indexToRemove)
            cardsToDeal.append(card)
        }
        player.cards = cardsToDeal
    }

    @discardableResult func dealFlop() -> [Card] {
        table.dealtCards = []
        table.burnt = []
        let dealt = dealWithBurning(number: 3)
        table.add(cards: dealt)
        return dealt
    }

    @discardableResult func dealTurn() -> [Card] {
        let dealt = dealWithBurning(number: 1)
        table.add(cards: dealt)
        return dealt
    }

    @discardableResult func dealRiver() -> [Card] {
        return dealTurn()
    }

    private func burn() -> Card? {
        return currentDeck.takeOneCard()
    }

    private func dealWithBurning(number: Int) -> [Card] {
        guard let burned = burn() else {
            return errorNotEnoughCards()
        }
        table.addToBurnt(card: burned)
        return deal(number: number)
    }

    func evaluateHandAtRiver(for player: inout Player) {
        player.hand = evaluateHandAtRiver(player: player)
    }

    func evaluateHandAtRiver(player: Player) -> (HandRank, [String]) {
        let sevenCards = table.dealtCards + player.cards
        let cardsReps = sevenCards.map({ $0.card_description })
        // all 5 cards combinations from the 7 cards
        let perms = cardsReps.permutation(5)
        // TODO: do the permutations with rank/else instead of literal cards descriptions
        let sortedPerms = perms.map({ $0.sorted(by: <) })
        //let permsSet = NSSet(array: sortedPerms)
        let uniqs = Array(sortedPerms).map({ $0 as! [String] })
        var handsResult = [(HandRank, [String])]()
        for hand in uniqs {
            let h = evaluator.evaluate(cards: hand)
            handsResult.append(
                (h, hand)
            )
        }
        handsResult.sort(by: { $0.0 < $1.0 })
        let bestHand = handsResult.first
        return bestHand!
    }

    func updateHeadsUpWinner(player1: Player, player2: Player) {
        currentHandWinner = findHeadsUpWinner(player1: player1, player2: player2)
    }

    func findHeadsUpWinner(player1: Player, player2: Player) -> Player {
        if player1.hand!.0 < player2.hand!.0 {
            return player1 }
        else if player1.hand!.0 == player2.hand!.0 {
            return Player(name: "SPLIT") }
        else {
            return player2
        }
    }
}
