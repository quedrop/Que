//
//  DriversReceiptTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class DriversReceiptTVCell: UITableViewCell {

	@IBOutlet var collectionView: UICollectionView!
	
	var arrReceipt : [String] = []
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
	
}

