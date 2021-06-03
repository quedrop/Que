//
//  SettingsVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 13/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

enum SettingAbbr: String {
          case CP
          case REF
          case PAY
          case RATE
          case IDE
      }

struct Struct_SettingData {
    let image: UIImage
    let title: String
    let abr : SettingAbbr
}

class SettingsVC: BaseViewController {
    //CONSTANTS
       
    //VARIABLES
    var arr = [Struct_SettingData]()
   
    
    //IBOUTLETS
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
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
        
        lblTitle.text = "Settings"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build =  Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
            lblVersion.text = "v\(version).\(build)"
        }
        lblVersion.textColor = .darkGray
        lblVersion.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 14.0))
        
        btnLogout.backgroundColor = THEME_COLOR
        btnLogout.setTitle("Logout", for: .normal)
        btnLogout.setTitleColor(.white, for: .normal)
        btnLogout.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        drawBorder(view: btnLogout, color: .clear, width: 0.0, radius: 8.0)
        
        
        if USER_OBJ?.loginType == "Standard" {
            arr = [
                Struct_SettingData(image: UIImage(named: "lock")!, title: "Change Password", abr: .CP),
                Struct_SettingData(image: UIImage(named: "ref_code")!, title: "My Referral Code", abr: .REF),
                Struct_SettingData(image: UIImage(named: "wallet")!, title: "Manage Payment Method", abr: .PAY),
                Struct_SettingData(image: UIImage(named: "review")!, title: "Reviews & Ratings", abr: .RATE),
                Struct_SettingData(image:UIImage(named: "identity")!, title: "Identity Details", abr: .IDE),
            ]
        } else {
            arr = [
                Struct_SettingData(image: UIImage(named: "ref_code")!, title: "My Referral Code", abr: .REF),
                Struct_SettingData(image: UIImage(named: "wallet")!, title: "Manage Payment Method", abr: .PAY),
                Struct_SettingData(image: UIImage(named: "review")!, title: "Reviews & Ratings", abr: .RATE),
                Struct_SettingData(image:UIImage(named: "identity")!, title: "Identity Details", abr: .IDE),
            ]
        }
        
        setupTableView(tableView: tblView)
       // loadProfileData()
    }

    func allNotificationCenterObservers() {
     
     
    }
    
    func setupTableView(tableView: UITableView) {
           
           let cellIdentifiers = [
               "SettingCell"
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
       
    // MARK: - BUTTON ACTION
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnLogoutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.callLogoutAPI()
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return arr.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let index = indexPath.row
    let data = arr[index]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
    cell.bindDetails(data: data)
    
    return cell
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let index = indexPath.row
    let data = arr[index]
    
    switch data.abr {
    case .CP:
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        navigationController?.pushViewController(vc, animated: true)
        break
        
    case .REF:
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "MyReferralCodeVC") as! MyReferralCodeVC
        navigationController?.pushViewController(vc, animated: true)
        break
        
    case .RATE:
           let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ReviewRatingListVC") as! ReviewRatingListVC
          navigationController?.pushViewController(vc, animated: true)
           break
    case .IDE:
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ViewDriverIdentityDetailsVC") as! ViewDriverIdentityDetailsVC
        navigationController?.pushViewController(vc, animated: true)
        break
    case .PAY:
       let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ManagePaymentMethodVC") as! ManagePaymentMethodVC
       navigationController?.pushViewController(vc, animated: true)
       break
    }
}
}
