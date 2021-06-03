//
//  SearchBar.swift
//  LuxuryQatar
//
//  Created by C100-105 on 18/10/19.
//  Copyright © 2019 Narola. All rights reserved.
//

import Foundation
import UIKit

class SearchBarTheme: UISearchBar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tintColor = .black
        barTintColor = .white
        
        if let textfield = self.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = .tableViewBg
        }
    }
    
}
