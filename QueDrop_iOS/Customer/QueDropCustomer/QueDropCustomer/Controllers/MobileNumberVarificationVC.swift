//
//  MobileNumberVarificationVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit

class MobileVerificationVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    var currentCountry = [String : Any]()
    var isNavigateFromEditProfile = false
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	var isFromGuest = false
    
    //MARK: - VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isTabbarHidden(true)
		//self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        txtPhoneNumber.becomeFirstResponder()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func setupGUI() {
        lblTitle.text = "Phone Number"
        lblTitle.textColor = THEME_COLOR
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        lblCountryCode.text = "+44"
        lblCountryCode.textColor = .black
        lblCountryCode.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 18.0))
        scaleFont(byWidth: lblCountryCode)
        
        lblInfo.textColor = .lightGray
        lblInfo.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        
        txtPhoneNumber.textColor = .black
        txtPhoneNumber.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 18.0))
        txtPhoneNumber.setLeftPadding(108.0)
        txtPhoneNumber.tintColor = txtPhoneNumber.textColor
        txtPhoneNumber.placeholder = "Phone number"
        txtPhoneNumber.text = USER_OBJ?.phoneNumber
        txtPhoneNumber.addBottomLine()
       // setupFloatingTextField(textField: txtPhoneNumber)
        
        btnNext.backgroundColor = THEME_COLOR
        btnNext.setTitle("Next", for: .normal)
        btnNext.setTitleColor(.white, for: .normal)
        btnNext.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        
        makeCircular(view: imgFlag)
        
        if let dialingCode = USER_OBJ?.countryCode {
          if dialingCode == 0 {
            currentCountry = getCountryDialCode(strCode: getCountryCode())
          } else {
            currentCountry = getCountry(fromDialingCode: dialingCode.description)
          }
        } else {
          currentCountry = getCountryDialCode(strCode: getCountryCode())
        }
        lblCountryCode.text = currentCountry["dial_code"] as? String
        imgFlag.image = UIImage(named: currentCountry["code"] as! String)
    }
    func setupForGuest() {
        isFromGuest = true
    }

    // MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        if isGuest
        {
            let transition:CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromBottom
            self.navigationController?.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.popViewController(animated: false)
        }
       else  if UserType == .Supplier && isNavigateFromEditProfile {
            UserDefaults.standard.removeCustomObject(forKey: kUserDetailsUdf)
            self.navigateToHome()
        } else {
            if UserType == .Supplier {
                UserDefaults.standard.removeCustomObject(forKey: kUserDetailsUdf)
                self.navigateToHome()
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        }
        
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        self.view.endEditing(true)
        if doValidate() {
            sendOTP(strCountryCode: lblCountryCode.text!, mobileNumber: txtPhoneNumber.text!)
        }
    }
    @IBAction func btnCountryCodeClicked(_ sender: Any) {
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "CountryPickerVC") as!  CountryPickerVC
        vc.delegate = self
        vc.currentCountry = currentCountry
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    func navigateToCodeVerification() {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
        vc.countryCode = lblCountryCode.text!
        vc.phoneNumber = txtPhoneNumber.text!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        if(removeWhiteSpaceCharacter(fromText: txtPhoneNumber.text!).count == 0){
            strError = "Please Provide Phone number"
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            ShowToast(message: strError)
            return false
        }
        return true
    }
}

//MARK: - COUNTRY PICKER DELEGATE
extension MobileVerificationVC : CountryPickerVCDelegate {
    func countrySelected(dic: [String : Any]) {
        currentCountry = dic
        lblCountryCode.text = currentCountry["dial_code"] as? String
        imgFlag.image = UIImage(named: currentCountry["code"] as! String)
    }
}
