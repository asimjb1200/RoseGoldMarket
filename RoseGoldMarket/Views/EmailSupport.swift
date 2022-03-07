//
//  EmailSupport.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI

struct EmailSupport: View {
    @StateObject var viewModel: EmailSupportViewModel = EmailSupportViewModel()
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.emailSent == false {
                Text("Send Us A Message:").font(.custom("MontserratAlternates-ExtraBold", size: 20)).frame(maxWidth: .infinity)
                TextField("Subject:", text: $viewModel.subjectLine)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763))
                    )
                    .padding()
                    .alert(isPresented: $viewModel.invalidText) {
                        return Alert(title: Text("Check Subject and Email"), message: Text("Make sure your subject line and message contains text"), dismissButton: .default(Text("OK")))
                    }

                TextEditor(text: $viewModel.message)
                    .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.694, opacity: 0.763))
                    .cornerRadius(25.0)
                    .padding()
                    .frame(height: 200, alignment: .center)

                Button("Send Email") {
                    guard
                        !viewModel.subjectLine.isEmpty,
                        !viewModel.message.isEmpty
                    else {
                        viewModel.invalidText.toggle()
                        return
                    }
//                    viewModel.sendEmail(user: user)
                }
                .foregroundColor(Color("Accent2"))
                
            } else {
                Text(viewModel.deliveryHeading).font(.custom("MontserratAlternates-ExtraBold", size: 28))
                Text(viewModel.deliveryMessage).font(.custom("MontserratAlternates-Regular", size: 20))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct EmailSupport_Previews: PreviewProvider {
    static var previews: some View {
        EmailSupport()
    }
}
