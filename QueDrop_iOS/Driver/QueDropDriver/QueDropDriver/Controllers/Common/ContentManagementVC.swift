//
//  ContentManagementVC.swift
//  QueDriver
//
//  Created by C100-174 on 22/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import WebKit

class ContentManagementVC: UIViewController {
    //MARK:- CONSTANTS
    
    //MARK:- VARIABLES
    var forType : CMS_TYPE?
    
    //MARK:- IBOUTLETS
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
     func initializations()  {
         
     }
    
     func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
         var contentURL = ""
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        if forType!.rawValue == CMS_TYPE.TermsCondition.rawValue {
             lblTitle.text = "Terms & Condition"
            contentURL = URL_TERMS_CONDITION
        }else if forType!.rawValue == CMS_TYPE.PrivacyPolicy.rawValue {
             lblTitle.text = "Privacy Policy"
            contentURL = URL_PRIVACY_POLICY
        } else {
            lblTitle.text = ""
        }
        webView.load(URLRequest(url: URL(string: contentURL)!))
     }
     
    // MARK: - BUTTONS ACTIONS
    @IBAction func btnCloseClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
