//
//  Ext+UICollectionView.swift
//  QueDrop
//
//  Created by C100-105 on 09/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

extension UITableView {
    
    func setRows(_ array: [Any], noDataTitle title: String, message: String, font: UIFont = UIFont(name: fFONT_REGULAR, size: 16.0)!) -> Int {
        let totalCount = array.count
        
        if totalCount == 0 {
            setEmptyView(title: title, message: message, font: font)
        } else {
            restore()
        }
        
        return array.count
    }
    
    private func setEmptyView(title: String, message: String, font: UIFont) {
        self.backgroundView = self.getEmptyView(title: title, message: message, font: font)
        self.separatorStyle = .none
    }
    
    public func restore() {
        self.backgroundView = nil
    }
    
}
