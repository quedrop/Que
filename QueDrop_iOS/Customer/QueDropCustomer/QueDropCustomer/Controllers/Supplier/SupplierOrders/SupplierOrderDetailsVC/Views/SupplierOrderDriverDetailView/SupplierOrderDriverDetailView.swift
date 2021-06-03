//
//  SupplierOrderDriverDetailView.swift
//  QueDrop
//
//  Created by C100-105 on 04/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderDriverDetailView: UIView {
    
    @IBOutlet weak var parentViewContainer: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewDriverContainer: UIView!
    
    @IBOutlet weak var viewBtnCall: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnCall: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("SupplierOrderDriverDetailView", owner: self, options: nil)
        parentViewContainer.fixInView(self)
        
        viewDriverContainer.showBorder(.lightGray, 10, 0.5)
        
        parentViewContainer.isUserInteractionEnabled = true
        viewBtnCall.isUserInteractionEnabled = true
        
        lblName.text = ""
        lblMobile.text = ""
        
        btnCall.setImage(#imageLiteral(resourceName: "supplier_call"), for: .normal)
        btnCall.isUserInteractionEnabled = true
        viewContainer.isUserInteractionEnabled = true
        viewDriverContainer.isUserInteractionEnabled = true
        viewBtnCall.isUserInteractionEnabled = true
        
      
    }
    
    func bindDetail(ofCustomer user: CustomerDetail) {
        lblTitle.text = "Customer Info"
        let url = user.userImage!.getUserImageURL() //URL_USER_IMAGES + user.userImage.asString()
        imgView.setWebImage(url.absoluteString, .noImagePlaceHolder, complete: { isDone, image in
            self.imgView.circlularView(0, radius: isDone ? nil : 0)
        })
        
        var name = user.firstName.asString() + " "
        if let lastName =  user.lastName {
           if lastName.count > 0 {
               name += lastName.prefix(1) + "."
           }
       }
        lblName.text = name /*user.firstName.asString() + " " + user.lastName.asString()*/
        lblMobile.text = "-"//"+" + user.countryCode.asInt().description + " " + user.phoneNumber.asString()
          btnCall.isHidden = true
    }
    
    func bindDetail(ofDriver user: DriverDetail) {
        lblTitle.text = "Driver Info"
        let url = user.userImage!.getUserImageURL() //URL_USER_IMAGES + user.userImage.asString()
        imgView.setWebImage(url.absoluteString, .noImagePlaceHolder, complete: { isDone, image in
            self.imgView.circlularView(0, radius: isDone ? nil : 0)
        })
        
        lblName.text = user.firstName.asString() + " " + user.lastName.asString()
        lblMobile.text = "+" + user.countryCode.asInt().description + " " + user.phoneNumber.asString()
        
    }
    
}
