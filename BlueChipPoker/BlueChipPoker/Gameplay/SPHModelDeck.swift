import Foundation

public class Deck: NSObject, NSCoding, CanTakeCard, SPHCardsDebug {
    public func encode(with coder: NSCoder) {
        coder.encode(cards, forKey: "cards")
        coder.encode(capacity, forKey: "capacity")
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        cards = coder.decodeObject(forKey: "cards") as! [Card]
        capacity = coder.decodeInteger(forKey: "capacity")
    }
    
    
    let suits = ["♠","♣","♥","♦"]
    let ranks = ["A","K","Q","J","T","9","8","7","6","5","4","3","2"]
    
    public var cards = [Card]()
    
    public var capacity = 52
    
    override init() {
        for thisSuit in suits {
            for thisRank in ranks {
                cards.append(
                    Card(suit: thisSuit, rank: thisRank)
                )
            }
        }
    }
    
    func shuffle() {
        cards.shuffle()
    }
    
    func takeCards(number: Int) -> [Card] {
        guard self.count >= number else {
            return errorNotEnoughCards()
        }
        var c = [Card]()
        for _ in 1...number {
            c.append(self.cards.takeOne())
        }
        return c
    }
    
    var count: Int {
        return cards.count
    }
    
    var dealt: Int {
        return capacity - cards.count
    }
}
