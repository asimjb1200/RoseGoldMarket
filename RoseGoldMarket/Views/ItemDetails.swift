//
//  ItemDetails.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/29/22.
//

import SwiftUI

struct ItemDetails: View {
    let item: Item
    var body: some View {
        VStack{
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image1))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().resizable().frame(width: 370, height: 370).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }

                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image2))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().resizable().frame(width: 370, height: 370).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }

                    AsyncImage(url: URL(string: "http://localhost:4000\(self.getImageLink(imageLink: item.image3))")) { imagePhase in
                        if let image = imagePhase.image {
                            image.resizable().resizable().frame(width: 370, height: 370).cornerRadius(25)
                        } else if imagePhase.error != nil {
                            Text("Problem loading image")
                        } else {
                            ProgressView()
                        }
                    }
                }.frame(height: 400)
                
            }
            
            Text("Date Posted: \(self.formatDate(date: item.dateposted))").font(.footnote).fontWeight(.medium).foregroundColor(Color("AccentColor")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
            Text(item.name)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(Color("MainColor"))
                .padding(.bottom)
            
            Text(item.description)
            Spacer()
            Button("Contact Owner") {
                
            }.padding(.bottom)
        }
    }
}

extension ItemDetails {
    func getImageLink(imageLink: String) -> String {
        // chop up the image url
        let linkArray = imageLink.components(separatedBy: "/build")
        
        return linkArray[1].replacingOccurrences(of: " ", with: "%20")
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct ItemDetails_Previews: PreviewProvider {
    static var previews: some View {
        let item = Item(id: 5, name: "Weed", description: "weed for you and me", owner: 6, isavailable: true, pickedup: false, dateposted: Date(), categories: ["indoor", "tropical"], image1: "/image1.jpg", image2: "/image2.jpg", image3: "/image3.jpg")
        ItemDetails(item: item)
    }
}
