//
//  MyReferralCodeVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 14/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class MyReferralCodeVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    
    //IBOUTLETS
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRef: UILabel!
    @IBOutlet weak var lblRefNote: UILabel!
    
    //MARK:- VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        allNotificationCenterObservers()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        
    }
    
    func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
        view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "My Refferal Code"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        lblRef.text = "Refferals".uppercased()
        lblRef.textColor = .black
        lblRef.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 22.0))
        
        lblRefNote.text = "Refer a friend & we'll give\n you & your buddy \(Currency)10 on\n your weekly payment"
        lblRefNote.textColor = .lightGray
        lblRefNote.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 18.0))
        
        btnInvite.backgroundColor = THEME_COLOR
        btnInvite.setTitle("Invite Friends", for: .normal)
        btnInvite.setTitleColor(.white, for: .normal)
        btnInvite.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        drawBorder(view: btnInvite, color: .clear, width: 0.0, radius: 8.0)
        
    }
    
    func allNotificationCenterObservers() {
        
        
    }
    
    //MARK: - BUTTON ACTIOn
    @IBAction func btnBackClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnInviteClick(_ sender: Any) {
        
        if (USER_OBJ?.refferalCode!.count)! > 0 {
            var AppName = "QueDrop Driver"
            if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                AppName = displayName
            }
            
            let firstActivityItem = "\(AppName) : Use my referral code and get reward\n Referral Code : \(USER_OBJ?.refferalCode ?? "")"
            
            let activityViewController : UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)
            
            // This lines is for the popover you need to show in iPad
            activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
            
            // This line remove the arrow of the popover to show in iPad
            activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            
            // Anything you want to exclude
            activityViewController.excludedActivityTypes = [
                .postToWeibo,
                .print,
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo
            ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }else {
            ShowToast(message: "Referral Code Not Found")
        }
    }
}
