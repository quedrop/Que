//
//  Ext+ProductOption.swift
//  QueDrop
//
//  Created by C100-105 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation

extension SupplierProducts {
    
    func getPurchasedOption() -> ProductOption {
        var option = ProductOption(json: .null)
        if let optionId = self.optionId, let options = self.productOption {
            for opt in options {
                if opt.optionId == optionId {
                    option = opt
                    break
                }
            }
        }
        return option
    }
}
