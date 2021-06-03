//
//  ProfileVC.swift
//  QueDrop
//
//  Created by C100-104 on 09/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class ProfileVC: BaseViewController {

	@IBOutlet var btnSettings: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let txtArr = ["First Name", "Username", "Email"]
    var userDetails = Struct_EditProfileDetails()
    
    enum Enum_ProfileDetails: Int {
        case Image = 0
        case InputDetails
        case PhoneNumber
    }
    

    
     override func viewDidLoad() {
          super.viewDidLoad()
          
          setupUI()
      }
      
      override func viewWillAppear(_ animated: Bool) {
          bindDetails()
        currScreen = .profile
        self.isTabbarHidden(false)
      }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

	@IBAction func actionSettings(_ sender: Any) {
		//LogOutUser()
        let vc = storyboard?.instantiateViewController(withIdentifier: "CustomerSettingsVC") as! CustomerSettingsVC
               self.navigationController?.pushViewController(vc, animated: true)
	}
	
    @objc func tapOpenEditProfile(_ gesture: UIGestureRecognizer) {
        
        let vc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierEditProfileVC") as! SupplierEditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
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
       view.backgroundColor = .white
       setupTableView(tableView: tableView)
   }
   
   func setupTableView(tableView: UITableView) {
       
       let cellIdentifiers = [
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
       tableView.backgroundColor = .tableViewBg
   }

}
extension ProfileVC : UITableViewDataSource, UITableViewDelegate
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if isGuest{
//            return 1
//        }
        return 4
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerProfileHeaderTVCell") as! CustomerProfileHeaderTVCell
            cell.bindDetails(image: userDetails.image, rating: USER_OBJ?.rating ?? 0)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOpenEditProfile(_:)))
            cell.imgEdit.isHidden = isGuest
            cell.imgEdit.addGestureRecognizer(tap)
            cell.imgEdit.image = #imageLiteral(resourceName: "supplier_edit_pencil")
            //userDetails.
            cell.viewRatingHeight.constant = 18
            cell.viewAttributedLabel.isHidden = true
            cell.basicDetailsHeight.constant = 30
            if isGuest{
                cell.viewRatingHeight.constant = 0
                cell.viewAttributedLabel.isHidden = false
                cell.basicDetailsHeight.constant = 0
                let strAgreement = "Login In to get your account details" as NSString
                cell.lblLoginDetails.text = strAgreement
                       cell.lblLoginDetails.numberOfLines = 0;
                       
                       let fullAttributedString = NSAttributedString(string:strAgreement as String, attributes: [
                           NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                           NSAttributedString.Key.font : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
                       ])
                       cell.lblLoginDetails.textAlignment = .center
                       cell.lblLoginDetails.attributedText = fullAttributedString;
                       
                       let rangeTC = strAgreement.range(of: "Login In")
                       
                       
                       let ppLinkAttributes: [String: Any] = [
                           NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
                           NSAttributedString.Key.underlineStyle.rawValue: false,
                           NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
                       ]
                       let ppActiveLinkAttributes: [String: Any] = [
                           NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
                           NSAttributedString.Key.underlineStyle.rawValue: false,
                           NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
                       ]
                       
                       cell.lblLoginDetails.activeLinkAttributes = ppActiveLinkAttributes
                       cell.lblLoginDetails.linkAttributes = ppLinkAttributes
                       
                       let urlTC = URL(string: "action://LI")!
                       
                       cell.lblLoginDetails.addLink(to: urlTC, with: rangeTC)
                       
                       
                       cell.lblLoginDetails.textColor = UIColor.black;
                       cell.lblLoginDetails.delegate = self;
            }
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
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isGuest
        {
            guard let row = Enum_ProfileDetails(rawValue: indexPath.section) else {
                return 0
            }
            switch row {
                case .InputDetails,
                     .PhoneNumber:
                    return 0
                
            default:
                return UITableView.automaticDimension
            }
        }
        else
        {
                return UITableView.automaticDimension
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProfileTextBoxCell", for: indexPath) as! SupplierProfileTextBoxCell
        cell.bindDetails(title: title)
        let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        cell.viewLeftTextBoxContainer.showShadow(color: shadowColor)
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
        
        return cell
    }
    @objc func showMobileScreen( _ sender: UIButton){
        self.navigateToHome(from: .register)
    }
}
extension ProfileVC : TTTAttributedLabelDelegate{
    
    //MARK: - TTTAttributedLabel DELEGATE METHOD
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //let vc = CommonWebViewVC.init(nibName: "CommonWebViewVC", bundle: nil)
        if url.absoluteString == "action://LI" {
            //vc.isForTerms = true
            print("Show Login")
            if isGuest
            {
                if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                {
                    LoginView.setupForGuest()
                    let transition:CATransition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromTop
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(LoginView, animated: false)
                    //self.navigationController?.pushViewController(LoginView, animated: true)
                }
            }
        }
        
    }
}
