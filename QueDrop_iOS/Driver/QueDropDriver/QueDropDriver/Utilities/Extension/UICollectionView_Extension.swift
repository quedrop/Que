//
//  UICollectionView_Extension.swift
//  QueDropDeliveryCustomer
//
//  Created by C100-104 on 01/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import Foundation
import Foundation
import UIKit
extension UICollectionView{
    func register(_ cellClass: String) {
		register(UINib(nibName: cellClass, bundle: nil), forCellWithReuseIdentifier: cellClass)
    }
}
