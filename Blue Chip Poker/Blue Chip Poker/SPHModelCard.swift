import Foundation

public class Card: NSObject, NSCoding {
    public func encode(with coder: NSCoder) {
        coder.encode(suit, forKey: "suit")
        coder.encode(rank, forKey: "rank")
    }
    
    public required convenience init?(coder: NSCoder) {
        let suit = coder.decodeObject(forKey: "suit") as! String
        let rank = coder.decodeObject(forKey: "rank") as! String
        self.init(suit: suit, rank: rank)
    }
    

    let suit: String

    let rank: String

    let card_description: String

    init(suit: String, rank: String) {
        self.suit = suit
        self.rank = rank
        self.card_description = "\(rank)\(suit)"
    }

    var name: String {
        get {
            let s:String
            switch suit {
            case "♠", "Spades":
                s = "Spades"
            case "♣", "Clubs":
                s = "Clubs"
            case "♥", "Hearts":
                s = "Hearts"
            case "♦", "Diamonds":
                s = "Diamonds"
            default:
                s = ""
                print("Error")
            }
            let r:String
            switch rank {
            case "A", "Ace":
                r = "Ace"
            case "K", "King":
                r = "King"
            case "Q", "Queen":
                r = "Queen"
            case "J", "Jack":
                r = "Jack"
            case "T", "Ten":
                r = "10"
            default:
                r = rank
            }
            return "\(r) of \(s)"
        }
    }
    
    var fileName: String {
        let temp = name.replacingOccurrences(of: " ", with: "_").lowercased()
        return "\(temp)_w.png"
    }
    
}
