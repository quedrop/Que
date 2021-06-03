//
//  PopOverVC.swift
//  QueDrop
//
//  Created by C100-104 on 17/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

protocol PopoverDelegate {
	func dismissPopOver(_ type: String)
}

class PopOverVC: BaseViewController{

    @IBOutlet weak var btnEdit: UIButton!
	 @IBOutlet weak var btnDelete: UIButton!
	var popOverDelegate : PopoverDelegate?
    var isOnlyDelete : Bool = false
	 override func viewDidLoad() {
		 super.viewDidLoad()
		self.view.layer.cornerRadius = 0
		 // Do any additional setup after loading the view.
        if isOnlyDelete { btnEdit.isHidden = true }
        else { btnEdit.isHidden = false }
        
        btnEdit.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btnDelete.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
	 }
	
	 @IBAction func btnEditClick(_ sender: Any) {
		 dismiss(animated: true, completion: nil)
		 //APP_DELEGATE.delegate?.popoverDismissed(isEdit: true)
		popOverDelegate?.dismissPopOver("Edit")
		 
	 }
	 
	 @IBAction func btnDelete(_ sender: Any) {
		 dismiss(animated: true, completion: nil)
		popOverDelegate?.dismissPopOver("Delete")
		 //APP_DELEGATE.delegate?.popoverDismissed(isEdit: false)
//test
	 } 
}
