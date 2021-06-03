//
//  ProfileImageCell.swift
//  QueDrop
//
//  Created by C100-105 on 22/03/20.
//  Copyright © 2020 Narola. All rights reserved.
//

import UIKit

class ProfileImageCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var imgEdit: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func bindDetails(image: UIImage?) {
        viewContainer.showBorder(.clear, 10)
        imgEdit.isUserInteractionEnabled = true
        
        if let image = image {
            imgProfile.image = image
        } else if let user = USER_OBJ {
            //let url = URL_USER_IMAGES + user.userImage.asString()
            //imgProfile.setWebImage(url, .noImagePlaceHolder)
            imgProfile.sd_setImage(with: user.userImage.asString().getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
        }
        
        imgProfile.contentMode = .scaleAspectFill
        imgProfile.circlularView()
    }
    
}
