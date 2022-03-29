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
    
    func containsSpecialChars(text:String) -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if text.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            return true
        } else {
            return false
        }
    }
    
    func containsProfanity(message:String) -> Bool {
        var badWordFound = false
        let wordsInMsg = message.components(separatedBy: " ")
        while badWordFound == false {
            for word in wordsInMsg {
                if badWords!.contains(word.lowercased()) {
                    badWordFound = true
                }
                // another loop to double check for squished words like this "hoebitch" lol...
                
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
