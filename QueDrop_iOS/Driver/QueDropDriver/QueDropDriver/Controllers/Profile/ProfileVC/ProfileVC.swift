//
//  ProfileVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 20/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

struct Struct_EditProfileDetails {
    var image: UIImage? = nil
    var fname = ""
    var lname = ""
    var username = ""
    var phone = ""
    var email = ""
    var country: [String: Any] = getCountryDialCode(strCode: getCountryCode())
}


class ProfileVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    let txtArr = ["First Name", "Username", "Email"]
    var userDetails = Struct_EditProfileDetails()
    
    enum Enum_ProfileDetails: Int {
        case Image = 0
        case NameRating
        case InputDetails
        case PhoneNumber
    }
    
    //IBOUTLETS
    @IBOutlet weak var btnSetting: UIButton!
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
       loadProfileData()
   }
   
   //MARK:- SETUP & INITIALISATION
   func initializations()  {
       
   }
  
   func setupGUI() {
       updateViewConstraints()
       self.view.layoutIfNeeded()
       self.view.backgroundColor = VIEW_BACKGROUND_COLOR
    
      lblTitle.text = "Profile"
      lblTitle.textColor = .white
      lblTitle.font = UIFont(name: fFONT_BOLD, size: 20.0)
     
      setupTableView(tableView: tblView)
      
      
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
           "ProfilePhoneDetailsTVC",
           "ProfileNameratingCell"
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
    // MARK: - BUTTON ACTION
    @IBAction func settingClick(_ sender: Any) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapOpenEditProfile(_ gesture: UIGestureRecognizer) {
       let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func changePhoneNumber(sender : UIButton) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
       vc.isNavigateFromEditProfile = true
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_ProfileDetails(rawValue: section) else {
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
        guard let row = Enum_ProfileDetails(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch row {
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell") as! ProfileImageCell
            cell.bindDetails(image: userDetails.image)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOpenEditProfile(_:)))
            cell.imgEdit.addGestureRecognizer(tap)
            cell.imgEdit.image = UIImage(named: "edit_pencil")
            return cell
            
        case .InputDetails:
            return getTextDetailCell(indexPath: indexPath)
            
        case .PhoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhoneDetailsTVC") as! ProfilePhoneDetailsTVC
            cell.bindDetails(country: userDetails.country, phoneNumber: userDetails.phone)
            cell.txtPhoneNumber.isUserInteractionEnabled = false
            cell.btnCountry.isUserInteractionEnabled = false
            cell.viewTxtContainer.backgroundColor = .white
            
            let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
           cell.viewTxtContainer.showShadow(color: shadowColor)
           cell.viewTxtContainer.clipsToBounds = false
            cell.btnChangePhone.addTarget(self, action: #selector(changePhoneNumber(sender:)), for: .touchUpInside)
            return cell
        
        case .NameRating:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileNameratingCell") as! ProfileNameratingCell
            if userDetails.fname.count > 0 {
                cell.lblName.text = "\(userDetails.fname) \(userDetails.lname)"
            } else if userDetails.username.count > 0 {
                cell.lblName.text = "\(userDetails.username)"
            } else {
                cell.lblName.text = ""
            }
            
            if let rt = USER_OBJ?.rating {
                cell.viewRating.rating = Double(rt)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = Enum_ProfileDetails(rawValue: indexPath.section) else {
            return
        }
        
        switch row {
            
        default:
            break
        }
        
    }
    
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let title = txtArr[index]
        let cell = tblView.dequeueReusableCell(withIdentifier: "ProfileTextBoxCell", for: indexPath) as! ProfileTextBoxCell
        cell.bindDetails(title: title)
        
        if index == 0 {
            
            cell.txtRightValue.tag = index
            cell.txtRightValue.isEnabled = false
            cell.txtRightValue.tag = index
//            cell.txtRightValue.delegate = self
//            cell.txtRightValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.txtRightValue.placeholder = "Last name"
            cell.txtRightValue.text = userDetails.lname
            cell.txtRightValue.backgroundColor = .white
        }
        
        cell.viewRightTextBox.isHidden = !(index == 0)
        cell.txtLeftValue.isEnabled = false
        cell.txtLeftValue.tag = index
//        cell.txtLeftValue.delegate = self
//        cell.txtLeftValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        
        var value: String? = ""
        if index == 0 {
            value = userDetails.fname
        } else if index == 1 {
            value = userDetails.username
        } else if index == 2 {
            value = userDetails.email
        }
        cell.txtLeftValue.text = value
        
        cell.txtLeftValue.backgroundColor = .white
        
        let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        cell.viewLeftTextBoxContainer.showShadow(color: shadowColor)
        cell.viewRightTextBoxContainer.showShadow(color: shadowColor)
        cell.viewLeftTextBoxContainer.clipsToBounds = false
        cell.viewRightTextBoxContainer.clipsToBounds = false
        return cell
    }
    
}
