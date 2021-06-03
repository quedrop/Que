//
//  ReferralVC.swift
//  QueDrop
//
//  Created by C205 on 13/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ReferralVC: UIViewController {

    @IBOutlet weak var lblReferralCode: UILabel!
    @IBOutlet weak var lblReferMessage: UILabel!
    @IBOutlet weak var btnInvite: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblReferralCode.text =  USER_OBJ?.refferalCode ?? ""
    }


    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionInvite(_ sender: Any) {
         if (USER_OBJ?.refferalCode!.count)! > 0 {
            let firstActivityItem = "GOFER Delivery : Use my referral code and get reward\n Referral Code : \(USER_OBJ?.refferalCode ?? "")"
            
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
