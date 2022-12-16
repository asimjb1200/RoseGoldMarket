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
    @FocusState var focusedField:SecurityCodeFields?
    var boxNum: SecurityCodeFields
    public func body(content: Content) -> some View {
        content
            .focused($focusedField, equals: boxNum)
            .font(Font.system(size: 40, design: .default))
            .autocapitalization(.none)
            .frame(width: 50, height: 80)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray))
            .onChange(of: textCode) {
                textCode = String($0.prefix(1))
                focusedField = findBoxNum()
            }
    }
    
    func findBoxNum() -> SecurityCodeFields {
        switch boxNum {
            case .first:
                return .second
            case .second:
                return .third
            case .third:
                return .fourth
            case .fourth:
                return .fifth
            case .fifth:
                return .sixth
            case .sixth:
                return .sixth
        }
    }
}
