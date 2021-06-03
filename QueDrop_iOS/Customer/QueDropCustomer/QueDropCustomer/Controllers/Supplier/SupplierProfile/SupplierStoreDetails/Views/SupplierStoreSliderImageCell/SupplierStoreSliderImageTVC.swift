//
//  SupplierStoreSliderImageTVC.swift
//  QueDrop
//
//  Created by C100-105 on 13/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import ImageSlideshow

class SupplierStoreSliderImageTVC: BaseTableViewCell {
    
    var callbackForOpenFullVC: Callback?
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var viewSlideShow: ImageSlideshow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupUI() {
        super.setupUI()
        
        viewSlideShow.contentScaleMode = .scaleAspectFill
        viewContainer.showBorder(.lightGray, 10)
        
        viewSlideShow.isUserInteractionEnabled = true

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
