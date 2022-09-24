//
//  KeyboardNotificationPublisher.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/23/22.
//

import Foundation
import Combine
import UIKit

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // emit the keyboard's height once the keyboard will show notification comes
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification).map{ $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification).map { _ in CGFloat(0)}
        
        return MergeMany(willShow, willHide).eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
