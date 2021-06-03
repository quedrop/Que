//
//  ProfileImageDetailsCell.swift
//  ProfileRatingApp
//
//  Created by C100-105 on 19/03/20.
//  Copyright © 2020 Narola. All rights reserved.
//

import UIKit
import ImageSlideshow

class SupplierImageScrollingCell: BaseTableViewCell {

    var callbackForOpenFullVC: Callback?
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewBlurr: AlertBlurrView!
    
    @IBOutlet weak var viewSlideShow: ImageSlideshow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewBlurr.isHidden = false
        
        viewSlideShow.contentScaleMode = .scaleAspectFill
        viewSlideShow.clipsToBounds = true
        
        viewSlideShow.isUserInteractionEnabled = true
        viewBlurr.isUserInteractionEnabled = false
        
        
    }
    
    func bindDetails(ofURLs urls: [String]) {
        
        let inputSource = getMediaSourceFrom(urls: urls)
        viewSlideShow.setImageInputs(inputSource)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOpenFullVC))
        viewSlideShow.addGestureRecognizer(tap)
        
        setupUI()
    }
    
    @objc func tapOpenFullVC() {
        callbackForOpenFullVC?()
    }
    
}
