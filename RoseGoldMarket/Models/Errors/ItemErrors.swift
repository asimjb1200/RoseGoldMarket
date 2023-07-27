//
//  ItemErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 7/20/23.
//

import Foundation

enum ItemErrors: String, Error {
    case genError = "error occurred"
    case urlError = "couldnt get url"
    case tokenExpired = "The access token has expired. Time to issue a new one"
    case responseConversionError = "could not convert the response object to an HTTPResponse"
    case dataConversionError = "was not able to convert the data object to a known type"
    case badStatusCode = "the status code indicated that there was a big problem"
}
