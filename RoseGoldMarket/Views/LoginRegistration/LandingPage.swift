//
//  LandingPage.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/10/23.
//

import SwiftUI

struct LandingPage: View {
    //@Binding var appViewState: AppViewStates
    @EnvironmentObject var appViewState: CurrentAppView
    @EnvironmentObject private var subHandler: SubscriptionHandler
    var buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "LandingPage")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea([.top, .bottom])
            
            VStack {
                if subHandler.subPurchaseLoading {
                    ProgressView()
                } else {
                    if !subHandler.isSubscribed && subHandler.firstMonthOver() {
                        Menu {
                            ForEach(subHandler.products) {(product) in
                                Button {
                                    Task {
                                        do {
                                            try await subHandler.purchase(product)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    Text("\(product.displayPrice) - \(product.displayName)")
                                }
                            }
                        } label: {
                            Text("Subscription Options")
                                .fontWeight(.bold)
                                .frame(width: buttonWidth)
                                .foregroundColor(.white)
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth, height: 50))
                                .padding()
                        }
                    }
                    
                    Button(
                        action: {
                            withAnimation {
                                appViewState.currentView = .LoginView
                            }
                        },
                        label: {
                        Text("Log In")
                            .fontWeight(.bold)
                            .frame(width: buttonWidth)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: buttonWidth, height: 50))
                            .padding()
                            
                    }).offset(y: 160)
                    
                    Button(
                        action: {
                            withAnimation {
                                appViewState.currentView = .RegistrationView
                            }
                        },
                        label: {
                            Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(width: buttonWidth)
                            .foregroundColor(.black)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white).frame(width: buttonWidth, height: 50))
                            .padding()
                        }
                    )
                    .offset(y: 160)
                }
            }
        }.task {
            do {
                try await subHandler.fetchSubscriptions()
                await subHandler.checkSubscriptionStatus()
            } catch {
                print(error)
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage().environmentObject(CurrentAppView()).environmentObject(SubscriptionHandler())
    }
}
