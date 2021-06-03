//
//  Ext+Alert.swift
//  Dentist
//
//  Created by C100-105 on 11/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit


class CustomControl {
    
    class func openActionSheetAlert(
        _ title: String?,
        _ message: String?,
        _ arrOfList: [String],
        _ textColor: UIColor = .gray,
        response: @escaping (_ index: Int) -> Void) -> UIAlertController {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        for index in 0..<arrOfList.count {
            let str = arrOfList[index]
            
            let strAction = UIAlertAction(title: str, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                response(index)
            })
            
            strAction.setValue(textColor, forKey: "titleTextColor")
            alertController.addAction(strAction)
        }
        
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
