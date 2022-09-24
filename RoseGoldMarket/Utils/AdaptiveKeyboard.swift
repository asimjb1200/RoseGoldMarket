//
//  AdaptiveKeyboard.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 9/23/22.
//

import Foundation
import SwiftUI
import Combine
import UIKit

//struct KeyboardAdaptive: ViewModifier {
//    @State private var bottomPadding: CGFloat = 0
//
//    func body(content: Content) -> some View {
//        // 1.
//        GeometryReader { geometry in
//            content
//                .padding(.bottom, self.bottomPadding)
//                // 2.
//                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
//                    // 3.
//                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
//                    // 4.
//                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
//
//                    // 5.
//                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop * 2 - geometry.safeAreaInsets.bottom)
//            }
//            // 6.
//            .animation(.easeOut(duration: 0.16))
//        }.background(.green)
//    }
//}

//extension View {
//    func adaptiveKeyboard() -> some View {
//        ModifiedContent(content: self, modifier: KeyboardAdaptive())
//    }
//}

//extension UIResponder {
//    private static weak var _currentFirstResponder: UIResponder?
//
//    static var currentFirstResponder:UIResponder? {
//        _currentFirstResponder = nil
//        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
//
//        return _currentFirstResponder
//    }
//
//    @objc func findFirstResponder(_ sender: Any) {
//        UIResponder._currentFirstResponder = self
//    }
//
//    var globalFrame: CGRect? {
//        guard let view = self as? UIView else { return nil }
//        return view.superview?.convert(view.frame, to: nil)
//    }
//}
