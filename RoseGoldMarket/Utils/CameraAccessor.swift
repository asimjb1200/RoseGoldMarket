//
//  CameraAccessor.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/28/22.
//

import UIKit
import SwiftUI

struct CameraAccessor: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> CameraCoordinator {
        return CameraCoordinator(self)
    }
    
    final class CameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var cameraAccessor: CameraAccessor
        
        init(_ cameraAccessor: CameraAccessor) {
            self.cameraAccessor = cameraAccessor
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            guard let selectedImage = info[.originalImage] as? UIImage else {
                print("couldn't convert the selected image to a UI image")
                return
            }
            self.cameraAccessor.selectedImage = selectedImage
        }
    }
}


