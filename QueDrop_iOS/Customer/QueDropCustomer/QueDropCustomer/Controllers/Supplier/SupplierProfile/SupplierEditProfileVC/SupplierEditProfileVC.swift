//
//  SupplierEditProfileVC.swift
//  QueDrop
//
//  Created by C100-105 on 09/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierEditProfileVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnSave: UIButton!
    
    let txtArr = ["First Name", "Username", "Email"]
    
    var userDetails = Struct_EditProfileDetails()
    
    enum Enum_EditProfileDetails: Int {
        case Image = 0
        case InputDetails
        case PhoneNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currScreen = .editProfile
         self.isTabbarHidden(false)
        bindDetails()
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnSaveClick(_ sender: Any) {
        API_SupplierProfile.shared.callEditProfileApi(
            userDetails: userDetails,
            responseData: { user in
                let isPhoneVerified = user.isPhoneVerified.asInt() == 1
                if !isPhoneVerified {
                    let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                    vc.isNavigateFromEditProfile = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.bindDetails()
                }
        },
            errorData: { isDone, message in
                let isPhoneVerified = (USER_OBJ?.isPhoneVerified).asInt() == 1
                if isPhoneVerified {
                    if isDone {
                        self.popVC()
                    } else {
                        self.showOkAlert(message) {
                            
                        }
                    }
                }
        })
    }
    
    func bindDetails() {
        userDetails = Struct_EditProfileDetails()
        if let user = USER_OBJ {
            userDetails.fname = user.firstName.asString()
            userDetails.lname = user.lastName.asString()
            userDetails.username = user.userName.asString()
            userDetails.email = user.email.asString()
            userDetails.phone = user.phoneNumber.asString()
            
            if let dialingCode = user.countryCode {
                userDetails.country = getCountry(fromDialingCode: dialingCode.description)
            }
        }
        
        tableView.reloadData()
    }
    
    func setupUI() {
        
        let btnTitle = "Save"
        let attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnSave.setTitle(nil, for: .normal)
        btnSave.setAttributedTitle(attrTitle, for: .normal)
        
        btnSave.backgroundColor = .appColor
        btnSave.showBorder(.clear, 10)
        
        view.backgroundColor = VIEW_BG_COLOR //.white
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierProfileImageCell",
            "SupplierProfileTextBoxCell",
            "SupplierStoreDetailsTVC",
            "SupplierPhoneDetailsTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 5, footHeight: 20)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    override func didFinishPickingMedia(selectedImage image: UIImage?) {
        if let image = image {
            userDetails.image = image
            tableView.reloadData()
        }
    }
    
}

extension SupplierEditProfileVC: CountryPickerVCDelegate {
    
    func countrySelected(dic: [String : Any]) {
        userDetails.country = dic
        tableView.reloadData()
    }
    
    @objc func btnCountryCodeClicked(_ sender: Any) {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "CountryPickerVC") as!  CountryPickerVC
        vc.delegate = self
        vc.currentCountry = userDetails.country
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierEditProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_EditProfileDetails(rawValue: section) else {
            return 0
        }
        switch row {
        case .InputDetails:
            return txtArr.count
            
        default:
            break
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_EditProfileDetails(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch row {
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProfileImageCell") as! SupplierProfileImageCell
            cell.bindDetails(image: userDetails.image)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(openImagePickerClick))
            cell.imgEdit.addGestureRecognizer(tap)
            cell.imgEdit.image = #imageLiteral(resourceName: "supplier_camera")
            return cell
            
        case .InputDetails:
            return getTextDetailCell(indexPath: indexPath)
            
        case .PhoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierPhoneDetailsTVC") as! SupplierPhoneDetailsTVC
            cell.bindDetails(country: userDetails.country, phoneNumber: userDetails.phone)
            cell.txtPhoneNumber.isUserInteractionEnabled = false
            cell.txtPhoneNumber.textColor = .darkGray
            cell.btnCountry.isUserInteractionEnabled = false
            let title = (USER_OBJ?.phoneNumber ?? "").isEmpty ? "Add" : "Change"
            cell.btnAddOrChange.setTitle(title, for: .normal)
          cell.btnAddOrChange.addTarget(self, action: #selector(showMobileScreen(_ :)), for: .touchUpInside)
            cell.btnCountry.addTarget(self, action: #selector(btnCountryCodeClicked(_:)), for: .touchUpInside)
            cell.viewTxtContainer.backgroundColor = .white//.tableViewBg
            
            let index = 3
            cell.tag = index+50
            cell.txtPhoneNumber.tag = index
            cell.txtPhoneNumber.isEnabled = true
            cell.txtPhoneNumber.delegate = self
            cell.txtPhoneNumber.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.txtPhoneNumber.returnKeyType = .done
            cell.viewTxtContainer.showBorder(UIColor.lightGray.withAlphaComponent(0.6), 5)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let title = txtArr[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProfileTextBoxCell", for: indexPath) as! SupplierProfileTextBoxCell
        cell.bindDetails(title: title)
        let bgColor = UIColor.white // #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        
        cell.tag = index+50
        cell.txtLeftValue.tag = index
        
        if index == 0 {
            cell.txtLeftValue.tag = 101
            cell.txtRightValue.tag = index
            cell.txtRightValue.isEnabled = true
            cell.txtRightValue.tag = index
            cell.txtRightValue.delegate = self
            cell.txtRightValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.txtRightValue.placeholder = "Last name"
            cell.txtRightValue.text = userDetails.lname
            cell.viewRightTextBoxContainer.backgroundColor = bgColor
            cell.txtLeftValue.autocapitalizationType = .sentences
            
            cell.viewRightTextBoxContainer.showBorder(/*bgColor*/UIColor.lightGray.withAlphaComponent(0.6), 5)
        }
        
        cell.txtLeftValue.returnKeyType = .next
        cell.txtRightValue.returnKeyType = .next
        
        cell.viewRightTextBox.isHidden = !(index == 0)
        if index == 2
        {
            cell.txtLeftValue.textColor = .darkGray
        }
        else
        {
            cell.txtLeftValue.textColor = .black
        }
        if !(userDetails.email.isEmpty)
        {
            cell.txtLeftValue.isEnabled = !(index == 2)
        }
        
        
        cell.txtLeftValue.delegate = self
        cell.txtLeftValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        
        var value: String? = ""
        if index == 0 {
            value = userDetails.fname
        } else if index == 1 {
            value = userDetails.username
        } else if index == 2 {
            value = userDetails.email
        }
        cell.txtLeftValue.text = value
        
        cell.viewLeftTextBoxContainer.backgroundColor = bgColor
        cell.viewLeftTextBoxContainer.showBorder(/*bgColor*/UIColor.lightGray.withAlphaComponent(0.6), 5)
        
        return cell
    }
    @objc func showMobileScreen( _ sender: UIButton){
           self.navigateToHome(from: .register)
       }
}

extension SupplierEditProfileVC: UITextFieldDelegate {
    
    @objc func textFieldValueChange(_ txt: UITextField) {
        let value = txt.text.asString()
        let index = txt.tag
        
        if index == 101 {
            userDetails.fname = value
        } else if index == 0 {
            userDetails.lname = value
        } else if index == 1 {
            userDetails.username = value
        } else if index == 2 {
            userDetails.email = value
        } else if index == 3 {
            userDetails.phone = value
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        
        var tag = textField.tag
        if tag == 101, let cell = self.tableView.viewWithTag(50) as? SupplierProfileTextBoxCell {
            return cell.txtRightValue.becomeFirstResponder()
            
        } else {
            tag = tag + 51
            if let cell = self.tableView.viewWithTag(tag) as? SupplierPhoneDetailsTVC {
                return cell.txtPhoneNumber.becomeFirstResponder()
                
            } else if let cell = self.tableView.viewWithTag(tag) as? SupplierProfileTextBoxCell {
                return cell.txtLeftValue.becomeFirstResponder()
            }
        }
        return true
    }
}
