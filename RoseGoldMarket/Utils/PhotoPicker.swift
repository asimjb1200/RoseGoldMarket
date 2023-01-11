//
//  PhotoPicker.swift
//  RoseGoldMarket
//
//  Created by Asim Brown on 1/19/22.
//

import SwiftUI

//struct PhotoPicker: UIViewControllerRepresentable {
//    @Binding var plantImage: UIImage? // tie the image to the view
//    @Binding var plantImage2: UIImage?
//    @Binding var plantImage3: UIImage?
//    @Binding var plantEnum: PlantOptions
//
//    typealias UIViewControllerType = UIImagePickerController // let this struct know that it'll be working with images
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator // tells photo picker to use my custom coordinator
//        picker.allowsEditing = true // allows them to crop photo, etc.
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(photoPicker: self)
//    }
//
//    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate { // used to pass info from uikit to swiftui
//        let photoPicker: PhotoPicker
//
//        init(photoPicker: PhotoPicker) {
//            self.photoPicker = photoPicker
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.editedImage] as? UIImage { // grabbing the edited image since we allowed them that option on line 16
//                guard let data = image.jpegData(compressionQuality: 0.5) else { return }
//                guard let compressedImage = UIImage(data: data) else { return }
//
//                switch photoPicker.plantEnum {
//                    case .imageOne:
//                        photoPicker.plantImage = compressedImage
//                    case .imageTwo:
//                        photoPicker.plantImage2 = compressedImage
//                    case .imageThree:
//                        photoPicker.plantImage3 = compressedImage
//                }
//            } else {
//                // return an error if an image isn't selected
//            }
//            // dismiss the photo picker
//            picker.dismiss(animated: true)
//        }
//    }
//
//}
