//
//  UserDefaults+Extensions.swift
//  Swing
//
//  Created by C110 on 22/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit
import Foundation

extension UserDefaults {
    
    func setCustom(_ obj: Any, forKey: String) {
        do {
            let defaults = UserDefaults.standard
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: false)
            defaults.set(encodedData, forKey: forKey)
            defaults.synchronize()
        } catch {
            print("Error Occure During Storing Object In Userdefaults")
        }
    }
    
    func getCustom(forKey:String) -> Any? {
        do {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: forKey) != nil {
                let decoded  = defaults.object(forKey: forKey) as! Data
                let decodedObj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as Any
                return decodedObj
            }
        } catch {
            print("Error Occure During Retriving Object From Userdefaults")
        }
        return nil
    }
    
    func removeCustomObject(forKey:String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: forKey)
        defaults.synchronize()
    }
    
}

