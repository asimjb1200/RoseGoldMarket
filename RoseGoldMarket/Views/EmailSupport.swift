//
//  EmailSupport.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI

struct EmailSupport: View {
    @StateObject var viewModel: EmailSupportViewModel = EmailSupportViewModel()
    @FocusState var subjectFocus:Bool
    @FocusState var descriptionFocus:Bool
    var body: some View {
        VStack(alignment: .center) {
            if viewModel.emailSent == false {
                Text("Send Us A Message:").font(.custom("MontserratAlternates-ExtraBold", size: 20)).frame(maxWidth: .infinity)
                TextField("Subject:", text: $viewModel.subjectLine)
                    .focused($subjectFocus)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            Button("Done") {
                                subjectFocus = false
                                descriptionFocus = false
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                        }
                    }
                    .modifier(
                        CustomTextBubble(isActive: subjectFocus == true, accentColor: .blue)
                    )
                    .padding()
                    .onSubmit {
                        subjectFocus = false
                        descriptionFocus = true
                    }
                    .alert(isPresented: $viewModel.invalidText) {
                        return Alert(title: Text("Check Subject and Email"), message: Text("Make sure your subject line and message contains text"), dismissButton: .default(Text("OK")))
                    }

                TextField("Message:", text: $viewModel.message, axis: .vertical)
                    .focused($descriptionFocus)
                    .padding()
                    .modifier(CustomTextBubble(isActive: descriptionFocus == true, accentColor: .blue))
                    .padding()

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
                Spacer()
            } else {
                Text(viewModel.deliveryHeading).font(.custom("MontserratAlternates-ExtraBold", size: 28))
                Text(viewModel.deliveryMessage).font(.custom("MontserratAlternates-Regular", size: 20))
            }
        }
    }
}

struct EmailSupport_Previews: PreviewProvider {
    static var previews: some View {
        EmailSupport()
    }
}
