//
//  UserTypeSelectionVC.swift
//  QueDrop
//
//  Created by C100-104 on 26/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit

class UserTypeSelectionVC: BaseViewController {
    
    //MARK:- Outlets
    
    @IBOutlet var btnCustomer: UIButton!
    @IBOutlet var imgCustomer: UIImageView!
    @IBOutlet var btnSupplier: UIButton!
    @IBOutlet var imgSupplier: UIImageView!
    @IBOutlet var btnTypeSelection: UIButton!
    
    //MARK:- Variables
    var fromSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnTypeSelection.isHidden = true
        if (!isGuest) ,let _ = USER_OBJ {
            APP_DELEGATE.socketIOHandler?.disconenctSocketManually(id: USER_ID)
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    //MARK:- Button Action Methods
    @IBAction func actionSelectCustomer(_ sender: UIButton) {
        saveUserTypeUserDefaults(type: .Customer)
        checkSelectedType()
    }
    @IBAction func actionSelectSupplier(_ sender: UIButton) {
        saveUserTypeUserDefaults(type: .Supplier)
        checkSelectedType()
    }
    @IBAction func actionSelectType(_ sender: UIButton) {
        
        if let _ = USER_OBJ {
            self.navigateToHome(from: .login)
        } else {
            switch UserType {
            case .Supplier:
                let nextViewController = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                if fromSetting{
                    nextViewController.setupForGuest()
                }
                self.navigationController?.pushViewController(nextViewController, animated: true)
                break
                
            default:
                let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
                self.navigationController?.pushViewController(nextViewController, animated: true)
                break
            }
        }
    }
    
    //MARK:- Methods
    func checkSelectedType()  {
        switch UserType {
        case .Supplier:
            UIView.animate(
                withDuration: 5.0,
                animations: {
                    self.btnTypeSelection.isHidden = false
                    self.btnTypeSelection.setTitle("I'm Supplier", for: .normal)
                    self.imgCustomer.isHighlighted = false
                    self.imgSupplier.isHighlighted = true
            },
                completion: nil)
            break
            
        case .Customer:
            UIView.animate(
                withDuration: 5.0,
                animations: {
                    self.btnTypeSelection.isHidden = false
                    self.btnTypeSelection.setTitle("I'm Customer", for: .normal)
                    self.imgCustomer.isHighlighted = true
                    self.imgSupplier.isHighlighted = false
            },
                completion: nil)
            break
            
        default:
            self.btnTypeSelection.isHidden = true
            self.imgCustomer.isHighlighted = false
            self.imgSupplier.isHighlighted = false
            break
        }
    }
    
}
