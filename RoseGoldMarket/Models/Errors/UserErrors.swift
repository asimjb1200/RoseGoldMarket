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
    case badPassword = "Bad password attempted"
    case badCreds = "Credentials weren't accepted by the server"
    case serverError = "There was a server side problem"
    case responseConversionError = "Couldn't convert the response to HTTP"
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case dataConversionError = "Couldn't decode the data object from the server"
}
