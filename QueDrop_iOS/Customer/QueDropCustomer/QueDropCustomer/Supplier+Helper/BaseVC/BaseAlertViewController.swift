//
//  BaseAlertViewController.swift
//  Tournament
//
//  Created by C100-105 on 07/01/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import UIKit

class BaseAlertViewController: SupplierBaseViewController {

    //MARK: - Variables
    //for alert dissmiss callback
    var dismissCallback: (() -> ())? = nil
    var inFrom = UIView.SlideDirection.RIGHT
    let showViewTimeInterval: Double = 0.35
    var isAnimate = false
    
    //MARK: - VC life cycle callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupAlertDismiss(toView view: UIView) {
        view.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissView() {
        hideDialog()
    }
    
    //MARK: - Show View
    func showView(viewDisplay: UIView, inFrom: UIView.SlideDirection = .RIGHT, isAnimate: Bool = false) {
        self.inFrom = inFrom
        self.isAnimate = isAnimate
        
        self.view.backgroundColor = .clear
        self.view.frame = viewDisplay.frame
        
        if isAnimate {
            self.view.animation(slideDuration: showViewTimeInterval, delay: 0, direction: inFrom, slide: .SlideIn)
        }
        
        viewDisplay.addSubview(view)
        view.center = viewDisplay.center
        
        view.layoutIfNeeded()
        viewDisplay.layoutIfNeeded()
    }
    
    //MARK: - Hide View
    func hideDialog() {
        if isAnimate {
            view.animation(slideDuration: 0.3, delay: 0, direction: inFrom, slide: .SlideOut)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (isAnimate ? 0.25 : 0), execute: {
            self.dismissCallback?()
            self.view.removeFromSuperview()
        })
    }

}

