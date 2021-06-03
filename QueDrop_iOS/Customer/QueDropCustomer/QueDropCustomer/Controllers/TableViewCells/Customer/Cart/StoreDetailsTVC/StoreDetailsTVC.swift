//
//  StoreDetailsTVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class StoreDetailsTVC: UITableViewCell {

	@IBOutlet var imageStoreLogo: UIImageView!
	@IBOutlet var lblStoreName: UILabel!
	@IBOutlet var lblStoreAddress: UILabel!
	@IBOutlet var lblStoreDistance: UILabel!
	@IBOutlet var btnCancel: UIButton!
//	@IBOutlet var tableView: UITableView!
	@IBOutlet var outerView: UIView!
	@IBOutlet var innerView: UIView!
	
	//var
	var products : [CartProducts] = []
	var cartDelegate : ManageListOfItemsInCartDelegate?
	var visibleCellCount = 0
	/*var height : CGFloat = 0.0
	{
		didSet{
			cartDelegate?.updatedHeightRorRow(index: tableView.tag, height: height)
		}
	}*/
	
	override func awakeFromNib() {
        super.awakeFromNib()
//		tableView.delegate = self
//		tableView.dataSource = self
		
//		let rectShape = CAShapeLayer()
//		rectShape.bounds = self.innerView.frame
//		rectShape.position = self.innerView.center
//		rectShape.path = UIBezierPath(roundedRect: self.innerView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
		 //self.innerView.layer.backgroundColor = UIColor.green.cgColor
		
		self.outerView.clipsToBounds = true
		self.outerView.layer.cornerRadius = 8
		self.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		self.innerView.clipsToBounds = true
		self.innerView.layer.cornerRadius = 8
		self.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
	
}
//MARK:- TableView Delegate
/*
extension StoreDetailsTVC : UITableViewDelegate , UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  products.count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedItemsOfStoreTVC", for: indexPath) as? SelectedItemsOfStoreTVC
		{
			let product = products[indexPath.row]
			do{
				cell.lblProductName.text = product.productName ?? ""
				cell.lblQty.text  = "\(product.quantity ?? 0)"
				cell.lblTotalPrice.text = product.productFinalPrice
				var addon : [String] = []
				if let addOns = product.addons
				{
					for item in addOns
					{
						addon.append(item.addonName ?? "")
					}
				}
				if let options = product.productOption
				{
					for option in options
					{
						if option.optionId == product.optionId ?? 0
						{
							if option.optionName?.lowercased() == "small"
							{
								addon.append("Small (Serves 1)")
							}
							else if option.optionName?.lowercased() == "medium"
							{
								addon.append("Medium (Serves 2)")
							}
							else if option.optionName?.lowercased() == "large"
							{
								addon.append("Large (Serves 4)")
							}
							else
							{
								addon.append(option.optionName ?? "")
							}
						}
					}
				}
				cell.lblProductAddons.text = addon.joined(separator: ",")
//				if visibleCellCount < products.count
//				{
//					height += cell.bounds.height
//					print("Height Of Cells ::: ", height)
//						visibleCellCount += 1
//				}
				
				cell.selectionStyle = .none
				return cell
			}
		}
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let sum = tableView.visibleCells.map( { $0.bounds.height } ).reduce(0,+)
		
		if visibleCellCount < products.count
		{
			height += sum
			print("Height Of Cells ::: ", height)
				visibleCellCount += 1
		}
//		print("Height:\(sum)")
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
}
*/
