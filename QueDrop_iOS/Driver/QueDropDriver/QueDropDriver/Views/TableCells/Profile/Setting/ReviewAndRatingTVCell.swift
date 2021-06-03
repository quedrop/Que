//
//  ReviewAndRatingTVCell.swift
//  QueDrop
//
//  Created by C205 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import FloatRatingView

class ReviewAndRatingTVCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblReviewContent: UILabel!
    @IBOutlet weak var userRating: FloatRatingView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bindDetails(image: String, userName : String, rating : Float , review : String , dateTime : String) {
        lblUserName.text  = userName
        lblReviewContent.text  = review
        let dateStr = dateTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var ratingDate = dateFormatter.date(from:dateStr)!
        ratingDate = ratingDate.UTCtoLocal().toDate()!
        let timeAgo = ratingDate.timeAgo()
        lblTime.text = timeAgo
        userRating.rating  = Double(rating)
       // let url = URL_USER_IMAGES + image
                //userImage.setWebImage(url, .noImagePlaceHolder)
         userImage.sd_setImage(with: image.getUserImageURL(), placeholderImage: UIImage(named: "avtar"),completed : nil)
            userImage.contentMode = .scaleAspectFill
            userImage.circlularView()
        }
}
