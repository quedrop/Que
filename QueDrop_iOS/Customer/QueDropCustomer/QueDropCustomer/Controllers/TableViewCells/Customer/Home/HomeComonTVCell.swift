//
//  HomeComonTVCell.swift
//  QueDrop
//
//  Created by C100-104 on 31/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class HomeComonTVCell: UITableViewCell {

	@IBOutlet var lblHeader: UILabel!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var btnSeeAll: UIButton!
	@IBOutlet var pageControl: UIPageControl!
	@IBOutlet var constraintPageControlHeight: NSLayoutConstraint! //37
	override func awakeFromNib() {
        super.awakeFromNib()
		collectionView.register("TodayDealCVCell")
		collectionView.register("PaymentOfferCVCell")
		collectionView.register("RestaurantOfferCVC")
		collectionView.register("RestaurantOfferShimmerCVC")
		//collectionView.register("CategoriesCVCell")
        collectionView.register("FreshProduceCell")
        collectionView.register("CategoriesShimmerCVCell")
        collectionView.register("StoreSlidingCell")
        collectionView.register("ProductCVC")
		// Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
