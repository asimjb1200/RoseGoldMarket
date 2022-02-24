//
//  IdentifiableView.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/23/22.
//

import Foundation
import SwiftUI

struct IdentifiableView: Identifiable {
    let view: AnyView
    let id = UUID()
}
