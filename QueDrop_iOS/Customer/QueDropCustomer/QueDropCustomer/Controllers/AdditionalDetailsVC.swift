//
//  AdditionalDetailsVC.swift
//  QueDrop
//
//  Created by C100-104 on 11/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SafariServices

class AdditionalDetailsVC: BaseViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var btnBack: UIButton!
	@IBOutlet var btnSave: UIButton!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	var isChecked : Bool = false {
        didSet {
			let cell = tableView.cellForRow(at: IndexPath(row: AdditionalFields.termAndConditions.rawValue, section: 0)) as! termAndConditionTVC
            if isChecked {
                cell.btnCheckBox.setImage(UIImage(named: "Checkbox_Checked"), for: .normal)
                cell.btnCheckBox.setBackgroundImage(UIImage(named: "gradient_bg"), for: .normal)
            } else {
                cell.btnCheckBox.setImage(UIImage(), for: .normal)
                cell.btnCheckBox.setBackgroundImage(UIImage(),for: .normal)
            }
        }
    }
	//ENUM
	enum AdditionalFields : Int{
		case email = 0
		case referralCode
		case termAndConditions
	}
	
	var loginType: String = ""
	var userSocialId: String = ""
	var firstName: String = ""
	var lastName: String = ""
	var email: String = ""
	var profilePic_url: String = ""
	var rCode = ""
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register("CommonTextFieldTVC")
		tableView.register("termAndConditionTVC")
		tableView.delegate = self
		tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionSave(_ sender: Any) {
		if doValidate() {
			if(isChecked) {
				doLoginWithSocialAccount(loginType: loginType, userSocialId: userSocialId, firstName: firstName, lastName: lastName, email: email, profilePic_url: profilePic_url)
			} else {
				ShowToast(message: "Please agree with our terms and conditions.")
			}
		}
	}
	
	//MARK:- Functions
	func SetDetails(loginType: String, userSocialId: String, firstName: String, lastName: String, email: String, profilePic_url: String)
	{
		self.loginType = loginType
		self.userSocialId = userSocialId
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		self.profilePic_url = profilePic_url
	}
	//MARK: - VALIDATION
	func doValidate() -> Bool {
		var strError = ""
		
		
		let emailCell = tableView.cellForRow(at: IndexPath(row: AdditionalFields.email.rawValue, section: 0)) as! CommonTextFieldTVC
		
		let codeCell = tableView.cellForRow(at: IndexPath(row: AdditionalFields.referralCode.rawValue, section: 0)) as! CommonTextFieldTVC
		
		
		email = emailCell.textField.text!
		
		rCode = codeCell.textField.text!
		
		
		
		if(removeWhiteSpaceCharacter(fromText: emailCell.textField.text!).count > 0 &&  !(emailCell.textField.text?.isEmail ?? false)){
			strError = "Please Provide Proper Email id"
		}
		if(removeWhiteSpaceCharacter(fromText: emailCell.textField.text!).count == 0){
			strError = "Please Provide Email Id"
		}
		
		if(strError.count > 0){
			//SHOW ERROR MSG
			ShowToast(message: strError)
			return false
		}
		return true
	}
}
extension AdditionalDetailsVC : UITableViewDataSource, UITableViewDelegate {
	 func numberOfSections(in tableView: UITableView) -> Int {
		   return 1
	   }
	   
	   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		   return 3
	   }
	   
	   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		   
		   switch indexPath.row {

		case AdditionalFields.email.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
			//cell.lblTitle.text = "Email"
			cell.textField.placeholder = "Email"
			cell.textField.keyboardType = .emailAddress
			if email.isEmpty
			{
				cell.textField.isEnabled = true
			}
			else
			{
				cell.textField.isEnabled = false
				cell.textField.text = email
			}
			cell.textField.isSecureTextEntry = false
			cell.btnAction.isHidden = true
			return cell

		case AdditionalFields.referralCode.rawValue:
				   let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
				  // cell.lblTitle.text = "Add Referral Code (Optional)"
				   cell.textField.placeholder = "Referral Code (Optional)"
				   cell.textField.isSecureTextEntry = false
				   cell.btnAction.isHidden = false
				   cell.btnAction.tag = indexPath.row
				   cell.btnAction.setImage(UIImage(named: "copy_document"), for: .normal)
				   cell.btnAction.addTarget(self, action: #selector(PasteClicked(sender:)), for: .touchUpInside)
				   return cell
			   
		case AdditionalFields.termAndConditions.rawValue:
				   let cell = tableView.dequeueReusableCell(withIdentifier: "termAndConditionTVC",for: indexPath) as! termAndConditionTVC
				   cell.lblTerms.delegate = self
				   cell.btnCheckBox.addTarget(self, action: #selector(checkBoxChecked(sender:)), for: .touchUpInside)
				   return cell
				   
			   default:
				   let cell = UITableViewCell()
				   cell.backgroundColor = .clear
				   return cell
		   }
	   }
	   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		   return UITableView.automaticDimension
	   }
	
    @objc func checkBoxChecked(sender : UIButton) {
        isChecked = !isChecked
    }
    

    
    @objc func PasteClicked(sender : UIButton) {
		let cell = tableView.cellForRow(at: IndexPath(row: AdditionalFields.referralCode.rawValue, section: 0)) as! CommonTextFieldTVC
        let pb: UIPasteboard = UIPasteboard.general;
        cell.textField.text = pb.string
    }
}
//MARK: - TTTATTRIBUTEDLABEL DELEGATE
extension AdditionalDetailsVC : TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://TC" {
                //vc.isForTerms = true
                self.showTnC(urlStr: URL_termAndCondition)
                print("Terms")
            }
            else if url.absoluteString == "action://PP" {
                //vc.isForTerms = false
                self.showTnC(urlStr: URL_privecyPolicy)
                print("Privacy policy")
            }
            //PUSH(v: vc)
           
        }
        func showTnC(urlStr : String) {
                   if let url = URL(string: urlStr) {
                       let config = SFSafariViewController.Configuration()
                       config.entersReaderIfAvailable = true
               
                       let vc = SFSafariViewController(url: url, configuration: config)
                       present(vc, animated: true)
                   }
               }
}
