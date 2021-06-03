//
//  EditProfileVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 13/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class EditProfileVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    let txtArr = ["First Name", "Username", "Email"]
    
    var userDetails = Struct_EditProfileDetails()
    
    enum Enum_EditProfileDetails: Int {
        case Image = 0
        case InputDetails
        case PhoneNumber
    }
    
    //IBOUTLETS
   @IBOutlet weak var btnEdit: UIButton!
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
        lblTitle.text = "Edit Profile"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        btnEdit.backgroundColor = THEME_COLOR
        btnEdit.setTitle("Save", for: .normal)
        btnEdit.setTitleColor(.white, for: .normal)
        btnEdit.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        drawBorder(view: btnEdit, color: .clear, width: 0.0, radius: 8.0)
        
        setupTableView(tableView: tblView)
        loadProfileData()
    }

    func allNotificationCenterObservers() {
     
     
    }
    func loadProfileData() {
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
      tblView.reloadData()
    }

    func setupTableView(tableView: UITableView) {
     let cellIdentifiers = [
         "ProfileImageCell",
         "ProfileTextBoxCell",
         "ProfilePhoneDetailsTVC"
     ]
     
     for ids in cellIdentifiers {
         tableView.register(ids)
     }
     
     //setupPullRefresh(tblView: tableView, delegate: self)
     
     tableView.keyboardDismissMode = .onDrag
     
     tblView.isScrollEnabled = true
     tblView.bounces = true
     tblView.separatorStyle = .none
     tblView.allowsSelection = true
     
     //tableView.contentInsetAdjustmentBehavior = .never
     tableView.setHeaderFootertView(headHeight: 5, footHeight: 20)
     
     tableView.delegate = self
     tableView.dataSource = self
     tableView.backgroundColor = .clear
    }
    // MARK: -BUTTON ACTION
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSaveClicked(_ sender: Any) {
        if doValidate() {
            updateProfileData(userdetail: userDetails)
        }
    }

    @objc func openImagePickerClick() {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "PhotoPickerVC") as! PhotoPickerVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func changePhoneNumber(sender : UIButton) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
       vc.isNavigateFromEditProfile = true
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        if(removeWhiteSpaceCharacter(fromText: userDetails.phone).count == 0){
            strError = "Please Provide Phone number"
        }
        if(removeWhiteSpaceCharacter(fromText:  userDetails.email).count > 0 &&  !( userDetails.email.isEmail )){
             strError = "Please Provide Proper Email id"
        }
        if(removeWhiteSpaceCharacter(fromText: userDetails.email).count == 0){
             strError = "Please Provide Email Id"
        }
        if(removeWhiteSpaceCharacter(fromText: userDetails.username).count == 0){
            strError = "Please Provide user name"
        }
        if(removeWhiteSpaceCharacter(fromText: userDetails.lname).count == 0){
             strError = "Please Provide last name"
         }
        if(removeWhiteSpaceCharacter(fromText: userDetails.fname ).count == 0){
            strError = "Please Provide first name"
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            ShowToast(message: strError)
            return false
        }
        return true
    }
    
}

//MARK: - COUNTRY PICKER DELEGATE METHODS
extension EditProfileVC: CountryPickerVCDelegate {
    
    func countrySelected(dic: [String : Any]) {
        userDetails.country = dic
        tblView.reloadData()
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

// MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension EditProfileVC: UITableViewDelegate, UITableViewDataSource {
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell") as! ProfileImageCell
            cell.bindDetails(image: userDetails.image)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(openImagePickerClick))
            cell.imgEdit.addGestureRecognizer(tap)
            cell.imgEdit.image = UIImage(named: "camera")
            return cell
            
        case .InputDetails:
            return getTextDetailCell(indexPath: indexPath)
            
        case .PhoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhoneDetailsTVC") as! ProfilePhoneDetailsTVC
            cell.bindDetails(country: userDetails.country, phoneNumber: userDetails.phone)
            cell.txtPhoneNumber.isUserInteractionEnabled = false
            cell.btnCountry.isUserInteractionEnabled = false
            cell.btnCountry.addTarget(self, action: #selector(btnCountryCodeClicked(_:)), for: .touchUpInside)
            cell.viewTxtContainer.backgroundColor = .white //VIEW_BACKGROUND_COLOR
            
            let index = 3
            cell.tag = index+50
            cell.txtPhoneNumber.tag = index
            cell.txtPhoneNumber.isEnabled = true
            cell.txtPhoneNumber.delegate = self
            cell.txtPhoneNumber.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.txtPhoneNumber.returnKeyType = .done
            cell.txtPhoneNumber.textColor = .darkGray
             cell.lblCountryCode.textColor = .darkGray
            
            cell.imgDropArrow.image = setImageViewTintColor(img: cell.imgDropArrow, color: .darkGray)
            cell.btnChangePhone.addTarget(self, action: #selector(changePhoneNumber(sender:)), for: .touchUpInside)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let title = txtArr[index]
        let cell = tblView.dequeueReusableCell(withIdentifier: "ProfileTextBoxCell", for: indexPath) as! ProfileTextBoxCell
        cell.isEdit = true
        cell.bindDetails(title: title)
        
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
             cell.viewRightTextBoxContainer.backgroundColor = VIEW_BACKGROUND_COLOR
            cell.txtLeftValue.autocapitalizationType = .sentences
            cell.viewRightTextBoxContainer.showBorder(UIColor.lightGray.withAlphaComponent(0.3), 5)
        }
        
        cell.txtLeftValue.returnKeyType = .next
        cell.txtRightValue.returnKeyType = .next
        
        cell.viewRightTextBox.isHidden = !(index == 0)
        cell.txtLeftValue.isEnabled = true
        cell.txtLeftValue.delegate = self
        cell.txtLeftValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        
        var value: String? = ""
        if index == 0 {
            value = userDetails.fname
            cell.txtLeftValue.isUserInteractionEnabled = true
        } else if index == 1 {
            value = userDetails.username
            cell.txtLeftValue.isUserInteractionEnabled = true
        } else if index == 2 {
            value = userDetails.email
            cell.txtLeftValue.isUserInteractionEnabled = false
            cell.txtLeftValue.textColor = .darkGray
        }
        cell.txtLeftValue.text = value
        
        cell.viewLeftTextBoxContainer.backgroundColor = VIEW_BACKGROUND_COLOR
        cell.viewLeftTextBoxContainer.showBorder(UIColor.lightGray.withAlphaComponent(0.3), 5)
        
        return cell
    }
}

extension EditProfileVC: UITextFieldDelegate {
    
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
        if tag == 101, let cell = self.tblView.viewWithTag(50) as? ProfileTextBoxCell {
            return cell.txtRightValue.becomeFirstResponder()
            
        } else {
            tag = tag + 51
            if let cell = self.tblView.viewWithTag(tag) as? ProfilePhoneDetailsTVC {
                return cell.txtPhoneNumber.becomeFirstResponder()
                
            } else if let cell = self.tblView.viewWithTag(tag) as? ProfileTextBoxCell {
                return cell.txtLeftValue.becomeFirstResponder()
            }
        }
        return true
    }
}

//MARK: - PHOTO PICKER DELEGATE
extension EditProfileVC : PhotoPickerVCDelegate {
    func imagePicked(img: UIImage) {
        userDetails.image = img
        tblView.reloadData()
    }
}

