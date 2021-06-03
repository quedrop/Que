//
//  CustomerProfileHeaderTVCell.swift
//  QueDrop
//
//  Created by C205 on 13/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import TTTAttributedLabel
class CustomerProfileHeaderTVCell: BaseTableViewCell {

    
      @IBOutlet weak var viewContainer: UIView!
      
      @IBOutlet weak var imgEdit: UIImageView!
      @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUseName: UILabel!
    @IBOutlet weak var lblUserAddress: UILabel!
    @IBOutlet weak var viewUserRatings: HCSStarRatingView!
    @IBOutlet weak var imgLocation: UIImageView!
    @IBOutlet weak var viewRatingHeight: NSLayoutConstraint!
    @IBOutlet weak var viewAttributedLabel: UIView!
    @IBOutlet weak var lblLoginDetails: TTTAttributedLabel!
    
    @IBOutlet weak var basicDetailsHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
      
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindDetails(image: UIImage?,rating : Float) {
          viewContainer.showBorder(.clear, 10)
          imgEdit.isUserInteractionEnabled = true
          imgLocation.setImageColor(color: .systemBlue)
        viewUserRatings.value = CGFloat(rating)
        lblUseName.text = USER_OBJ?.firstName ?? ""
        lblUserAddress.text = defaultAddress?.addressTitle ?? ""
          if let image = image {
              imgProfile.image = image
          } else if let user = USER_OBJ {
            if user.userImage?.isValidUrl() ?? false
            {
              let url = user.userImage.asString()
              imgProfile.setWebImage(url, .noProfilePlaceHolder)
            }
            else{
                let url = URL_USER_IMAGES + user.userImage.asString()
                 imgProfile.setWebImage(url, .noProfilePlaceHolder)
            }
          }
          
          imgProfile.contentMode = .scaleAspectFill
          imgProfile.circlularView()
       // imgProfile.showShadow(color: .lightGray)
      }
}
