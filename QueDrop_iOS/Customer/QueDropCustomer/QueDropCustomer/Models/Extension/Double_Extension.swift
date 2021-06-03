//
//  Double_Extension.swift
//  QueDrop
//
//  Created by C100-104 on 05/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import UIKit
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
class SubclassedUIButton: UIButton {
    var indexPath: Int?
    var urlString: String?
}
