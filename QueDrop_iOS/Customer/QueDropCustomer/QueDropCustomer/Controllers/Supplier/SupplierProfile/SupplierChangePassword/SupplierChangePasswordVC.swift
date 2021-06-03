//
//  ChangePasswordViewController.swift
//  ProfileRatingApp
//
//  Created by C100-105 on 22/03/20.
//  Copyright © 2020 Narola. All rights reserved.
//

import UIKit

class SupplierChangePasswordVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!

    var password = Struct_ChangePassword()
    
    private let txtArr = [
        "Current Password",
        "New Password",
        "Confirm Password"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI() {
        let btnTitle = "Save"
        let attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnUpdate.setTitle(nil, for: .normal)
        btnUpdate.setAttributedTitle(attrTitle, for: .normal)
        
        btnUpdate.backgroundColor = .appColor
        btnUpdate.showBorder(.clear, 10)
        
        view.backgroundColor = VIEW_BG_COLOR//.white
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierChangePasswordCell"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 10, footHeight: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
        
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnUpdateClick(_ sender: Any) {
        callChangePasswordAPI()
    }
    
    func validate() -> (Bool, String) {
        var isValid = false
        var message = ""
        
        if password.oldPassword.isEmpty {
            message = "Please enter current password."
            
//        } else if !password.oldPassword.isPasswordValid() {
//            message = "Current password must be in six characters including one digit, one upper case letter and one lower case letter."
            
        } else if password.newPassword.isEmpty {
            message = "Please enter new password."
            
//        } else if !password.newPassword.isPasswordValid() {
//            message = "New password must be in six characters including one digit, one upper case letter and one lower case letter."
            
        } else if password.oldPassword.elementsEqual(password.newPassword) {
            message = "New password is same as old password."
            
        } else if password.confirmPassword.isEmpty {
            message = "Please enter confirm password."
            
        } else if !password.newPassword.elementsEqual(password.confirmPassword) {
            message = "New password and confirm password must be same."
            
        } else {
            isValid = true
        }
        
        return (isValid, message)
    }
    
    func callChangePasswordAPI() {
        let valid = validate()
        
        if !valid.0 {
            showOkAlert(valid.1) {
                
            }
        } else {
            API_SupplierProfile.shared.callChangePasswordAPI(
                detail: password,
                responseData: { isDone, message in
                    self.showDismissAlert(title: "", message: message) {
                        if isDone {
                            self.popVC()
                        }
                    }
            })
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierChangePasswordVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getTextFieldCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SupplierChangePasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        
        let tag = textField.tag+50
        if let cell = self.tableView.viewWithTag(tag+1) as? SupplierChangePasswordCell {
            return cell.txt.becomeFirstResponder()
        }
        return true
    }
    
    @objc func textFieldValueChange(txt: UITextField) {
        let tag = txt.tag
        let str = txt.text.asString()
        
        switch tag {
        case 0:
            password.oldPassword = str
            break
            
        case 1:
            password.newPassword = str
            break
            
        case 2:
            password.confirmPassword = str
            break
            
        default:
            break
        }
    }
    
    func getTextFieldCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierChangePasswordCell") as! SupplierChangePasswordCell
        
        cell.setupUI()
        
        let index = indexPath.row
        let title = txtArr[index]
        cell.lbl.text = title
        cell.txt.placeholder = title
        
        cell.tag = index+50
        cell.txt.delegate = self
        cell.txt.tag = index
        cell.txt.addTarget(self, action: #selector(textFieldValueChange(txt:)), for: .editingChanged)
        
        cell.txt.returnKeyType = .next
        cell.txt.keyboardType = .default
        cell.txt.autocapitalizationType = .none
        
        var textValue = ""
        switch index {
        case 0:
            textValue = password.oldPassword
            cell.txt.placeholder = "Current Password"
            if #available(iOS 11.0, *) {
                cell.txt.textContentType = .password
            }
            break
            
        case 1:
            textValue = password.newPassword
            cell.txt.placeholder = "New Password"
            if #available(iOS 12.0, *) {
                cell.txt.textContentType = .newPassword
            } else if #available(iOS 11.0, *) {
                cell.txt.textContentType = .password
            }
            break
            
        case 2:
            cell.txt.returnKeyType = .done
            textValue = password.confirmPassword
            cell.txt.placeholder = "Confirm Password"
            if #available(iOS 12.0, *) {
                cell.txt.textContentType = .newPassword
            } else if #available(iOS 11.0, *) {
                cell.txt.textContentType = .password
            }
            break

        default:
            break
        }
        
        cell.txt.text = textValue
        
        return cell
    }
}
