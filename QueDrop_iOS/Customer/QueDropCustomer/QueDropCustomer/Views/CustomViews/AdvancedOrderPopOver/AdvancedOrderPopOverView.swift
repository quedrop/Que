//
//  AdvancedOrderPopOverView.swift
//  QueDrop
//
//  Created by C100-104 on 19/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

//protocol AdvancedOrderPopoverDelegate {
//	func dismissPopOver(_ type: String)
//}

class AdvancedOrderPopOverView: UIViewController {

	
	@IBOutlet var tableView: UITableView!
	
	var delegate : UITableViewDelegate?
	var dataSource : UITableViewDataSource?
//	var delegate : AdvancedOrderPopoverDelegate?
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = delegate
			tableView.dataSource = dataSource
    }
	func setUpTableView(delegate : UITableViewDelegate , dataSource : UITableViewDataSource){
		self.delegate = delegate
		self.dataSource = dataSource
	}
}
