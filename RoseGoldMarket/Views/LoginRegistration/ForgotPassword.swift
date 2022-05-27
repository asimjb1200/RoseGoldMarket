//
//  ForgotPassword.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 5/26/22.
//

import SwiftUI

struct ForgotPassword: View {
    @State var username:String = ""
    @State var email:String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            
            Text("- OR -")
            
            TextField("Email", text: $email)
        }
    }
}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword()
    }
}
