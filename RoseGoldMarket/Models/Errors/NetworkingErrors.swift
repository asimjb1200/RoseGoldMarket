//
//  NetworkingErrors.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/14/23.
//

import Foundation

enum NetworkingErrors: String, Error {
    case responseConversionError = "unable to cast the response to HTTPURLResponse"
    case problemStatusCode = "We didn't get back the expected 2-- status code"
}
