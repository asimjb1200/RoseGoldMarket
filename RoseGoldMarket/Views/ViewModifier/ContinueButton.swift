//
//  ContinueButton.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/24/22.
//

import Foundation
import SwiftUI

struct ContinueButtonStyling:ViewModifier {

    public func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: 190)
            .font(.system(size: 16, weight: Font.Weight.bold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue))
    }
    
}
