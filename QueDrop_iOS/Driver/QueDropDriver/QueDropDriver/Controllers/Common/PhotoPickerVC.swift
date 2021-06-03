//
//  PhotoPickerVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

@objc protocol PhotoPickerVCDelegate:NSObjectProtocol{
    func imagePicked(img : UIImage)
}

class PhotoPickerVC: BaseViewController {
    //CONSTANT
       
    //VARIABLES
    var delegate:PhotoPickerVCDelegate?
    var imagePicker = UIImagePickerController()
    var isForRecipt : Bool = false
    
    //IBOUTLETS
    @IBOutlet weak var viewDismiss: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    //MARK: - VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismisssVC))
        tapGesture.numberOfTapsRequired = 1
        viewDismiss.addGestureRecognizer(tapGesture)
        
        if isForRecipt {
            viewContainer.isHidden = true
            #if DEBUG
                openGallery()
           #else
               openCamera()
           #endif
        } else {
            viewContainer.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         if isForRecipt {
            self.view.backgroundColor = .clear
         }else {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        self.view.isOpaque = false
    }
    
    //MARK: - BUTTONS ACTION
    @IBAction func btnGalleryClicked(_ sender: Any) {
        openGallery()
    }
    
    @IBAction func btnCameraClicked(_ sender: Any) {
        openCamera()
    }
    
    func openGallery()  {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    @objc func dismisssVC()  {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- ImagePicker Delegate Method
extension PhotoPickerVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            
            picker.dismiss(animated: true) {
                self.dismiss(animated: true) {
                    if (self.delegate?.responds(to: #selector(self.delegate?.imagePicked(img:))))! {
                       self.delegate?.imagePicked(img: pickedImage)
                    }
                }
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    
    }
   
}
