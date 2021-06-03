//
//  ChangePasswordVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 14/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

struct Struct_ChangePassword {
    var oldPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    
}

class ChangePasswordVC: BaseViewController {
    //CONSTANTS
        
     //VARIABLES
    var password = Struct_ChangePassword()
     let txtArr = [
         "Current Password",
         "New Password",
         "Confirm Password"
     ]
    
     
     //IBOUTLETS
     @IBOutlet weak var btnSave: UIButton!
     @IBOutlet weak var lblTitle: UILabel!
     @IBOutlet weak var tblView: UITableView!
      
     //MARK:- VC LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        allNotificationCenterObservers()
        setupGUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
     super.viewDidAppear(animated)

    }

    //MARK:- SETUP & INITIALISATION
    func initializations()  {
     
    }

    func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
         
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Change Password"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        btnSave.backgroundColor = THEME_COLOR
        btnSave.setTitle("Save", for: .normal)
        btnSave.setTitleColor(.white, for: .normal)
        btnSave.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        drawBorder(view: btnSave, color: .clear, width: 0.0, radius: 8.0)
        
        setupTableView(tableView: tblView)
    }

    func allNotificationCenterObservers() {
     
     
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "ChangePasswordCell"
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
    
    //MARK: - BUTTON ACTIOn
    @IBAction func btnBackClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
        
    @IBAction func btnUpdateClick(_ sender: Any) {
        if doValidate() {
            doChangePwd(newPwd: password.newPassword, oldPwd: password.oldPassword)
        }
    }
      
    //MARK: - VALIDATION
   func doValidate() -> Bool {
       var strError = ""
       
       
    if password.newPassword != password.confirmPassword {
            strError = "New passsword and confirm new password must be same"
       }
    if password.confirmPassword.count == 0 {
           strError = "Please Provide Confirm New Password"
       }
        if password.newPassword.count == 0 {
            strError = "Please Provide New Password"
        }
        if password.oldPassword.count == 0 {
           strError = "Please Provide Old Password"
       }
       
       if(strError.count > 0){
           //SHOW ERROR MSG
           ShowToast(message: strError)
           return false
       }
       return true
   }
        
}

// MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension ChangePasswordVC: UITableViewDelegate, UITableViewDataSource {
    
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

extension ChangePasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        
        let tag = textField.tag+50
        if let cell = self.tblView.viewWithTag(tag+1) as? ChangePasswordCell {
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
        let cell = tblView.dequeueReusableCell(withIdentifier: "ChangePasswordCell") as! ChangePasswordCell
        
        //cell.setupUI()
        
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

            if #available(iOS 11.0, *) {
                cell.txt.textContentType = .password
            }
            break
            
        case 1:
            textValue = password.newPassword
            
            if #available(iOS 12.0, *) {
                cell.txt.textContentType = .newPassword
            } else if #available(iOS 11.0, *) {
                cell.txt.textContentType = .password
            }
            break
            
        case 2:
            cell.txt.returnKeyType = .done
            textValue = password.confirmPassword
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

