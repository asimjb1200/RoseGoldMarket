//
//  CustomTextBubble.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 10/15/22.
//

import Foundation
import SwiftUI

struct CustomTextBubble:ViewModifier {
    var isActive: Bool
    //var textField: Binding<String>
    var accentColor: Color
    
    public func body(content: Content) -> some View {
        content.background(RoundedRectangle(cornerRadius: 30).stroke(isActive ? accentColor : Color.gray, lineWidth: isActive ? 3 : 1)).background(RoundedRectangle(cornerRadius: 30).fill(Color(.systemGray6)))
    }
}
