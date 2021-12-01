import Foundation

public class Table: NSObject, NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(dealtCards, forKey: "dealtCards")
        coder.encode(burnt, forKey: "burnt")
    }
    
    override init(){}
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        dealtCards = coder.decodeObject(forKey: "dealtCards") as! [Card]
        burnt = coder.decodeObject(forKey: "burnt") as! [Card]
    }
    

    var dealtCards = [Card]()

    var burnt = [Card]()

    var currentGame: String {
        return dealtCards.spacedDescriptions
    }

    var flop: String {
        guard dealtCards.count > 2 else { return "" }
        return dealtCards[0...2].spacedDescriptions
    }

    var turn: String {
        guard dealtCards.count > 3 else { return "" }
        return dealtCards[3].card_description
    }

    var river: String {
        guard dealtCards.count > 4 else { return "" }
        return dealtCards[4].card_description
    }

    func add(cards: [Card]) {
        dealtCards += cards
    }

    func addToBurnt(card: Card) {
        burnt.append(card)
    }

}

