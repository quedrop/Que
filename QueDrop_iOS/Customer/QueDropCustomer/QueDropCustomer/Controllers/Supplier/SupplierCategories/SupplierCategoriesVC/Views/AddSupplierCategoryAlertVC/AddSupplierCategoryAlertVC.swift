//
//  AddPlayerAlertVC.swift
//  Tournament
//
//  Created by C100-105 on 25/02/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import UIKit

class AddSupplierCategoryAlertVC: BaseAlertViewController {
    
    @IBOutlet weak var constraintsBlurrTrailling: NSLayoutConstraint!
    @IBOutlet weak var constraintsBlurrBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintsBlurrLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintsBlurrTop: NSLayoutConstraint!
    
    @IBOutlet weak var blurrView: AlertBlurrView!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var stackBtnView: UIStackView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var category: FoodCategory? = nil
    var parentVC: BaseViewController?
    var callbackForData: ((Struct_AddCategoryDetails) -> ())? = nil
    var categoryDetails = Struct_AddCategoryDetails()
    let imagePlaceHolder = #imageLiteral(resourceName: "add_picture")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.delegate = self
        txtName.returnKeyType = .done
        
        viewContainer.showBorder(.clear, 10)
        imgProfile.contentMode = .scaleAspectFill
        imgProfile.clipsToBounds = true
        imgProfile.circlularView()
        
        categoryDetails = Struct_AddCategoryDetails()
        
        if let category = category {
            categoryDetails.name = category.storeCategoryTitle.asString()
            if let imageUrl = category.storeCategoryImage {
                let url = URL_STORE_CATEGORY_IMAGES + imageUrl
                imgProfile.setWebImage(url, imagePlaceHolder, complete: { isDone, image in
                    if isDone {
                        self.imgProfile.image = image
                    }
                })
            }
        }
        
        txtName.text = categoryDetails.name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        imgProfile.addGestureRecognizer(tap)
        
        imgProfile.isUserInteractionEnabled = true
        
        setupAlertDismiss(toView: blurrView)

        animateBlurrView()
    }
    
    func animateBlurrView() {
        let frame = self.viewContainer.frame
        
        self.constraintsBlurrLeading.constant = frame.minX
        self.constraintsBlurrTop.constant = frame.minY
        self.constraintsBlurrTrailling.constant = frame.minX
        self.constraintsBlurrBottom.constant = frame.minY
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + showViewTimeInterval, execute: {
            self.blurrView.isHidden = false
            UIView.animate(
                withDuration: self.showViewTimeInterval,
                animations: {
                    self.constraintsBlurrTop.constant = 0
                    self.constraintsBlurrBottom.constant = 0
                    self.constraintsBlurrLeading.constant = 0
                    self.constraintsBlurrTrailling.constant = 0
                    self.view.layoutIfNeeded()
            })
        })
    }
    
    @objc func openImagePicker() {
        let alert = CustomControl.openActionSheetAlert(
            "Select Action",
            nil,
            arrProfileSelection,
            response: { selected in
                self.openImagePickerSelectionVC(isCamera: selected == 1)
        })
        parentVC?.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnOkClick(_ sender: Any) {
        categoryDetails.name = txtName.text.asString()
        
        if !categoryDetails.name.isEmpty &&
            (categoryDetails.image != nil || category != nil) {
            
            callbackForData?(categoryDetails)
        } else {
            if categoryDetails.image == nil && category == nil {
                showOkAlert("Please add a profile picture.") {
                    self.openImagePicker()
                }
            } else if categoryDetails.name.isEmpty {
                showOkAlert("Please enter category name.") {
                    self.txtName.becomeFirstResponder()
                }
            }
        }
    }
    
    @IBAction func btnCancelClick(_ sender: Any) {
        hideDialog()
    }
    
    override func didFinishPickingMedia(selectedImage image: UIImage?) {
        categoryDetails.image = image
        imgProfile.image = image != nil ? image : imagePlaceHolder
        imgProfile.circlularView()
    }
}

extension AddSupplierCategoryAlertVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
