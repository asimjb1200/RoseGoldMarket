//
//  ImagePicker.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 12/28/22.
//

import Foundation
import SwiftUI
import PhotosUI

struct ImageSelector: UIViewControllerRepresentable {
    
    @Binding var image:UIImage?
    
    // will handle the job of presenting the content from UIKit to SwiftUI
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator // this uses the coordinator returned by the makeCoordinator function
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    // swiftui calls this anytime the ImageSelector is created
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // respond to interaction from the user while they're using the picker. Acts as the picker's delegate
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) // tell the picker to go away
            
            // exit if no selection was made
            guard let provider = results.first?.itemProvider else {return}
            
            // if this has an image, use it
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
        
        var parent: ImageSelector
        init(_ parent: ImageSelector) {
            self.parent = parent
        }
    }
}



