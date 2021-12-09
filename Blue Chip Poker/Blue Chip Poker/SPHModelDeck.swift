/***
 NOTE: THIS FILE HAS BEEN TAKEN FROM A THIRD-PARTY  LIBRARY : https://github.com/ericdke/PokerHands
 Here are the details of the original copyright:
 Created by Ivan Sanchez on 06/10/2014.
 Copyright (c) 2014 Gourame Limited. All rights reserved.
 ***/

import Foundation

public class Deck: NSObject, NSCoding, CanTakeCard, SPHCardsDebug {
    
    /// NOTE : This function has been added to the original file to make it compatible for encoding the object in the BlueChipPoker App
    /// Original file : https://github.com/ericdke/PokerHands
    public func encode(with coder: NSCoder) {
        coder.encode(cards, forKey: "cards")
        coder.encode(capacity, forKey: "capacity")
    }
    
    /// NOTE : This function has been added to the original file to make it compatible for decoding the object in the BlueChipPoker App
    /// Original file : https://github.com/ericdke/PokerHands
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
