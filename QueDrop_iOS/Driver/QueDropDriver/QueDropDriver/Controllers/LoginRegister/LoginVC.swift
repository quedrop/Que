//
//  LoginVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 29/02/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleSignIn
import UIKit
import TTTAttributedLabel
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import JVFloatLabeledTextField

class LoginVC: BaseViewController, TTTAttributedLabelDelegate {
    //CONSTANT
    
    //VARIABLES
    var isEyedisable : Bool = true {
        didSet {
            if isEyedisable {
                txtPassword.isSecureTextEntry = false
                btnShowPassword.setImage(UIImage(named: "eye_enabled"), for: .normal)
            } else {
                txtPassword.isSecureTextEntry = true
                btnShowPassword.setImage(UIImage(named: "eye_disabled"), for: .normal)
            }
        }
    }
    var isRememberMe : Bool = false {
        didSet {
            if isRememberMe {
                btnCheckbox.setImage(UIImage(named: "Checkbox_Checked"), for: .normal)
                btnCheckbox.setBackgroundImage(UIImage(named: "gradient_bg"), for: .normal)
            } else {
                btnCheckbox.setImage(UIImage(), for: .normal)
                btnCheckbox.setBackgroundImage(UIImage(),for: .normal)
            }
        }
    }
    
    //IBOUTLETS
    @IBOutlet var txtEmail: JVFloatLabeledTextField!
    @IBOutlet var txtPassword: JVFloatLabeledTextField!
    
    @IBOutlet var btnShowPassword: UIButton!
    @IBOutlet var btnGoogleLogin: UIButton!
    @IBOutlet var btnFacebookLogin: UIButton!
    @IBOutlet var btnCheckbox: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnRegistration: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitleEmail: UILabel!
    @IBOutlet weak var lblTitlePwd: UILabel!
    @IBOutlet weak var lblRememberMe: UILabel!
    @IBOutlet weak var lblOR: UILabel!
    
    @IBOutlet weak var lblTerms: TTTAttributedLabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewOR: UIView!
    
    @IBOutlet weak var viewContainerAppleLogin: UIStackView!
    
    var emailId = ""
    var password = ""
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGUI()
        if #available(iOS 13.0, *) {
           setupProviderLoginView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*if #available(iOS 13.0, *) {
            performExistingAccountSetupFlows()
        }*/
    }
    
    //MARK:- SETUP & INITIALISATION
    func setupGUI() {
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        setupLinkLabels()
        isEyedisable = false
        isRememberMe = false
        
        lblTitle.text = "Login"
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 22))
        
        
       txtEmail.textColor = .darkGray
        txtEmail.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.5))
        txtEmail.placeholder = "Email"
        txtPassword.textColor = txtEmail.textColor
        txtPassword.font = txtEmail.font
        txtPassword.placeholder = "Password"
        
        txtEmail.tintColor = txtEmail.tintColor
        txtPassword.tintColor = txtEmail.tintColor
        
        setupFloatingTextField(textField: txtEmail)
        setupFloatingTextField(textField: txtPassword)
        
        txtPassword.setRightPadding(60)
        txtEmail.addBottomLine()
        txtPassword.addBottomLine()
        
        btnLogin.backgroundColor = THEME_COLOR
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        
        lblRememberMe.text = "Remember Me"
        lblRememberMe.textColor = .darkGray
        lblRememberMe.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.0))
        
        btnForgotPassword.setTitle("Forgot Password?", for: .normal)
        btnForgotPassword.setTitleColor(.darkGray, for: .normal)
        btnForgotPassword.titleLabel?.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 14.0))
        
        drawBorder(view: btnCheckbox, color: .gray, width: 1.0, radius: 2.0)
        
        lblOR.text = "OR    "
        lblOR.textColor = .gray
        lblOR.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 15.0))
        lblOR.backgroundColor = VIEW_BACKGROUND_COLOR
        
        viewOR.gradientBackground(ColorSet: [UIColor.clear.cgColor, UIColor.lightGray.withAlphaComponent(0.5).cgColor, UIColor.lightGray.cgColor, UIColor.lightGray.cgColor, UIColor.lightGray.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor], direction: .leftToRight)
        
        let r1 = NSMutableAttributedString(string: "Don't have an Account? ")
        let r2 = NSMutableAttributedString(string: "Register")
        
        r1.addAttribute(.foregroundColor, value: THEME_COLOR, range: NSMakeRange(0, r1.length))
        r1.addAttribute(.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))!, range: NSMakeRange(0, r1.length))
        
        r2.addAttribute(.foregroundColor, value: THEME_COLOR, range: NSMakeRange(0, r2.length))
        r2.addAttribute(.font, value: UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 16.0))!, range: NSMakeRange(0, r2.length))
        
        r1.append(r2)
        
        btnRegistration.setAttributedTitle(r1, for: .normal)
        
        if getIsRememberMe() {
            txtEmail.text = getEmail()
            txtPassword.text = getPassword()
            isRememberMe = getIsRememberMe()
        }
        
    }
    
    func setupLinkLabels()  {
        let strAgreement = "By Continuing, you agree to our\n terms of use and privacy policy" as NSString
        lblTerms.text = strAgreement
        lblTerms.numberOfLines = 0;
        
        let fullAttributedString = NSAttributedString(string:strAgreement as String, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0)) as Any
        ])
        lblTerms.textAlignment = .center
        lblTerms.attributedText = fullAttributedString;
        
        let rangeTC = strAgreement.range(of: "terms of use")
        let rangePP = strAgreement.range(of: "privacy policy")
        
        let ppLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: THEME_COLOR.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0)) as Any
        ]
        let ppActiveLinkAttributes: [String: Any] = [
            NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
            NSAttributedString.Key.underlineStyle.rawValue: false,
            NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
        ]
        
        lblTerms.activeLinkAttributes = ppActiveLinkAttributes
        lblTerms.linkAttributes = ppLinkAttributes
        
        let urlTC = URL(string: "action://TC")!
        let urlPP = URL(string: "action://PP")!
        lblTerms.addLink(to: urlTC, with: rangeTC)
        lblTerms.addLink(to: urlPP, with: rangePP)
        
        lblTerms.textColor = UIColor.black;
        lblTerms.delegate = self;
    }
    //MARK:- SETUP APPLE LOGIN AND ITS FEATURE
    /// - Tag: add_appleid_button
    @available(iOS 13.0, *)
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.viewContainerAppleLogin.addArrangedSubview(authorizationButton)
      }
      /// - Tag: perform_appleid_request
    @available(iOS 13.0, *)
    @objc
      func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
      }
    // - Tag: perform_appleid_password_request
      /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                ASAuthorizationPasswordProvider().createRequest()]
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
      }
    //MARK:- BUTTON ACTIONS
    @IBAction func btnForgotPwdClicked(_ sender: Any) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCheckboxClicked(_ sender: Any) {
        isRememberMe = !isRememberMe
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        self.view.endEditing(true)
        if doValidate() {
            doLogin()
        }
    }
    
    @IBAction func btnFacebookClicked(_ sender: Any) {
        facebooklogin()
    }
    
    @IBAction func btnGoogleClicked(_ sender: Any) {
        if isNetworkConnected {
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.presentingViewController.modalPresentationStyle = .overFullScreen
            GIDSignIn.sharedInstance()?.signIn()
        }else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    
    @IBAction func btnRegistrationClciked(_ sender: Any) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEyeClciked(_ sender: Any) {
        isEyedisable = !isEyedisable
    }
    //MARK:- FACEBOOK LOGIN
    func facebooklogin() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self, handler: { (result, error) -> Void in
            print("\n\n result: \(result)")
            print("\n\n Error: \(error)")
            
            if (error == nil) {
                let fbloginresult : LoginManagerLoginResult = result!
                if(fbloginresult.isCancelled) {
                    //Show Cancel alert
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    self.returnUserData()
                    //fbLoginManager.logOut()
                }
            }
        })
    }
    func returnUserData() {
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id,email,first_name,last_name,picture"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                print("\n\n Error: \(error)")
            } else {
                let resultDic = result as! NSDictionary
                print("\n\n  fetched user: \(result)")
                var userId = ""
                var fName = ""
                var lName = ""
                var imageUrl = ""
                var email = ""
                if (resultDic.value(forKey:"id") != nil) {
                    let id = resultDic.value(forKey:"id")! as? String
                    userId = id ?? ""
                    print("\n User Id is: \(id)")
                }
                if (resultDic.value(forKey:"first_name") != nil) {
                    let firstName = resultDic.value(forKey:"first_name")! as? String
                    fName = firstName ?? ""
                    print("\n User First Name is: \(firstName)")
                }
                if (resultDic.value(forKey:"last_name") != nil) {
                    let lastName = resultDic.value(forKey:"last_name")! as? String
                    lName = lastName ?? ""
                    print("\n User Last Name is: \(lastName)")
                }
                if let picture = resultDic.value(forKey:"picture") as? NSDictionary
                {
                    if let data = picture["data"] as? NSDictionary
                    {
                        if let imgUrl = data["url"] as? String
                        {
                            imageUrl = imgUrl
                            print("\n User Profile Image is: \(imgUrl)")
                        }
                    }
                }
                if (resultDic.value(forKey:"email") != nil) {
                    let userEmail = resultDic.value(forKey:"email")! as? String
                    email = userEmail ?? ""
                    print("\n User Email is: \(userEmail)")
                }
                self.checkAccountAvailability(loginType: "Facebook", userSocialId: userId, firstName: fName, lastName: lName, email: email, profilePic_url: imageUrl)
                /*let vc = LoginStoryboard.instantiateViewController(withIdentifier: "AdditionalDetailsVC") as! AdditionalDetailsVC
                 vc.SetDetails(loginType: "Facebook", userSocialId: userId, firstName: fName, lastName: lName, email: email, profilePic_url: imageUrl)
                 self.navigationController?.pushViewController(vc, animated: true)
                 */
                
            }
        })
    }
    //MARK: - TTTAttributedLabel DELEGATE METHOD
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "ContentManagementVC") as! ContentManagementVC
        if url.absoluteString == "action://TC" {
            print("TC")
            vc.forType = CMS_TYPE.TermsCondition
        }else if url.absoluteString == "action://PP" {
            print("TC")
            vc.forType = CMS_TYPE.PrivacyPolicy
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        if(txtPassword.text?.count == 0){
            strError = "Please enter password"
        }
        if(removeWhiteSpaceCharacter(fromText: txtEmail.text!).count > 0 && !(txtEmail.text?.isEmail ?? false) ){
            strError = "Please Provide Proper Email id"
        }
        if(removeWhiteSpaceCharacter(fromText: txtEmail.text!).count == 0){
            strError = "Please Provide Email Id"
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            //print(strError)
            ShowToast(message: strError)
            return false
        }
        emailId = txtEmail.text ?? ""
        password = txtPassword.text ?? ""
        return true
    }
    
}

//MARK:- GOOGLE LOGIN DELEGATE
extension LoginVC : GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        // Perform any operations on signed in user here.
        if let user = user{
            let userSocialId = user.userID  ?? ""                 // For client-side use only!
            let firstName = user.profile.givenName ?? ""
            let lastName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            let profilePic_url = user.profile.imageURL(withDimension: 0)?.absoluteString ?? ""
            print("userSocialId : ",userSocialId)
            print("fistName : ",firstName)
            print("lastName : ",lastName)
            print("email : ",email)
            print("profilePic_url : ",profilePic_url)
            
            checkAccountAvailability(loginType: "Google", userSocialId: userSocialId, firstName: firstName, lastName: lastName, email: email, profilePic_url: profilePic_url)
            /*let vc = LoginStoryboard.instantiateViewController(withIdentifier: "AdditionalDetailsVC") as! AdditionalDetailsVC
             vc.SetDetails(loginType: "Google", userSocialId: userSocialId, firstName: fistName, lastName: lastName, email: email, profilePic_url: profilePic_url)
             self.navigationController?.pushViewController(vc, animated: true)*/
        }// ...
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
}


//MARK:- APPLE LOGIN DELEGATE METHODS
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
        default:
            break
        }
    }
    private func saveUserInKeychain(_ userIdentifier: String) {
//        do {
//            // try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
//        } catch {
//            print("Unable to save userIdentifier to keychain.")
//        }
    }
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        print("UserId :",userIdentifier)
        print("FirstName :",fullName?.givenName ?? "")
        print("LastName :",fullName?.familyName ?? "")
        print("Email :",userIdentifier)
       
        var fName = ""
        var lName = ""
        var emailId = ""
        
        if let givenName = fullName?.givenName {
            fName = givenName
        }
        if let familyName = fullName?.familyName {
            lName = familyName
        }
        if let email = email {
            emailId = email
        }
        self.checkAccountAvailability(loginType: "Apple", userSocialId: userIdentifier, firstName: fName, lastName: lName, email: emailId, profilePic_url: "")
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}






