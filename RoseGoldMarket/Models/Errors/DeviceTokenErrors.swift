//
//  DeviceTokenErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/3/23.
//

import Foundation

enum DeviceTokenErrors: String, Error {
    case expiredToken = "The access token attempted was expired"
    case serverError = "There was a problem on the server"
    case success = "OK"
    case responseConversionError = "couldn't convert the response to http"
    case badURL = "couldnt load URL"
}
