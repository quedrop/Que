//
//  SupplierProfileVC.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProfileVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnSettings: UIButton!
    
    let txtArr = ["First Name", "Username", "Email"]
    var userDetails = Struct_EditProfileDetails()
    
    enum Enum_ProfileDetails: Int {
        case Image = 0
        case InputDetails
        case PhoneNumber
        case StoreProfile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if storeDetailsObj == nil {
            getStoreDetails()
        }
        currScreen = .profile
        bindDetails()
        self.isTabbarHidden(false)
    }
    
    @IBAction func btnSettingsClick(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierSettingsVC") as! SupplierSettingsVC
        pushVC(vc)
    }
    
    @objc func tapOpenEditProfile(_ gesture: UIGestureRecognizer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierEditProfileVC") as! SupplierEditProfileVC
        pushVC(vc)
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
        view.backgroundColor = VIEW_BG_COLOR
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
    
    func getStoreDetails() {
        API_SupplierProfile.shared.getStoreDetail(
            responseData: { store in
                storeDetailsObj = store
                self.tableView.reloadData()
        },
            errorData: { isDone, message in
                if !isDone {
                    self.showOkAlert(message) {
                        
                    }
                }
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_ProfileDetails(rawValue: section) else {
            return 0
        }
        switch row {
        case .InputDetails:
            return txtArr.count
            
        case .StoreProfile:
            if storeDetailsObj == nil {
                return 0
            }
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProfileImageCell") as! SupplierProfileImageCell
            cell.bindDetails(image: userDetails.image)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOpenEditProfile(_:)))
            cell.imgEdit.addGestureRecognizer(tap)
            cell.imgEdit.image = #imageLiteral(resourceName: "supplier_edit_pencil")
            return cell
            
        case .InputDetails:
            return getTextDetailCell(indexPath: indexPath)
            
        case .PhoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierPhoneDetailsTVC") as! SupplierPhoneDetailsTVC
            cell.bindDetails(country: userDetails.country, phoneNumber: userDetails.phone)
            let title = (USER_OBJ?.phoneNumber ?? "").isEmpty ? "Add" : "Change"
           cell.btnAddOrChange.setTitle(title, for: .normal)
           cell.btnAddOrChange.addTarget(self, action: #selector(showMobileScreen(_ :)), for: .touchUpInside)
            cell.txtPhoneNumber.isUserInteractionEnabled = false
            cell.btnCountry.isUserInteractionEnabled = false
            cell.viewTxtContainer.backgroundColor = .white
            
            let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
            cell.viewTxtContainer.showShadow(color: shadowColor)
            cell.viewTxtContainer.clipsToBounds = false
            return cell
            
        case .StoreProfile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierStoreDetailsTVC") as! SupplierStoreDetailsTVC
            cell.bindStoreDetails()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = Enum_ProfileDetails(rawValue: indexPath.section), row == .StoreProfile else {
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierStoreDetailsVC") as! SupplierStoreDetailsVC
        pushVC(vc)
    }
    @objc func showMobileScreen( _ sender: UIButton){
         self.navigateToHome(from: .register)
     }
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        let index = indexPath.row
        let title = txtArr[index]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProfileTextBoxCell", for: indexPath) as! SupplierProfileTextBoxCell
        cell.bindDetails(title: title)
        cell.viewRightTextBoxContainer.removeShadow()
        
        if index == 0 {
            
            cell.txtRightValue.tag = index
            cell.txtRightValue.isEnabled = false
            cell.txtRightValue.tag = index
//            cell.txtRightValue.delegate = self
//            cell.txtRightValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.txtRightValue.placeholder = "Last name"
            cell.txtRightValue.text = userDetails.lname
            cell.txtRightValue.backgroundColor = .clear
            cell.viewRightTextBoxContainer.showShadow(color: shadowColor)
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
        
        cell.txtLeftValue.backgroundColor = .clear
        
        cell.viewLeftTextBoxContainer.showShadow(color: shadowColor)
        
        return cell
    }
    
}
