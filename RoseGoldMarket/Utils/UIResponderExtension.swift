//
//  AdaptiveKeyboard.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/23/22.
//

import Foundation
import SwiftUI

extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder:UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)

        return _currentFirstResponder
    }

    @objc func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}
