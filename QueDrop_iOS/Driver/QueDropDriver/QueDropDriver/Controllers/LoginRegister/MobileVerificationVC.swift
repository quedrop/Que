//
//  MobileVerificationVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class MobileVerificationVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    var currentCountry = [String : Any]()
    var isFromLaunch : Bool = false
    var isNavigateFromEditProfile = false
    
    //IBOUTLETS
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var lblTitlPhoneNumber: UILabel!
    @IBOutlet weak var btnCountry: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var imgFlag: UIImageView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
    
    //MARK: - VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func setupGUI() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Phone Number"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        lblCountryCode.text = "+44"
        lblCountryCode.textColor = .black
        lblCountryCode.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 18.0))
        scaleFont(byWidth: lblCountryCode)
        
        lblInfo.textColor = .lightGray
        lblInfo.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))
        
        lblTitlPhoneNumber.textColor = .blue
        lblTitlPhoneNumber.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))
        
        txtPhoneNumber.textColor = .black
        txtPhoneNumber.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 18.0))
        txtPhoneNumber.setLeftPadding(108.0)
        txtPhoneNumber.tintColor = txtPhoneNumber.textColor
        txtPhoneNumber.placeholder = "Phone number"
        txtPhoneNumber.text = USER_OBJ?.phoneNumber
        txtPhoneNumber.addBottomLine()
        
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
        
        if isFromLaunch {
            btnBack.setImage(setImageTintColor(image: UIImage(named: "home"), color: .white), for: .normal)
        } else {
            btnBack.setImage(UIImage(named: "left_arrow"), for: .normal)
        }
    }
    

    // MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        if isFromLaunch/* || isNavigateFromEditProfile*/{
            callLogoutAPI()
        } else {
             navigationController?.popViewController(animated: true)
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
        vc.isNavigateFromEditProfile = isNavigateFromEditProfile
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
