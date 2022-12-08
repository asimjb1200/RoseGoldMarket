//
//  SecurityCodeTextBox.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/6/22.
//

import Foundation
import SwiftUI

struct SecurityCodeTextBox:ViewModifier {
    @Binding var textCode: String
    public func body(content: Content) -> some View {
        content
            .font(Font.system(size: 40, design: .default))
            .autocapitalization(.none)
            .frame(width: 50, height: 80)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray))
            .onChange(of: textCode) {
                textCode = String($0.prefix(1))
            }
    }
}
