//
//  ImageSliderTVC.swift
//  QueDrop
//
//  Created by C100-104 on 21/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import ImageSlideshow

class ImageSliderTVC: UITableViewCell {

	@IBOutlet var imageSlider: ImageSlideshow!
	override func awakeFromNib() {
        super.awakeFromNib()
		imageSlider.layer.borderColor = UIColor.gray.cgColor
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
