//
//  RegistrationFormEnum.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/22/22.
//

import Foundation
import SwiftUI

enum FormFields: Int, CaseIterable {
    case fullName, firstName, lastName, username, phone, address, password, passwordPlain, confirmPassword, confirmPasswordPlain, email, city, zipcode, state
}
