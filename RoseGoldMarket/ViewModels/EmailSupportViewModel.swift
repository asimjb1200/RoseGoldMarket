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
    
    func sendEmail(user: UserModel) {
        userService.emailSupport(subject: self.subjectLine, message: self.message, token: user.accessToken, completion: {[weak self] (emailSentResponse) in
            switch (emailSentResponse) {
                case .success(_):
                    DispatchQueue.main.async {
                        self?.deliveryHeading = "Your Email Was Delivered"
                        self?.deliveryMessage = "We will be in touch within 2-3 business days."
                        self?.emailSent = true
                    }
                case .failure(let err):
                    if err == .tokenExpired {
                        DispatchQueue.main.async {
                            user.logout()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.deliveryHeading = "There Was A Problem"
                            self?.deliveryMessage = "Your message couldn't be delivered. Try again later."
                            self?.emailSent = true
                        }
                    }
            }
        })
    }
    
    deinit {
        print("[x] destroyed")
    }
}
