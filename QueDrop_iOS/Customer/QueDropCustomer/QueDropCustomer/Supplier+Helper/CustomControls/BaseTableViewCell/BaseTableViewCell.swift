//
//  BaseTableViewCell.swift
//  ProfileRatingApp
//
//  Created by C100-105 on 27/12/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit
import ImageSlideshow

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        imageView?.image = nil
        textLabel?.text = nil
        
        selectionStyle = .none
    }
    
    func getMediaSourceFrom(urls: [String]) ->  [InputSource] {
        
        var inputSource: [InputSource] = []
        for strUrl in urls {
            if let url = URL(string: strUrl) {
                let imgSource = SDWebImageSource(url: url, placeholder: .noImagePlaceHolder)
                inputSource.append(imgSource)
            }
        }
        
        if inputSource.count == 0 {
            let imgSource = ImageSource(image: .noImagePlaceHolder)
            inputSource.append(imgSource)
        }
        
        return inputSource
    }

}
