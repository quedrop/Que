//
//  UIImageView.swift
//  Motive8
//
//  Created by C100-105 on 25/01/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit
import Photos
import SDWebImage

extension UIImage {
    
    static var noImagePlaceHolder: UIImage {
        let placeholder = QUE_AVTAR //UIImage(named: "avtar")
        return placeholder!
    }
    
}

extension UIImageView {
    
    func setWebImage(_ url : String, _ placeholder: UIImage?) {
        setWebImage(url, placeholder, complete: { isDone, image in
        })
    }
    
    func setWebImage(
        _ url : String,
        _ placeholder: UIImage?,
        complete: @escaping (_ isSucess: Bool, _ image: UIImage?) -> Void) {

        /*
        var noImage = placeholder
        if noImage == nil {
            noImage = #imageLiteral(resourceName: "placeholder")
        }
        */
        
        //self.sd_setShowActivityIndicatorView(true)
        //self.sd_setIndicatorStyle(UIActivityIndicatorView.Style.gray)
        
        var newurl = url
        if url.contains(" ") {
            newurl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).asString()
        }
        let imgUrl = URL(string: newurl)
        self.sd_setImage(
            with: imgUrl,
            placeholderImage: placeholder,
            options: [SDWebImageOptions.transformAnimatedImage],
            completed: { downImage, error, cacheType, imageURL in
                let isDone = downImage != nil
                self.image = isDone ? downImage : placeholder
                complete(isDone, downImage)
        })
    }
}


