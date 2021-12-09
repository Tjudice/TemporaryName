/***
 NOTE: THIS FILE HAS BEEN TAKEN FROM A THIRD-PARTY  LIBRARY : https://github.com/ericdke/PokerHands
 Here are the details of the original copyright:
 Created by Ivan Sanchez on 06/10/2014.
 Copyright (c) 2014 Gourame Limited. All rights reserved.
 ***/

import Foundation

public class Player: NSObject, NSCoding, CanTakeCard {
    
    /// NOTE : This function has been added to the original file to make it compatible for encoding the object in the BlueChipPoker App
    /// Original file : https://github.com/ericdke/PokerHands
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(frequentHands, forKey: "frequentHands")
        coder.encode(cards, forKey: "cards")
    }
    
    /// NOTE : This function has been added to the original file to make it compatible for decoding the object in the BlueChipPoker App
    /// Original file : https://github.com/ericdke/PokerHands
    public required convenience init?(coder: NSCoder) {
        let name = coder.decodeObject(forKey: "name") as! String
        self.init(name: name)
        frequentHands = coder.decodeObject(forKey: "frequentHands") as! [String:Int]
        cards = coder.decodeObject(forKey: "cards") as! [Card]
    }
    

    override init() {}

    init(name: String) {
        self.name = name
    }

    var name: String?

    var historyOfDealtCards = [(Card, Card, Date)]()
    
    var frequentHands = [String:Int]()

    var hand: (HandRank, [String])?
    
    var handDescription: String? {
        return hand?.1.joined(separator: " ")
    }
    
    var handNameDescription: String? {
        return hand?.0.name.rawValue.lowercased()
    }

    var cardsHistory: String {
        let mapped = historyOfDealtCards.map { $0.0.card_description + " " + $0.1.card_description }
        return mapped.joined(separator: ", ")
    }

    public var cards = [Card]() {
        didSet {
            let tu = (cards[0], cards[1], Date())
            historyOfDealtCards.append(tu)
            let fqname = "\(tu.0.card_description),\(tu.1.card_description)"
            if frequentHands[fqname] == nil {
                frequentHands[fqname] = 1
            } else {
                frequentHands[fqname]! += 1
            }
        }
    }

    var cardsNames: String {
        return cards.joinNames(with: ", ")
    }

    var count: Int {
        return cards.count
    }

    var holeCards: String {
        return cards.spacedDescriptions
    }
    
    var lastDealtHandReadableDate: String? {
        guard let date = historyOfDealtCards.last?.2 else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
        return formatter.string(from: date)
    }
    
    var lastDealtHandDate: Date? {
        return historyOfDealtCards.last?.2
    }
}
