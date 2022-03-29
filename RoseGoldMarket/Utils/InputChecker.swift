//
//  InputChecker.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/28/22.
//

import Foundation

struct InputChecker {
    static let shared = InputChecker()
    private var badWords:[String]?
    
    private init() {
        loadBadWords()
    }
    
    func isValidTitle(title:String) -> Bool {
        return true
    }
    
    func isValidText(message:String) -> Bool {
        return true
    }
    
    func containsProfanity(message:String) -> Bool {
        var badWordFound = false
        let wordsInMsg = message.components(separatedBy: " ")
        while badWordFound == false {
            for word in wordsInMsg {
                if badWords!.contains(word.lowercased()) {
                    badWordFound = true
                }
            }
        }
        return badWordFound
    }
    
    func isOver200Chars(message:String) -> Bool {
        return true
    }
    
    mutating func loadBadWords() {
        if let fileURL = Bundle.main.path(forResource: "badwords", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: fileURL)
                if badWords == nil {
                    badWords = contents.components(separatedBy: "\n")
                }
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
}
