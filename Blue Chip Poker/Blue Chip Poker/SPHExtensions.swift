/***
 NOTE: THIS FILE HAS BEEN TAKEN FROM A THIRD-PARTY  LIBRARY : https://github.com/ericdke/PokerHands
 Here are the details of the original copyright:
 Created by Ivan Sanchez on 06/10/2014.
 Copyright (c) 2014 Gourame Limited. All rights reserved.
 ***/

import Foundation

public func ==(lhs: Card, rhs: Card) -> Bool {
    if lhs.rank == rhs.rank && lhs.suit == rhs.suit {
        return true
    }
    return false
}

public protocol CanTakeCard {
    
    var cards: [Card] { get set }
    mutating func takeOneCard() -> Card?
    
}

public extension CanTakeCard {
    
    mutating func takeOneCard() -> Card? {
        guard cards.count > 0 else { return nil }
        return cards.takeOne()
    }
    
}

public protocol SPHCardsDebug {
    
    func errorNotEnoughCards() -> [Card]
    func error(_ message: String)
    
}

public extension SPHCardsDebug {
    
    func errorNotEnoughCards() -> [Card] {
        error("not enough cards")
        return []
    }
    
    func error(_ message: String) {
        print("ERROR: \(message)")
    }
    
}

public extension Sequence where Iterator.Element == Card {
    
    var descriptions: [String] {
        return self.map { $0.card_description }
    }
    
    var spacedDescriptions: String {
        return self.descriptions.joined(separator: " ")
    }
    
    func index(of card: Card) -> Int? {
        for (index, deckCard) in self.enumerated() {
            if deckCard == card {
                return index
            }
        }
        return nil
    }
    
    func joinNames(with string: String) -> String {
        return self.map({ $0.name }).joined(separator: string)
    }
    
}

public extension CountableRange {
    
    var array: [Element] {
        return self.map { $0 }
    }
    
}

public extension Array {
    
    mutating func takeOne() -> Element {
        let index:Int
        #if os(Linux)
            // TODO: find a better way
            index = getPseudoRandomNumber(self.count)
        #else
            index = Int(arc4random_uniform(UInt32(self.count)))
        #endif
        let item = self[index]
        self.remove(at: index)
        return item
    }
    
    // adapted from ExSwift
    func permutation(_ length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        } else if length == 0 {
            return [[]]
        } else {
            var permutations: [[Element]] = []
            let combinations = combination(length)
            for combination in combinations {
                var endArray: [[Element]] = []
                var mutableCombination = combination
                permutations += self.permutationHelper(length, array: &mutableCombination, endArray: &endArray)
            }
            return permutations
        }
    }
    // adapted from ExSwift
    private func permutationHelper(_ n: Int, array: inout [Element], endArray: inout [[Element]]) -> [[Element]] {
        if n == 1 {
            endArray += [array]
        }
        for i in 0..<n {
            _ = permutationHelper(n - 1, array: &array, endArray: &endArray)
            let j = n % 2 == 0 ? i : 0;
            let temp: Element = array[j]
            array[j] = array[n - 1]
            array[n - 1] = temp
        }
        return endArray
    }
    // adapted from ExSwift
    func combination(_ length: Int) -> [[Element]] {
        if length < 0 || length > self.count {
            return []
        }
        var indexes: [Int] = (0..<length).array
        var combinations: [[Element]] = []
        let offset = self.count - indexes.count
        while true {
            var combination: [Element] = []
            for index in indexes {
                combination.append(self[index])
            }
            combinations.append(combination)
            var i = indexes.count - 1
            while i >= 0 && indexes[i] == i + offset {
                i -= 1
            }
            if i < 0 {
                break
            }
            i += 1
            let start = indexes[i-1] + 1
            for j in (i-1)..<indexes.count {
                indexes[j] = start + j - i + 1
            }
        }
        return combinations
    }
    
}
