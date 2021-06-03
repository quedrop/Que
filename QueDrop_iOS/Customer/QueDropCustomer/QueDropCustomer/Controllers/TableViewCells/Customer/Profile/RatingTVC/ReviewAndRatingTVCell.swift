//
//  ReviewAndRatingTVCell.swift
//  QueDrop
//
//  Created by C205 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ReviewAndRatingTVCell: BaseTableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblReviewContent: UILabel!
    @IBOutlet weak var userRating: HCSStarRatingView!
    
    
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
        userRating.value  = CGFloat(rating)
        let url = image.getUserImageURL() //URL_USER_IMAGES + image
        userImage.setWebImage(url.absoluteString, USER_AVTAR)
            userImage.contentMode = .scaleAspectFill
            userImage.circlularView()
        }
}
