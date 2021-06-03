//
//  CustomTabbarVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 20/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class CustomTabbarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = THEME_COLOR
        self.tabBar.backgroundColor = .white
       
        //UITabBar.appearance().backgroundColor = .white
        //UITabBar.appearance().tintColor = THEME_COLOR
       // UITabBar.appearance().shadowImage = UIImage.init()
//        UITabBar.appearance().backgroundImage = UIImage.init()
//
//        self.tabBar.layer.shadowColor = UIColor.black.cgColor
//        self.tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        self.tabBar.layer.shadowRadius = 4
//        self.tabBar.layer.shadowOpacity = 0.2
//        self.tabBar.layer.masksToBounds = false
        if #available(iOS 13.0, *) {
            let appearance = tabBar.standardAppearance
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance;
        } else {
           tabBar.shadowImage = UIImage()
           tabBar.backgroundImage = UIImage()
        }
        
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        tabBar.layer.shadowRadius = 10;
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1;
        
    }
    
//    func traitCollection() -> UITraitCollection {
//        return UITraitCollection(horizontalSizeClass: .compact)
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
