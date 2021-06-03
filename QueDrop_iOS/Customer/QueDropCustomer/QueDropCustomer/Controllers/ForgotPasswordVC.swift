//
//  ForgotPasswordVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ForgotPasswordVC: BaseViewController{
    //CONSTANTS
    
    //VARIABLES
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtEmail: JVFloatLabeledTextField!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupGUI()
    }
        
    //MARK:- SETUP & INITIALISATION
    func setupGUI() {
        lblTitle.text = "Forgot Password"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        lblInfo.textColor = .gray
        lblInfo.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))
        
        txtEmail.textColor = .black
        txtEmail.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.5))
        txtEmail.tintColor = txtEmail.textColor
        //txtEmail.setLeftRightPadding(10)
        txtEmail.addBottomLine()
        setupFloatingTextField(textField: txtEmail)
        
        btnSend.backgroundColor = THEME_COLOR
        btnSend.setTitle("Send", for: .normal)
        btnSend.setTitleColor(.white, for: .normal)
        btnSend.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
    }
    

    // MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSendClicked(_ sender: Any) {
        self.view.endEditing(true)
        if doValidate() {
            forgotPassword()
        }
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
		if(removeWhiteSpaceCharacter(fromText: txtEmail.text!).count > 0 && !(txtEmail.text?.isEmail ?? false)){
            strError = "Please Provide Proper Email id"
        }
        if(removeWhiteSpaceCharacter(fromText: txtEmail.text!).count == 0){
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
