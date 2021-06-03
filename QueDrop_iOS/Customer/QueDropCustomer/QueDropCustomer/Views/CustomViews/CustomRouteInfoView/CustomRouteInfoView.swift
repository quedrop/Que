//
//  CustomRouteInfoView.swift
//  QueDrop
//
//  Created by C100-104 on 05/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CustomRouteInfoView: BaseViewController {

	@IBOutlet var lblDistance: UILabel!
	@IBOutlet var lblTime: UILabel!
	@IBOutlet var mainView: UIView!
	
	var distance = ""
	var time = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.mainView.layer.shadowColor = UIColor.black.cgColor
		self.mainView.layer.shadowOpacity = 0.3
		self.mainView.layer.shadowOffset = .zero
		self.mainView.layer.shadowRadius = 5
		self.mainView.layer.masksToBounds = false
		
		self.lblTime.text = self.time
		self.lblDistance.text = self.distance
    }
	func setValues(distance : String , time : String)
	{
		self.distance = distance
		self.time = time
	}
}
