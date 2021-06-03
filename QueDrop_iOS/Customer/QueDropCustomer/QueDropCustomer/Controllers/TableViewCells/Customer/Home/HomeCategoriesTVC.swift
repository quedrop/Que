//
//  HomeCategoriesTVC.swift
//  QueDrop
//
//  Created by C100-104 on 07/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//


import UIKit

class HomeCategoriesTVC: UITableViewCell {

	@IBOutlet var lblHeader: UILabel!
	@IBOutlet var collectionView: UICollectionView!
	
	
	override func awakeFromNib() {
		  super.awakeFromNib()
		collectionView.register("CategoriesCVCell")
		collectionView.register("CategoriesShimmerCVCell")
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
