//  Created by Ivan Sanchez on 06/10/2014.
//  Copyright (c) 2014 Gourame Limited. All rights reserved.
//
//  Modified for SwiftyPokerHands to take values from JSON files instead of huge array literals.

import Foundation

final public class ByteRanks {
    
    enum SPHError: String, Error {
        case CouldNotFindJSONFile = "FATAL ERROR: Could not find init files in app bundle"
        case CouldNotLoadJSONFile = "FATAL ERROR: Could not load init files from app bundle"
        case CouldNotConvertJSONFile = "FATAL ERROR: Could not read init files from app bundle"
    }
    
    static let sharedInstance = ByteRanks()
    
    let flushes: [Int]
    let uniqueToRanks: [Int]
    let primeProductToCombination: [Int]
    let combinationToRank: [Int]
    
    public init() {
        do {
            let bundle = Bundle.main
            guard let fpath = bundle.path(forResource: "flushes_bytes", ofType: "json"),
                let upath = bundle.path(forResource: "uniqueToRanks_bytes", ofType: "json"),
                let ppath = bundle.path(forResource: "primeProductToCombination_bytes", ofType: "json"),
                let cpath = bundle.path(forResource: "combinationToRank_bytes", ofType: "json") else {
                    throw SPHError.CouldNotFindJSONFile
            }
            guard let fdata = try? Data(contentsOf: URL(fileURLWithPath: fpath)),
                let udata = try? Data(contentsOf: URL(fileURLWithPath: upath)),
                let pdata = try? Data(contentsOf: URL(fileURLWithPath: ppath)),
                let cdata = try? Data(contentsOf: URL(fileURLWithPath: cpath)) else {
                    throw SPHError.CouldNotLoadJSONFile
            }
            guard let ujson = try JSONSerialization.jsonObject(with: udata, options: []) as? [Int],
                let fjson = try JSONSerialization.jsonObject(with: fdata, options: []) as? [Int],
                let pjson = try JSONSerialization.jsonObject(with: pdata, options: []) as? [Int],
                let cjson = try JSONSerialization.jsonObject(with: cdata, options: []) as? [Int] else {
                    throw SPHError.CouldNotConvertJSONFile
            }
            self.flushes = fjson
            self.uniqueToRanks = ujson
            self.primeProductToCombination = pjson
            self.combinationToRank = cjson
        } catch let error as SPHError {
            print(error)
            fatalError()
        } catch let error as NSError {
            print(error.debugDescription)
            fatalError()
        }
    }
    
    
}
