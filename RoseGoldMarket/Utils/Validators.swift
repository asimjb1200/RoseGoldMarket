//
//  Validators.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/19/22.
//

import Foundation

struct Validators {
    private var badWords: [String]? // make sure to get this from the plist
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func pwContainsNumber(password: String) -> Bool {
        var numberFound = false
        for chr in password {
            if chr.isNumber {
                numberFound = true
                break
            }
        }
        return numberFound
    }

    static func pwContainsUppercase(password: String) -> Bool {
        var uppercaseFound = false
        for chr in password {
            if chr.isUppercase {
                uppercaseFound = true
                break
            }
        }
        return uppercaseFound
    }
    
    static func spacesFound(fieldsToCheck: [String]) -> Bool {
        for field in fieldsToCheck {
            guard field.contains(" ") == false else {
                return true
            }
        }
        return false
    }
    
    static func foundEmptyTextField(wordList: [String]) -> Bool {
        for field in wordList {
            guard !field.isEmpty else {
                return true
            }
        }
        return false
    }
}
