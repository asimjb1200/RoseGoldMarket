//
//  ManageSubscriptions.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/9/23.
//

import SwiftUI

//struct ManageSubscriptions: View {
//    @EnvironmentObject var subHandler: SubscriptionHandler
//    var buttonWidth = UIScreen.main.bounds.width * 0.85
//
//    var body: some View {
//        VStack {
//            if subHandler.firstMonthOver() && !subHandler.isSubscribed {
//                Text("In order to use this application, you'll need to select one of our subscription options if you haven't already").padding()
//            } else if !subHandler.firstMonthOver() && !subHandler.isSubscribed  {
//                Text("After the first 30 days, you'll have to sign up for one of our subscription options below in order to continue using the app's services.").padding()
//            }
//            if subHandler.subPurchaseLoading {
//                ProgressView()
//            } else {
//                if subHandler.isSubscribed {
//                    Text("You're already subscribed.")
//                }
//
//                ForEach(subHandler.products) {(product) in
//                    Button {
//                        Task {
//                            do {
//                                try await subHandler.purchase(product)
//                            } catch {
//                                print(error)
//                            }
//                        }
//                    } label: {
//                        Text("\(product.displayPrice) - \(product.displayName)")
//                            .fontWeight(.bold)
//                            .frame(width: buttonWidth)
//                            .foregroundColor(.white)
//                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth, height: 50))
//                            .padding()
//                    }
//                }
//            }
//        }
//        .onAppear() {
//            if subHandler.products.isEmpty {
//                Task {
//                    do {
//                        try await subHandler.fetchSubscriptions()
//                    } catch {
//                        print(error)
//                    }
//
//                }
//            }
//        }
//    }
//}
//
//struct ManageSubscriptions_Previews: PreviewProvider {
//    static var previews: some View {
//        ManageSubscriptions().environmentObject(SubscriptionHandler())
//    }
//}
