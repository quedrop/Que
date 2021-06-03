//
//  SignUpVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SafariServices

class SignUpVC: BaseViewController, UITextFieldDelegate {

    //CONSTANTS
    
    //VARIABLES
    var fname = ""
    var lname = ""
    var email = ""
    var pwd = ""
    var rCode = ""
    
    var isChecked : Bool = false {
        didSet {
            let cell = tblForm.cellForRow(at: IndexPath(row: 5, section: 0)) as! termAndConditionTVC
            if isChecked {
                cell.btnCheckBox.setImage(UIImage(named: "Checkbox_Checked"), for: .normal)
                cell.btnCheckBox.setBackgroundImage(UIImage(named: "gradient_bg"), for: .normal)
            } else {
                cell.btnCheckBox.setImage(UIImage(), for: .normal)
                cell.btnCheckBox.setBackgroundImage(UIImage(),for: .normal)
            }
        }
    }
    
    var isPwdEyedisable : Bool = true {
        didSet {
            let cell = tblForm.cellForRow(at: IndexPath(row: 2, section: 0)) as! CommonTextFieldTVC
            if isPwdEyedisable {
                cell.textField.isSecureTextEntry = false
                cell.btnAction.setImage(UIImage(named: "eye_enabled"), for: .normal)
            } else {
                cell.textField.isSecureTextEntry = true
                cell.btnAction.setImage(UIImage(named: "eye_disabled"), for: .normal)
            }
        }
    }
    
    var isCPwdEyedisable : Bool = true {
        didSet {
            let cell = tblForm.cellForRow(at: IndexPath(row: 3, section: 0)) as! CommonTextFieldTVC
            if isCPwdEyedisable {
                cell.textField.isSecureTextEntry = false
                cell.btnAction.setImage(UIImage(named: "eye_enabled"), for: .normal)
            } else {
                cell.textField.isSecureTextEntry = true
                cell.btnAction.setImage(UIImage(named: "eye_disabled"), for: .normal)
            }
        }
    }
    var imagePicker = UIImagePickerController()
    var isImageSelected : Bool = false
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNext: UIButton!
     @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblForm: UITableView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var btnAddUserPic: UIButton!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var viewTableHeader: UIView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		initializations()
		
		getCurrenLocationDetails()
        setupGUI()
    }
        
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        currScreen = .signUp
        tblForm.register("MultiTextFieldTVC")
        tblForm.register("CommonTextFieldTVC")
        tblForm.register("termAndConditionTVC")
    }
    
    func setupGUI() {
        tblForm.tableHeaderView = nil
        tblForm.tableHeaderView = viewTableHeader
        
        lblTitle.text = "Sign Up"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
    
        btnNext.backgroundColor = THEME_COLOR
        btnNext.setTitle("Next", for: .normal)
        btnNext.setTitleColor(.white, for: .normal)
        btnNext.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        
        makeCircular(view: imgUser)
    }
    

    // MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        self.view.endEditing(true)
        if doValidate() {
            if(isChecked) {
                doRegistration(fname: fname, lname: lname, password: pwd, referral_code: rCode, email: email)
            } else {
                ShowToast(message: "Please agree with our terms and conditions.")
            }
        }
    }
    
    @objc func checkBoxChecked(sender : UIButton) {
        isChecked = !isChecked
    }
    
    @objc func isPassWordEnableDisable(sender : UIButton) {
        isPwdEyedisable = !isPwdEyedisable
    }
    
    @objc func isConfirmPwdEnableDisable(sender : UIButton) {
        isCPwdEyedisable = !isCPwdEyedisable
    }
    
    @objc func PasteClicked(sender : UIButton) {
        let cell = tblForm.cellForRow(at: IndexPath(row: 4, section: 0)) as! CommonTextFieldTVC
        let pb: UIPasteboard = UIPasteboard.general;
        cell.textField.text = pb.string
        if cell.textField.text!.count > 0 {
            //CALL API FOR CHECKING VALIDITY OF REFERRAL CODE
            checkReferralCodeValidity(referralCode: cell.textField.text!)
        }
    }
    @IBAction func btnAddUserPicCliecked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Select Photo Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func openGallery()  {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        let firstCell = tblForm.cellForRow(at: IndexPath(row: 0, section: 0)) as! MultiTextFieldTVC
        let emailCell = tblForm.cellForRow(at: IndexPath(row: 1, section: 0)) as! CommonTextFieldTVC
        let pwdCell = tblForm.cellForRow(at: IndexPath(row: 2, section: 0)) as! CommonTextFieldTVC
        let cPwdCell = tblForm.cellForRow(at: IndexPath(row: 3, section: 0)) as! CommonTextFieldTVC
        let codeCell = tblForm.cellForRow(at: IndexPath(row: 4, section: 0)) as! CommonTextFieldTVC
        
        fname = firstCell.txtFirstName.text!
        lname = firstCell.txtLastName.text!
        email = emailCell.textField.text!
        pwd = pwdCell.textField.text!
        rCode = codeCell.textField.text!
        
        if(cPwdCell.textField.text != pwdCell.textField.text){
             strError = "Password and Confirm Password must be same"
        }
        if(cPwdCell.textField.text?.count == 0){
             strError = "Please enter confirm password"
        }
         /*if((pwdCell.textField.text?.count)! > 0 && !utils.validatePassword(pwd: txtPwd.text!)){
             strError = "Minimum password length 7 characters & must contain one uppercase, lowercase & number"
         }*/
        if(pwdCell.textField.text?.count == 0){
             strError = "Please enter password"
        }
		if(removeWhiteSpaceCharacter(fromText: emailCell.textField.text!).count > 0 &&  !(emailCell.textField.text?.isEmail ?? false)){
             strError = "Please Provide Proper Email id"
        }
        if(removeWhiteSpaceCharacter(fromText: emailCell.textField.text!).count == 0){
             strError = "Please Provide Email Id"
        }
        if(removeWhiteSpaceCharacter(fromText: firstCell.txtLastName.text!).count == 0){
             strError = "Please Provide last name"
         }
        if(removeWhiteSpaceCharacter(fromText: firstCell.txtFirstName.text!).count == 0){
            strError = "Please Provide first name"
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            ShowToast(message: strError)
            return false
        }
        return true
    }
    
    //MARK:- UITEXTFIELD DELEGATE METHODS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let codeCell = tblForm.cellForRow(at: IndexPath(row: 4, section: 0)) as! CommonTextFieldTVC
        if textField == codeCell.textField {
            let str = (textField.text! + string)
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if str.count <= 8 || isBackSpace == -92 {
                return true
            }
            textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 8))
            return false
        }
        return true
    }
    
    @objc func referralCodeValueChanged(textField : UITextField) {
        if textField.text!.count == 8 {
            //CALL API FOR CHECKING VALIDITY OF REFERRAL CODE
            checkReferralCodeValidity(referralCode: textField.text!)
        }
    }
    
}

extension SignUpVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case SignUpFields.name.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MultiTextFieldTVC",for: indexPath) as! MultiTextFieldTVC
                return cell
                
        case SignUpFields.email.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
                //cell.lblTitle.text = "Email"
                cell.textField.placeholder = "Email"
                //cell.textField.setRightPadding(10)
                cell.textField.keyboardType = .emailAddress
                cell.textField.isSecureTextEntry = false
                cell.btnAction.isHidden = true
                return cell
                
            case SignUpFields.password.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
                //cell.lblTitle.text = "Password"
                cell.textField.placeholder = "Password"
                //cell.textField.setRightPadding(70)
                cell.textField.isSecureTextEntry = true
                cell.btnAction.isHidden = false
                cell.btnAction.tag = indexPath.row
                cell.btnAction.setImage(#imageLiteral(resourceName: "eye_disabled"), for: .normal)
                cell.btnAction.addTarget(self, action: #selector(isPassWordEnableDisable(sender:)), for: .touchUpInside)
                return cell
            
            case SignUpFields.confirmPassword.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
                //cell.lblTitle.text = "Confirm Password"
                cell.textField.placeholder = "Confirm Password"
               // cell.textField.setRightPadding(70)
                cell.textField.isSecureTextEntry = true
                cell.btnAction.isHidden = false
                cell.btnAction.tag = indexPath.row
                cell.btnAction.setImage(#imageLiteral(resourceName: "eye_disabled"), for: .normal)
                cell.btnAction.addTarget(self, action: #selector(isConfirmPwdEnableDisable(sender:)), for: .touchUpInside)
                return cell
            
            case SignUpFields.referralCode.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTextFieldTVC",for: indexPath) as! CommonTextFieldTVC
                //cell.lblTitle.text = "Add Referral Code (Optional)"
                cell.textField.placeholder = "Referral Code (Optional)"
                cell.textField.isSecureTextEntry = false
                //cell.textField.setRightPadding(10)
                cell.btnAction.isHidden = false
                cell.btnAction.tag = indexPath.row
                cell.btnAction.setImage(UIImage(named: "copy_document"), for: .normal)
                cell.btnAction.addTarget(self, action: #selector(PasteClicked(sender:)), for: .touchUpInside)
                cell.textField.addTarget(self, action: #selector(referralCodeValueChanged(textField:)), for: .editingChanged)
                cell.textField.delegate = self
                return cell
            
            case SignUpFields.termAndConditions.rawValue:
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
}

//MARK: - TTTATTRIBUTEDLABEL DELEGATE
extension SignUpVC : TTTAttributedLabelDelegate {
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


extension SignUpVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            isImageSelected = true
            imgUser.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
       
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    
    }
   
}
