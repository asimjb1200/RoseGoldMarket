//
//  MessageErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/6/22.
//

import Foundation

enum MessageErrors: String, Error {
    case serverError = "500 error on the server"
    case decodingError = "could not properly decode the objects"
    case genError = "there was a problem I don't understand"
    case responseDecodingError = "the response was not of the expected type"
    case tokenExpired = "The access token has expired. Time to issue a new one"
}
