//
//  SupplierStoreDetailsTVC.swift
//  QueDrop
//
//  Created by C100-105 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierStoreDetailsTVC: BaseTableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewStoreContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        DispatchQueue.main.async {
            self.viewStoreContainer.showShadow(color: shadowColor)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        lblTime.isHidden = true
        
        viewContainer.backgroundColor = .clear
        viewStoreContainer.backgroundColor = .white
        viewStoreContainer.showBorder(.clear, 5)
        imgView.showBorder(.clear, 5)
        
        lblDescription.numberOfLines = 0
        viewStoreContainer.clipsToBounds = false
        
        let shadowColor = #colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8823529412, alpha: 1)
        DispatchQueue.main.async {
            self.viewStoreContainer.showShadow(color: shadowColor)
        }
        
    }
    
    func bindStoreDetails() {
        if let store = storeDetailsObj {
            let url = URL_STORE_LOGO_IMAGES + store.storeLogo.asString()
            imgView.setWebImage(url, .noImagePlaceHolder)
            
            lblName.text = store.storeName
            lblDescription.text = store.storeAddress
            var time = ""
            if let schedule = store.schedule, schedule.count > 0 {
                time = schedule[0].openingTime.asString() + " - " + schedule[0].closingTime.asString()
            }
            lblTime.text = time
        }
        
        setupUI()
    }
}
