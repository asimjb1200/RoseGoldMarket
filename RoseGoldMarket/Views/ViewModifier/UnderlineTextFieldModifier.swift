//
//  UnderlineTextFieldModifier.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 6/19/22.
//

import SwiftUI

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.black)
            .padding(10)
    }
}
