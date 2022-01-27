//
//  CategoryPicker.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/25/22.
//

import SwiftUI

struct CategoryPicker: View {
    @State private var doesClose = true
    var body: some View {
        Toggle("Outdoor", isOn: $doesClose)
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker()
    }
}
