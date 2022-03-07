//
//  ChangeAvatar.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//
import SwiftUI

struct ChangeAvatar: View {
    var username = "dee"
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "http://localhost:4000/images/avatars/\(username).png")) { phase in
                if let image = phase.image {
                    image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width:200, height:200)
                } else if phase.error != nil {
                    Color.red
                } else {
                    ProgressView().foregroundColor(Color("MainColor")).frame(width: 100, height: 100)
                }
            }
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ChangeAvatar_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAvatar()
    }
}
