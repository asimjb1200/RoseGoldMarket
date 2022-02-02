//
//  ItemPreview.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/28/22.
//

import SwiftUI

struct ItemPreview: View {
    let itemId: UInt
    let itemTitle: String
    let itemImageLink: String
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: itemImageLink))")) { phase in
                if let image = phase.image {
                    image.resizable().frame(maxWidth: 200, maxHeight: 200).cornerRadius(15)
                } else if phase.error != nil {
                    Color.red // an error occurred
                } else {
                    ProgressView()
                        .foregroundColor(Color("MainColor"))
                        .frame(width: 100, height: 100) // place holder for the image while it's loading
                }
            }
                
            Text("\(itemTitle)")
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(Color("AccentColor"))
                
        }
        .frame(maxWidth: 200, maxHeight: 200)
        .padding()
    }
}

extension ItemPreview {
    func getImageLink(imageLink: String) -> String {
        // chop up the image url
        let linkArray = imageLink.components(separatedBy: "/build")
        
        return linkArray[1].replacingOccurrences(of: " ", with: "%20")
    }
    
    
}

struct ItemPreview_Previews: PreviewProvider {
    static var previews: some View {
        ItemPreview(itemId: 5, itemTitle: "Item Title", itemImageLink: "/Users/asimbrown/Desktop/Dev/Projects/RoseGold/build/images/dee/Oak Tree/image2.jpg")
    }
}
