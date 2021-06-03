//
//  CodeVerificationVC.swift
//  QueDrop
//
//  Created by C100-104 on 29/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import OTPFieldView

class OTPVerificationVC: BaseViewController{
    //CONSTANTS
    
    //VARIABLES
    var phoneNumber = String()
    var countryCode = String()
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: TTTAttributedLabel!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet var textCodeDigit1: UITextField!
    @IBOutlet var textCodeDigit2: UITextField!
    @IBOutlet var textCodeDigit3: UITextField!
    @IBOutlet var textCodeDigit4: UITextField!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var otpTextFieldView: OTPFieldView!
    var hasCodeFilled = false
    var code = ""
    
    //MARK: - VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
      //  initialisation()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func initialisation()  {
        textCodeDigit1.delegate = self
        textCodeDigit2.delegate = self
        textCodeDigit3.delegate = self
        textCodeDigit4.delegate = self
       
    }
    func setUpTextField()
    {
        self.otpTextFieldView.fieldsCount = 4
        self.otpTextFieldView.fieldBorderWidth = 0.5
        self.otpTextFieldView.defaultBorderColor = UIColor.lightGray
        self.otpTextFieldView.filledBorderColor = THEME_COLOR
        self.otpTextFieldView.cursorColor = THEME_COLOR
        self.otpTextFieldView.fieldFont =  UIFont(name: fFONT_MEDIUM, size: 30.0)!
        self.otpTextFieldView.displayType = .roundedCorner
        self.otpTextFieldView.fieldSize = 58
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.defaultBackgroundColor = .white
        self.otpTextFieldView.filledBackgroundColor = THEME_COLOR
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
    func setupGUI() {
        setupLinkLabels()
        lblTitle.text = "Verification Code"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
    
        lblInfo.textColor = .lightGray
        lblInfo.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        
        btnVerify.backgroundColor = THEME_COLOR
        btnVerify.setTitle("Verify Code", for: .normal)
        btnVerify.setTitleColor(.white, for: .normal)
        btnVerify.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
            /*
        setEmptyField(textField: textCodeDigit1)
        setEmptyField(textField: textCodeDigit2)
        setEmptyField(textField: textCodeDigit3)
        setEmptyField(textField: textCodeDigit4)
        
        textCodeDigit1.becomeFirstResponder()*/
         setUpTextField()
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
       textField.textColor = .white
       textField.backgroundColor = .clear
        textField.tintColor = THEME_COLOR
    }

    func setupLinkLabels()  {
        let strInfo = "Waiting for automatically detect and SMS sent to \(countryCode) \(phoneNumber) Wrong number?" as NSString
        lblInfo.text = strInfo
        lblInfo.numberOfLines = 0;
        
        let fullAttributedString = NSAttributedString(string:strInfo as String, attributes: [
            NSAttributedString.Key.foregroundColor: THEME_COLOR,
            NSAttributedString.Key.font : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
            ])
        lblInfo.textAlignment = .center
        lblInfo.attributedText = fullAttributedString;
        
        let rangeTC = strInfo.range(of: "Wrong number?")
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.orange.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
            ]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.orange.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
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
        if hasCodeFilled{
            verifyOTP(strCountryCode: countryCode, mobileNumber: phoneNumber, strCode: code)
        }else
        {
            ShowToast(message: "Please Provide Proper OTP")
        }
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
extension OTPVerificationVC : OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
           print("Has entered all OTP? \(hasEntered)")
        hasCodeFilled = hasEntered
           return false
       }
       
       func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
           return true
       }
       
       func enteredOTP(otp otpString: String) {
           print("OTPString: \(otpString)")
        self.code = otpString
        verifyOTP(strCountryCode: countryCode, mobileNumber: phoneNumber, strCode: otpString)
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
