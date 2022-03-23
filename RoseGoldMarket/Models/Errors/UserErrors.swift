//
//  UserErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/16/22.
//

import Foundation

enum UserErrors: String, Error {
    case success = "Successfully logged in user"
    case failure = "Not able to log user in"
    case badCreds = "Credentials weren't accepted by the server"
    case tokenExpired = "The access token has expired. Time to issue a new one"
}
