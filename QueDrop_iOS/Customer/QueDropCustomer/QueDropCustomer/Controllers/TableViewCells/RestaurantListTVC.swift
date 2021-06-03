//
//  RestaurantListTVC.swift
//  QueDrop
//
//  Created by C100-104 on 03/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class RestaurantListTVC: UITableViewCell {

	@IBOutlet var imageRestaurnt: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblAddress: UILabel!
	@IBOutlet var lblDistance: UILabel!
    @IBOutlet weak var imgHeart: UIImageView!
       var context = CIContext(options: nil)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       // viewGrayFilter.
        imageRestaurnt.layer.cornerRadius = 5
        imageRestaurnt.clipsToBounds = true
        imageRestaurnt.layer.borderColor = UIColor.black.cgColor
        imageRestaurnt.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func addGrayLayer()
    {
        Noir()
    }
    
    func Noir() {
    
            let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
            currentFilter!.setValue(CIImage(image: imageRestaurnt.image!), forKey: kCIInputImageKey)
            let output = currentFilter!.outputImage
            let cgimg = context.createCGImage(output!,from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            imageRestaurnt.image = processedImage
          }
}

