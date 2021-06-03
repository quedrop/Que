//
//  Ext+Array.swift
//  LuxuryQatar
//
//  Created by C100-105 on 10/08/19.
//  Copyright © 2019 Narola. All rights reserved.
//

import UIKit

extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension Array {
    func removeBraces(isTrimming: Bool = true) -> String {
        var desc = self.description
        if isTrimming {
            desc = desc.replacingOccurrences(of: " ", with: "")
        }
        
        if desc.count > 1 {
            if (desc.first?.description.elementsEqual("["))! && (desc.last?.description.elementsEqual("]"))! {
                return desc.dropFirst().dropLast().description
            }
        }
        return ""
    }
}
