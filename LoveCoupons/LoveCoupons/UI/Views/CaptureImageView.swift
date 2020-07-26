//
//  CaptureImageView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 24/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

struct CaptureImageView {
    @Binding var isShown: Bool
    @Binding var isReturnImage: Bool
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, isReturnImage: $isReturnImage, image: $image)
    }
}

extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImageView>) {
        
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var isCoordinatorShown: Bool
    @Binding var isReturnImageInCoordinator: Bool
    @Binding var imageInCoordinator: UIImage?
    
    init(isShown: Binding<Bool>, isReturnImage: Binding<Bool>, image: Binding<UIImage?>) {
        _isCoordinatorShown = isShown
        _isReturnImageInCoordinator = isReturnImage
        _imageInCoordinator = image
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageInCoordinator = unwrapImage
        isReturnImageInCoordinator = true
        isCoordinatorShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isReturnImageInCoordinator = false
        isCoordinatorShown = false
    }
}
