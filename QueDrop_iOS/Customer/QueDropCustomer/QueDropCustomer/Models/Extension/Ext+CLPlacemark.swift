//
//  Ext+CLPlacemark.swift
//  Dentist
//
//  Created by C100-105 on 02/05/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBook

extension CLPlacemark {
    
    func parseAddress() -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (self.subThoroughfare != nil &&
            self.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) &&
            (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (self.subAdministrativeArea != nil &&
            self.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            self.subThoroughfare ?? "",
            firstSpace,
            // street name
            self.thoroughfare ?? "",
            comma,
            // city
            self.locality ?? "",
            secondSpace,
            // state
            self.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
    func address() -> String {
        var locationString = ""
        
        print("==============")
        
        if let address1 = self.subThoroughfare {
            print(address1)
            locationString.append(address1 + ", ")
        }
        
        if let address = self.thoroughfare {
            print(address)
            locationString.append(address + ", ")
        }
        if let sublocality = self.subLocality {
            print(sublocality)
            locationString.append(sublocality + ", ")
        }
        if let locality = self.locality {
            print(locality)
            locationString.append(locality + ", ")
        }
        
        
        if let administrativeArea = self.administrativeArea {
            print(administrativeArea)
            locationString.append(administrativeArea)
        }
        
        if locationString.count > 0 {
            locationString.append(".")
        }
        
        return locationString
    }
    
    
}
