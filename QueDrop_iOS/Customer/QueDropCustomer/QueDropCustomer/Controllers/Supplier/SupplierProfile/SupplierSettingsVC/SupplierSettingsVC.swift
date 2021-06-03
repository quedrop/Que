//
//  SupplierSettingsVC.swift
//  QueDrop
//
//  Created by C100-105 on 09/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierSettingsVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnLogout: UIButton!
    
    let arr = [
        Struct_SettingData(image: #imageLiteral(resourceName: "supplier_change_password"), title: "Change Password"),
        Struct_SettingData(image: #imageLiteral(resourceName: "supplier_wallet"), title: "Manage Payment Method"),
        Struct_SettingData(image: #imageLiteral(resourceName: "supplier_switch"), title: "Switch Account")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnLogoutClick(_ sender: Any) {
        API_SupplierProfile.shared.logOutUser(
            responseData: { isDone, message in
                self.ReinitializeApp()
        })
    }
    
    func setupUI() {
        
        let btnTitle = "Log Out"
        let attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnLogout.setTitle(nil, for: .normal)
        btnLogout.setAttributedTitle(attrTitle, for: .normal)
        
        btnLogout.backgroundColor = .appColor
        btnLogout.showBorder(.clear, 10)
        
        view.backgroundColor = VIEW_BG_COLOR//.white
        setupTableView(tableView: tableView)
        
        
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
        tableView.setHeaderFootertView(headHeight: 10, footHeight: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
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
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        switch index {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierChangePasswordVC") as! SupplierChangePasswordVC
            pushVC(vc)
            break
            
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierManagePaymentMethodVC") as! SupplierManagePaymentMethodVC
            pushVC(vc)
            break
            
        case 2:
            let vc = MainStoryboard.instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
            pushVC(vc)
            break
            
        default:
            break
        }
    }
}
