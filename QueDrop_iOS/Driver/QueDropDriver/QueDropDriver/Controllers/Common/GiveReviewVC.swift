//
//  GiveReviewVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 01/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import FloatRatingView
class GiveReviewVC: UIViewController {
    //CONSTANT
       
    //VARIABLES
    var orderId : Int?
    var customerId : Int?
    
    //IBOUTLETS
    @IBOutlet weak var viewDismiss: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var viewRating: FloatRatingView!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    //MARK: - VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismisssVC))
            tapGesture.numberOfTapsRequired = 1
            viewDismiss.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.isOpaque = false
    }
    
    //MARK:- SETUP & INITIALISATION
     func initializations()  {
     }
    
     func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
         
         drawBorder(view: viewContainer, color: .clear, width: 0.0, radius: 8.0)
         drawBorder(view: txtReview, color: .lightGray, width: 1.0, radius: 8.0)
         
         btnCancel.backgroundColor = .clear
         btnCancel.setTitle("CANCEL", for: .normal)
         btnCancel.setTitleColor(.lightGray, for: .normal)
         btnCancel.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
       
        btnSend.backgroundColor = .clear
         btnSend.setTitle("SEND REVIEW", for: .normal)
         btnSend.setTitleColor(THEME_COLOR, for: .normal)
         btnSend.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
         
        lblTitle.text = "Give Feedback"
        lblTitle.textColor = .darkGray
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 20.0))
        
        lblSubTitle.text = "Please write your feedback"
        lblSubTitle.textColor = .lightGray
        lblSubTitle.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        viewRating.minRating = 0
        viewRating.maxRating = 5
        viewRating.type = .halfRatings
        viewRating.rating = 0.0
        
        txtReview.textColor = .gray
        txtReview.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))
        txtReview.tintColor = .gray
     }
    
    //MARK: - BUTTONS ACTION
    @IBAction func btnCancelClicked(_ sender: Any) {
        dismisssVC()
    }
    
    @IBAction func btnSendReviewClicked(_ sender: Any) {
        if txtReview.text.length == 0 && viewRating.rating < 0 {
            ShowToast(message: "Please select rating or write review to submit")
        } else {
            giveReview(toUserId: customerId!, fromUserId: USER_OBJ?.userId ?? 0, rating: Float(viewRating!.rating), review: txtReview.text, orderId: orderId!)
        }
    }
    
    @objc func dismisssVC()  {
        dismiss(animated: true, completion: nil)
    }

}
