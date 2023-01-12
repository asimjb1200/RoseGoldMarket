//
//  LandingPage.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/10/23.
//

import SwiftUI

struct LandingPage: View {
    @Binding var appViewState: AppViewStates
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "LandingPage")!)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Button(
                    action: {
                        withAnimation {
                            appViewState = .LoginView
                        }
                    },
                    label: {
                    Text("Login")
                        .frame(width: 200)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.blue).frame(width: 200, height: 50))
                        .padding()
                        
                }).offset(y: 160)
                
                Button(
                    action: {
                        withAnimation {
                            appViewState = .RegistrationView
                        }
                    },
                    label: {
                        Text("Sign Up")
                        .frame(width: 200)
                        .foregroundColor(.black)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.white).frame(width: 200, height: 50))
                        .padding()
                    }
                )
                .offset(y: 160)
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage(appViewState: Binding.constant(.LandingPage))
    }
}
