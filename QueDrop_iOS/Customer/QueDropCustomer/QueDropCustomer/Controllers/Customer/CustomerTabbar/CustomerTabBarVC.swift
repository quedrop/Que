//
//  CustomerTabBarVC.swift
//  QueDrop
//
//  Created by C100-104 on 03/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CustomerTabBarVC: UITabBarController , UITabBarControllerDelegate {
    var previousIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        addAboveShadow()
        // Do any additional setup after loading the view.
         //APP_DELEGATE.socketIOHandler?.disconnectSocket()
        if (!isGuest),let _ = USER_OBJ {
//          APP_DELEGATE.socketIOHandler = SocketIOHandler()
            APP_DELEGATE.socketIOHandler?.callFunctionsAfterConnection()
      }
    }
    func addAboveShadow()
    {
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.tabBar.layer.shadowRadius = 10
        self.tabBar.layer.shadowColor = UIColor.darkGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.3
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
       /* if isGuest
        {
            if tabBarController.selectedIndex > 0 && tabBarController.selectedIndex < 2//3//4
            {
                tabBarController.selectedIndex = previousIndex
                if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                {
                    LoginView.setupForGuest()
                    let transition:CATransition = CATransition()
                        transition.duration = 0.5
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.push
                        transition.subtype = CATransitionSubtype.fromTop
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(LoginView, animated: false)
                    //self.navigationController?.pushViewController(LoginView, animated: true)
                }
                
               // return false
            }
        }*/
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
      /*  if isGuest
        {
            if tabBarController.selectedIndex > 0 && tabBarController.selectedIndex < 4
            {
                if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                {
                    LoginView.setupForGuest()
                    let transition:CATransition = CATransition()
                        transition.duration = 0.5
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.push
                        transition.subtype = CATransitionSubtype.fromTop
                    self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                    self.navigationController?.pushViewController(LoginView, animated: false)
                    //self.navigationController?.pushViewController(LoginView, animated: true)
                }
                
                return false
            }
        }*/
        previousIndex = tabBarController.selectedIndex
        return true
    }

}
