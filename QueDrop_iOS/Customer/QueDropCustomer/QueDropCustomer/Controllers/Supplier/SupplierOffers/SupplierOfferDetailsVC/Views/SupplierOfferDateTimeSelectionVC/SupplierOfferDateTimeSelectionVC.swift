//
//  DatePickerAlertVC.swift
//  Tournament
//
//  Created by C100-105 on 07/01/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import UIKit

class SupplierOfferDateTimeSelectionVC: BaseAlertViewController {

    @IBOutlet weak var blurrView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewButtonContainer: UIView!
    
    @IBOutlet weak var dtPicker: UIDatePicker!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var strTitle: String? = nil
    var selectedDate: Date? = nil
    var minDate: Date? = nil
    var maxDate: Date? = nil
    
    var callbackForCancel: (() -> ())? = nil
    var callbackForSelectedDate: ((Date) -> ())? = nil
    
    //MARK: - VC life cycle callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewButtonContainer.backgroundColor = .appColor
        dtPicker.minimumDate = minDate
        dtPicker.maximumDate = maxDate
        
        if let selectedDate = selectedDate {
            dtPicker.setDate(selectedDate, animated: true)
        }
        
        setupAlertDismiss(toView: blurrView)
    }
    
    //MARK: - UI Actions callbacks
    @IBAction func btnDoneClick(_ sender: Any) {
        let date = dtPicker.date
        callbackForSelectedDate?(date)
        hideDialog()
    }
    
    @IBAction func btnCancelClick(_ sender: Any) {
        cancelDialog(isHide: false)
    }
    
    override func showView(viewDisplay: UIView, inFrom: UIView.SlideDirection = .RIGHT, isAnimate: Bool = false) {
        super.showView(viewDisplay: viewDisplay, inFrom: inFrom, isAnimate: isAnimate)
        
        lblTitle.text = strTitle
    }
    
    override func dismissView() {
        cancelDialog(isHide: false)
    }
    
    override func hideDialog() {
        cancelDialog(isHide: true)
    }
    
    func cancelDialog(isHide: Bool) {
        view.animation(slideDuration: 0.3, delay: 0, direction: inFrom, slide: .SlideOut)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            if isHide {
                self.dismissCallback?()
            } else {
                self.callbackForCancel?()
            }
            self.view.removeFromSuperview()
        })
    }
    
    
}
