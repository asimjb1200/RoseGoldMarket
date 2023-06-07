//
//  PushNotifDeviceTokenPub.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/1/23.
//

import Foundation
import Combine

extension Notification.Name {
    // here I will create a custom notification that will represent an event that I define
    static let deviceTokenReceived = Notification.Name("device_token_received")
}

