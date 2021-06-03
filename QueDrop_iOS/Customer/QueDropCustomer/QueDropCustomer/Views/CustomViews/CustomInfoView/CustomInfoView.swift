//
//  CustomInfoView.swift
//  QueDrop
//
//  Created by C100-104 on 05/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage


class CustomInfoView: BaseViewController {

	@IBOutlet var topMainView: UIView!
	@IBOutlet var imageLogo: UIImageView!
	@IBOutlet var lblStoreName: UILabel!
	@IBOutlet var lblStoreAddress: UILabel!
	@IBOutlet var lblStoreDistance: UILabel!
	
	@IBOutlet var lblTime: UILabel!
	
	//MARK:- Variables
	var name: String = ""
	var address : String = ""
	var distance : String = ""
	var time : String = ""
	var shopId : Int = 0
	var logoURL : String = ""
	override func viewDidLoad() {
        super.viewDidLoad()

		self.topMainView.layer.shadowColor = UIColor.black.cgColor
		self.topMainView.layer.shadowOpacity = 0.3
		self.topMainView.layer.shadowOffset = .zero
		self.topMainView.layer.shadowRadius = 5
		self.topMainView.layer.masksToBounds = false
		self.lblStoreName.text = name
		self.lblStoreAddress.text = address
		self.lblStoreDistance.text = distance
		self.lblTime.text = time
		self.imageLogo.sd_setImage(with: URL(string: logoURL), placeholderImage:#imageLiteral(resourceName: "location_mark_green"), completed: nil)
		
		self.imageLogo.layer.borderColor = UIColor.black.cgColor
		self.imageLogo.layer.borderWidth = 0.5
		self.imageLogo.layer.cornerRadius = 5
		self.imageLogo.clipsToBounds = true
		
    }
	override func viewWillAppear(_ animated: Bool) {
		
	}
	@IBAction func btnViewDidTap(_ sender: UIButton) {
		print("Did Tap Works....")
		
	}
	
	
	
	func setDetail(name: String , address : String , distance : String, shopId : String, logoURL : String,time : String){
		self.name  = name
		self.address  = address
		self.distance  = distance
		self.shopId  = Int(shopId) ?? 0
		self.logoURL = "\(URL_STORE_LOGO_IMAGES)\(logoURL)"
		self.time = time
	}
	

}
