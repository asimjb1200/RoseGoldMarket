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

class EmailService: NSObject, MFMailComposeViewControllerDelegate, ObservableObject {
    //public static let shared = EmailService()
    @Published var emailSent = false

    func sendEmail(subject:String, body:String, to:String, completion: @escaping (Bool) -> Void){
     if MFMailComposeViewController.canSendMail(){
        let picker = MFMailComposeViewController()
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
         UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController?.present(picker, animated: true, completion: nil)
       //UIApplication.shared.windows.last?.rootViewController?.present(picker,  animated: true, completion: nil)
//         UIApplication
//             .shared
//             .connectedScenes
//             .compactMap { ($0 as? UIWindowScene)?.keyWindow }
//             .last?
//             .rootViewController?.present(picker, animated: true, completion: nil)
    }
      completion(MFMailComposeViewController.canSendMail())
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // detect what the user did
        switch result.rawValue {
            case MFMailComposeResult.cancelled.rawValue:
                print("Mail cancelled")
            case MFMailComposeResult.saved.rawValue:
                print("Mail saved")
            case MFMailComposeResult.sent.rawValue:
                print("Mail sent")
                DispatchQueue.main.async {
                    self.emailSent = true
                }
            case MFMailComposeResult.failed.rawValue:
                print("Mail sent failure: %@", [error!.localizedDescription])
            default:
                break
        }
        controller.dismiss(animated: true, completion: nil)
         }
}
