//
//  Ext+BaseVC+MediaPicking.swift
//  Tournament
//
//  Created by C100-105 on 12/02/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices


//MARK: - Image picker and Upload image delegate
extension SupplierBaseViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func openImagePickerClick() {
        
        let alert = CustomControl.openActionSheetAlert(
            "Select Action",
            nil,
            arrProfileSelection,
            response: { selected in
                self.openImagePickerSelectionVC(isCamera: selected == 1)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func openImagePickerSelectionVC(isCamera: Bool) {
        
        let type: UIImagePickerController.SourceType = isCamera ? .camera : .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(type) {
            
            imagePicker = UIImagePickerController()
            imagePicker.sourceType = type
            
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            
            //imagePicker.isModalInPresentation = false
            //imagePicker.modalPresentationStyle = .popover
            //imagePicker.isModalInPopover = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        didFinishPickingMedia(selectedImage: selectedImage)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    @objc func didFinishPickingMedia(selectedImage image: UIImage?) {
    }
    
}
