//
//  SupplierTabBarController.swift
//  QueDrop
//
//  Created by C100-104 on 09/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    //MARK: Variables
    var previousController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setupUI()
        
        if let _ = USER_OBJ {
//            APP_DELEGATE.socketIOHandler?.disconnectSocket()
//            APP_DELEGATE.socketIOHandler = SocketIOHandler()
            APP_DELEGATE.socketIOHandler?.callFunctionsAfterConnection()
        }
    }
    
    func setupUI() {
        addAboveShadow()
        let homeVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierCategoriesVC") as! SupplierCategoriesVC
        let searchVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierOrderVC") as! SupplierOrderVC
        let earningVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierEarningsVC") as! SupplierEarningsVC
        let createVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierNotificationsVC") as! SupplierNotificationsVC
        let connectionsVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierOfferVC") as! SupplierOfferVC
        let myProfileVc = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierProfileVC") as! SupplierProfileVC
        
        viewControllers?.removeAll()
        
        addToTabBar(homeVc)
        addToTabBar(searchVc)
        //addToTabBar(earningVc)
        addToTabBar(createVc)
        addToTabBar(connectionsVc)
        addToTabBar(myProfileVc)
        
        previousController = homeVc
        
        let unSelectedFont = UIFont.systemFont(ofSize: 13, weight: .medium).getAppFont()
        let selectedFont = UIFont.systemFont(ofSize: 15, weight: .bold).getAppFont()
        
        let unselectedColor = UIColor.lightGray
        let selectedColor = UIColor.appColor
        
        tabBar.tintColor = selectedColor
        tabBarItem.badgeColor = selectedColor
        
        let selectedAttributes: [NSAttributedString.Key: Any] =
            [
                NSAttributedString.Key.font: selectedFont,
                NSAttributedString.Key.foregroundColor: selectedColor
        ]
        
        let normalAttributes: [NSAttributedString.Key: Any] =
            [
                NSAttributedString.Key.font: unSelectedFont,
                NSAttributedString.Key.foregroundColor: unselectedColor
        ]
        
        let tabImages: [[UIImage]] = [
            [
                #imageLiteral(resourceName: "list"),
                #imageLiteral(resourceName: "order"),
                #imageLiteral(resourceName: "tab_earning"),
                #imageLiteral(resourceName: "tab_notification"),
                #imageLiteral(resourceName: "offers"),
                #imageLiteral(resourceName: "tab_profile")
            ],
            [
                #imageLiteral(resourceName: "list_selected"),
                #imageLiteral(resourceName: "order_selected"),
                #imageLiteral(resourceName: "tab_earning_selected"),
                #imageLiteral(resourceName: "notification_selected"),
                #imageLiteral(resourceName: "offers_selected"),
                #imageLiteral(resourceName: "profile_selected")
            ]
        ]
        
        let tabTitle: [String] = ["Category", "Order", "Earnings", "Notification", "Offers", "Profile"]
        
        var index = 0
        for item in tabBar.items! {
            if index == 2
            {
                index += 1
            }
            item.image = tabImages[0][index]
            item.selectedImage = tabImages[1][index]
            item.title = tabTitle[index]
            
            item.setTitleTextAttributes(selectedAttributes, for: .selected)
            item.setTitleTextAttributes(normalAttributes, for: .normal)
            
            
            index += 1
        }
    }
    //Add Shadow
    func addAboveShadow()
    {
       self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.tabBar.layer.shadowRadius = 10
        self.tabBar.layer.shadowColor = UIColor.darkGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.3
    }
    // add viewcontroller to tab bar
    func addToTabBar(_ vc: UIViewController) {
        /*
         let navvc = UINavigationController(rootViewController: vc)
         navvc.navigationBar.isHidden = true
         //navvc.setNavigationBarHidden(true, animated: false)
         navvc.navigationBar.barStyle = UIBarStyle.blackOpaque
         */
        viewControllers?.append(vc)
    }
    
}
