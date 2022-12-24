//
//  Validators.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/19/22.
//

import Foundation

struct Validators {
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
}
