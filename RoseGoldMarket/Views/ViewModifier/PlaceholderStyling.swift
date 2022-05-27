//
//  PlaceholderStyling.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/26/22.
//

import Foundation
import SwiftUI

struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeHolder: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeHolder).padding(.horizontal, 5).foregroundColor(Color.gray)
            }
            content
                .foregroundColor(.black)
            
        }
    }
}
