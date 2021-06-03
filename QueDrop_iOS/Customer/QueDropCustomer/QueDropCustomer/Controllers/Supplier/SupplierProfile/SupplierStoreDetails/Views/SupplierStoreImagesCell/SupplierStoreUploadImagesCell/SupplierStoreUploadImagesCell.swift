//
//  SupplierStoreUploadImagesCell.swift
//  Gofer
//
//  Created by C100-105 on 11/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit

class SupplierStoreUploadImagesCell: BaseTableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewAddPhoto: UIView!
    
    @IBOutlet weak var collectionImages: UICollectionView!
    
    var cellIndex: Int?
    var arrOfImages: [UIImage] = []
    var arrOfMedia: [String] = []
    
    var callbackForAddImage: Callback?
    var callbackForDeleteUIImage: ((Int)->())?
    var callbackForDeleteSliderImage: ((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionImages.register("CollImageCell")
        collectionImages.register("Coll_AddMoreCell")
        
        collectionImages.delegate = self
        collectionImages.dataSource = self
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setImagesToCollection(images: [UIImage], media: [String]) {
        self.arrOfImages = images
        self.arrOfMedia = media
 //       let isHavingImages = arrOfImages.count > 0 || arrOfMedia.count > 0
        
//        viewAddPhoto.isHidden = isHavingImages
//        viewAddPhoto.isUserInteractionEnabled = !isHavingImages
//
//        collectionImages.isHidden = !isHavingImages
//        collectionImages.isUserInteractionEnabled = isHavingImages
        
        viewAddPhoto.isHidden = true
        viewAddPhoto.isUserInteractionEnabled = false
        
        collectionImages.isHidden = false
        collectionImages.isUserInteractionEnabled = true
        
        collectionImages.reloadData()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        viewContainer.backgroundColor = .clear
        viewAddPhoto.backgroundColor = .clear
        collectionImages.backgroundColor = .clear
    }
    
}

extension SupplierStoreUploadImagesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let singleCell = collectionView.frame.width / 3
        let leftRightSpacing = singleCell - (singleCell / 1.3)
            
        collectionView.contentInset = UIEdgeInsets(top: 10, left: leftRightSpacing, bottom: 10, right: leftRightSpacing)
  
        let width = CGFloat(Int(singleCell - leftRightSpacing))
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = arrOfImages.count + arrOfMedia.count + 1
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        
        if index == (arrOfImages.count + arrOfMedia.count) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Coll_AddMoreCell", for: indexPath) as! Coll_AddMoreCell
            cell.callbackForAddMore = {
                self.callbackForAddImage?()
            }
            cell.imgView.contentMode = .scaleAspectFit
            cell.contentView.showBorder(.lightGray, 5)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollImageCell", for: indexPath) as! CollImageCell
        
        cell.imgProblem.showBorder(.lightGray, 5)
        
        let isMediaUrl = index < arrOfMedia.count
        
        if isMediaUrl {
            
            let mediaUrl = arrOfMedia[index]
            cell.imgProblem.setWebImage(mediaUrl, .noImagePlaceHolder)
            
        } else {
            index = index - arrOfMedia.count
            let image = arrOfImages[index]
            cell.imgProblem.image = image
            
        }
        
        cell.callbackForDelete = {
            if isMediaUrl {
                self.callbackForDeleteSliderImage?(index)
            } else {
                self.callbackForDeleteUIImage?(index)
            }
        }
        
        return cell
    }
    
}
