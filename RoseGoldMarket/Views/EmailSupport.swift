//
//  EmailSupport.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 3/2/22.
//

import SwiftUI
import MessageUI

struct EmailSupport: View {
    @EnvironmentObject var user: UserModel
    @StateObject var viewModel: EmailSupportViewModel = EmailSupportViewModel()
    @FocusState var subjectFocus:Bool?
    @FocusState var descriptionFocus:Bool?
    @State var showEmail = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    let buttonWidth = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        VStack(alignment: .center) {
            //            if viewModel.emailSent == false {
            //                Text("Send Us A Message:").font(.custom("MontserratAlternates-ExtraBold", size: 20)).frame(maxWidth: .infinity)
            //                TextField("Subject:", text: $viewModel.subjectLine)
            //                    .focused($subjectFocus, equals: true)
            //                    .padding()
            //                    .toolbar {
            //                        ToolbarItem(placement: .keyboard) {
            //                            Button("Done") {
            //                                subjectFocus = nil
            //                                descriptionFocus = nil
            //                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
            //                        }
            //                    }
            //                    .modifier(
            //                        CustomTextBubble(isActive: subjectFocus == true, accentColor: .blue)
            //                    )
            //                    .padding()
            //                    .onSubmit {
            //                        subjectFocus = false
            //                        descriptionFocus = true
            //                    }
            //                    .alert(isPresented: $viewModel.invalidText) {
            //                        return Alert(title: Text("Check Subject and Email"), message: Text("Make sure your subject line and message contains text"), dismissButton: .default(Text("OK")))
            //                    }
            //
            //                TextField("Message:", text: $viewModel.message, axis: .vertical)
            //                    .focused($descriptionFocus, equals: true)
            //                    .padding()
            //                    .modifier(CustomTextBubble(isActive: descriptionFocus == true, accentColor: .blue))
            //                    .padding()
            //
            //                Button(
            //                    action: {
            //                        guard !viewModel.subjectLine.isEmpty else {
            //                            subjectFocus = true
            //                            return
            //                        }
            //                        viewModel.sendEmail(user: user)
            //                    },
            //                    label: {
            //                        Text("Send")
            //                            .foregroundColor(.white)
            //                            .frame(width: buttonWidth)
            //                            .font(.system(size: 16, weight: Font.Weight.bold))
            //                            .padding()
            //                            .background(RoundedRectangle(cornerRadius: 25).fill(.blue).frame(width: buttonWidth))
            //                            .padding(.top)
            //                    }
            //                )
            //                Spacer()
            //            } else {
            //                Text(viewModel.deliveryHeading).font(.custom("MontserratAlternates-ExtraBold", size: 28))
            //                Text(viewModel.deliveryMessage).font(.custom("MontserratAlternates-Regular", size: 20))
            //            }
          
            
            if result != nil {
                Text("Result: \(String(describing: result))")
                    .lineLimit(nil)
            }
        }.onAppear() {
            
        }
    }
}

struct EmailSupport_Previews: PreviewProvider {
    static var previews: some View {
        EmailSupport().environmentObject(UserModel.shared)
    }
}
