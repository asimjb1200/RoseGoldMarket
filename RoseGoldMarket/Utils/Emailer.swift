//
//  Emailer.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 2/28/23.
//

import SwiftUI
import UIKit
import MessageUI

//struct MailView: UIViewControllerRepresentable {
//    @Binding var isShowing: Bool
//    @Binding var result: Result<MFMailComposeResult, Error>?
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//
//        @Binding var isShowing: Bool
//        @Binding var result: Result<MFMailComposeResult, Error>?
//
//        init(isShowing: Binding<Bool>,
//             result: Binding<Result<MFMailComposeResult, Error>?>) {
//            _isShowing = isShowing
//            _result = result
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//            defer {
//                isShowing = false
//            }
//            guard error == nil else {
//                self.result = .failure(error!)
//                return
//            }
//            self.result = .success(result)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(isShowing: $isShowing,
//                           result: $result)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.mailComposeDelegate = context.coordinator
//        vc.setToRecipients(["test@mail.com"])
//        vc.setMessageBody("this is a test email", isHTML: true)
//        vc.setSubject("User Inquiry")
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
//                                context: UIViewControllerRepresentableContext<MailView>) {
//
//    }
//}

class EmailService: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailService()

    func sendEmail(subject:String, body:String, to:String, completion: @escaping (Bool) -> Void){
     if MFMailComposeViewController.canSendMail(){
        let picker = MFMailComposeViewController()
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
       UIApplication.shared.windows.first?.rootViewController?.present(picker,  animated: true, completion: nil)
    }
      completion(MFMailComposeViewController.canSendMail())
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
         }
}
