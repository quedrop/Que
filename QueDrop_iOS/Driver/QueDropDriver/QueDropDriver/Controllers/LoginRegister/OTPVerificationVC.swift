//
//  OTPVerificationVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class OTPVerificationVC: BaseViewController{
    //CONSTANTS
    
    //VARIABLES
    var phoneNumber = String()
    var countryCode = String()
    var isNavigateFromEditProfile = false
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: TTTAttributedLabel!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet var textCodeDigit1: UITextField!
    @IBOutlet var textCodeDigit2: UITextField!
    @IBOutlet var textCodeDigit3: UITextField!
    @IBOutlet var textCodeDigit4: UITextField!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
    //MARK: - VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initialisation()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func initialisation()  {
        textCodeDigit1.delegate = self
        textCodeDigit2.delegate = self
        textCodeDigit3.delegate = self
        textCodeDigit4.delegate = self
    }
    
    func setupGUI() {
        setupLinkLabels()
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Verification Code"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
    
        lblInfo.textColor = .lightGray
        lblInfo.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))
        
        btnVerify.backgroundColor = THEME_COLOR
        btnVerify.setTitle("Verify Code", for: .normal)
        btnVerify.setTitleColor(.white, for: .normal)
        btnVerify.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        
        setEmptyField(textField: textCodeDigit1)
        setEmptyField(textField: textCodeDigit2)
        setEmptyField(textField: textCodeDigit3)
        setEmptyField(textField: textCodeDigit4)
        
        textCodeDigit1.becomeFirstResponder()
    }
    
    func setOTP(textField : UITextField , text : String) {
        textField.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        textField.text = text
        textField.textColor = .white
        textField.backgroundColor = THEME_COLOR
        textField.tintColor = THEME_COLOR
    }
    
    func setEmptyField(textField : UITextField) {
       textField.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
       textField.text = "-"
       textField.textColor = .black
       textField.backgroundColor = .clear
        textField.tintColor = THEME_COLOR
    }

    func setupLinkLabels()  {
        let strInfo = "Waiting for automatically detect and SMS sent to \(countryCode) \(phoneNumber) Wrong number?" as NSString
        lblInfo.text = strInfo
        lblInfo.numberOfLines = 0;
        
        let fullAttributedString = NSAttributedString(string:strInfo as String, attributes: [
            NSAttributedString.Key.foregroundColor: THEME_COLOR,
            NSAttributedString.Key.font : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0)) as Any
            ])
        lblInfo.textAlignment = .center
        lblInfo.attributedText = fullAttributedString;
        
        let rangeTC = strInfo.range(of: "Wrong number?")
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.orange.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0)) as Any
            ]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.orange.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0)) as Any
            ]
        
        lblInfo.activeLinkAttributes = ppActiveLinkAttributes
        lblInfo.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://WN")!
        lblInfo.addLink(to: urlTC, with: rangeTC)
        
        lblInfo.textColor = UIColor.black;
        lblInfo.delegate = self;
    }
    
    // MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnVerifyClicked(_ sender: Any) {
        self.view.endEditing(true)
        if doValidate() {
            let strCode = "\(textCodeDigit1.text!)\(textCodeDigit2.text!)\(textCodeDigit3.text!)\(textCodeDigit4.text!)"
            verifyOTP(strCountryCode: countryCode, mobileNumber: phoneNumber, strCode: strCode)
        }
    }
    
    func navigateToDriverIdentityScreen() {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "UpdateDriverIdentityDetailVC") as!  UpdateDriverIdentityDetailVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        if(textCodeDigit4.text == "-" || textCodeDigit4.text?.length == 0
            || textCodeDigit3.text == "-" || textCodeDigit3.text?.length == 0 || textCodeDigit2.text == "-" || textCodeDigit2.text?.length == 0 || textCodeDigit1.text == "-" || textCodeDigit1.text?.length == 0){
            strError = "Please Provide Proper OTP"
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            ShowToast(message: strError)
            return false
        }
        return true
    }
}

//MARK: - UITEXTFIELD DELEGATE
extension OTPVerificationVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if textField.text!.count < 2  && string.count > 0{
            let nextTag = textField.tag + 1

            // get next responder
            var nextResponder = textField.superview?.viewWithTag(nextTag)

            if (nextResponder == nil){

                nextResponder = textField.superview?.viewWithTag(1)
            }
            setOTP(textField: textField, text: string)
            nextResponder?.becomeFirstResponder()
            return false
        }
        else if textField.text!.count >= 1  && string.count == 0{
            // on deleting value from Textfield
            let previousTag = textField.tag - 1

            // get next responder
            var previousResponder = textField.superview?.viewWithTag(previousTag)

            if (previousResponder == nil){
                previousResponder = textField.superview?.viewWithTag(1)
            }
           setEmptyField(textField: textField)
            previousResponder?.becomeFirstResponder()
            return false
        }
        return true
        
    }
}

//MARK: - TTTATTRIBUTEDLABEL DELEGATE
extension OTPVerificationVC : TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "action://WN" {
            navigationController?.popViewController(animated: true)
        }
    }
}
