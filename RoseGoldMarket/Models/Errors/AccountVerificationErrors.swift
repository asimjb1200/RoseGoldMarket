//
//  AccountVerificationErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 10/24/22.
//

import Foundation

enum AccountVerificationErrors: String, Error {
    case success = "user has been verified. they can now log in"
    case failure = "something unexpected happened"
    case responseConversionError = "Couldn't convert the response to HTTP"
    case unknownError = "received an error code I didn't expect"
    case wrongCode = "the user did not provide the right code"
    case serverSideError = "there was an error on the server"
    case userNotFound = "That user couldn't be found in our records"
}
