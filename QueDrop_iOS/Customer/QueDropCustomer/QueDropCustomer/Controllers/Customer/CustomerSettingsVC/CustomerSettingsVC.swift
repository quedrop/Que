//
//  CustomerSettingsVC.swift
//  QueDrop
//
//  Created by C205 on 13/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CustomerSettingsVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLogout: UIButton!
     @IBOutlet weak var lblVersion: UILabel!
    let arr = [
           Struct_SettingData(image: #imageLiteral(resourceName: "supplier_change_password"), title: "Change Password"),
           Struct_SettingData(image: #imageLiteral(resourceName: "location_black"), title: "Manage Address"),
           //Struct_SettingData(image: #imageLiteral(resourceName: "supplier_wallet"), title: "Manage Payment Method"),
           Struct_SettingData(image: #imageLiteral(resourceName: "referral"), title: "My Referral Code"),
           Struct_SettingData(image: #imageLiteral(resourceName: "review_and_rating"), title: "Review & Ratings"),
           Struct_SettingData(image: #imageLiteral(resourceName: "fav"), title: "Favourites"),
           Struct_SettingData(image: #imageLiteral(resourceName: "supplier_switch"), title: "Switch Account")
       ]
    enum settingCells : Int{
        case changePassword = 0
        case manageAddress
        //case managePayment
        case referralCode
        case review
        case favorite
        case switchAccount
    }
   override func viewDidLoad() {
       super.viewDidLoad()
       setupTableView(tableView: tableView)
    self.btnLogout.isHidden = isGuest
    
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build =  Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
        lblVersion.text = "v\(version).\(build)"
    }
    lblVersion.textColor = .darkGray
    lblVersion.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 14.0))
    
     //  setupUI()
   }
    override func viewWillAppear(_ animated: Bool) {
        self.isTabbarHidden(true)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionLogout(_ sender: Any) {
        self.LogOutUser()
    }
    
    func setupTableView(tableView: UITableView) {
           
           let cellIdentifiers = [
               "SupplierSettingTVC"
           ]
           
           for ids in cellIdentifiers {
               tableView.register(ids)
           }
           
           //setupPullRefresh(tblView: tableView, delegate: self)
           
           tableView.keyboardDismissMode = .onDrag
           
           tableView.isScrollEnabled = true
           tableView.bounces = true
           tableView.separatorStyle = .singleLine
           tableView.allowsSelection = true
           tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
           
           //tableView.contentInsetAdjustmentBehavior = .never
           tableView.setHeaderFootertView(headHeight: 20, footHeight: 20)
           
           tableView.delegate = self
           tableView.dataSource = self
           tableView.backgroundColor = .clear
       }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CustomerSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let data = arr[index]
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierSettingTVC", for: indexPath) as! SupplierSettingTVC
        cell.bindDetails(data: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isGuest
        {
            if  indexPath.row == settingCells.changePassword.rawValue ||
                indexPath.row == settingCells.review.rawValue ||
                indexPath.row == settingCells.referralCode.rawValue ||
                indexPath.row == settingCells.favorite.rawValue
            {
                return 0
            }
        }
        else if (USER_OBJ?.loginType ?? "").lowercased() != "standard"
        {
            if  indexPath.row == settingCells.changePassword.rawValue
            {
                    return 0
            }
            
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        switch index {
        case settingCells.changePassword.rawValue:
            let vc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierChangePasswordVC") as! SupplierChangePasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case settingCells.manageAddress.rawValue :
            let nextViewController = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
            isMapPresented = true
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
            break
        case settingCells.referralCode.rawValue:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReferralVC") as! ReferralVC
              self.navigationController?.pushViewController(vc, animated: true)
              break
            case settingCells.review.rawValue:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReviewAndRatingVC") as! ReviewAndRatingVC
              self.navigationController?.pushViewController(vc, animated: true)
              break
        case settingCells.switchAccount.rawValue:
            let vc = MainStoryboard.instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
            vc.fromSetting = true
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case settingCells.favorite.rawValue:
            let vc = CustomerStoryboard.instantiateViewController(withIdentifier: "FavouriteStoreVC") as! FavouriteStoreVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        default:
            break
        }
    }
}

