//
//  EmailSupportViewModel.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import Foundation
final class EmailSupportViewModel: ObservableObject {
    private var userService: UserNetworking = .shared
    var subjectLine = ""
    var message = ""
    @Published var invalidText: Bool = false
    @Published var emailSent: Bool = false
    @Published var deliveryMessage: String = ""
    @Published var deliveryHeading: String = ""
    
    deinit {
        print("[x] destroyed")
    }
}
