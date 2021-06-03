//
//  PastOrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 28/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class PastOrderVC: UIViewController {
	
	
	@IBOutlet var tableView: UITableView!
	
	var arrPastOrder : [CurrentOrder] = []
	var cellType = [Int : Int]() //row:Type
	var arrCellType : [ [Int : Int]] = []
	var storeIndex = [Int : Int]() //section:storesIndex
	//var storeIndexForProduct = [Int : Int]() //section:storesIndex
	var arrStoreIndexForProduct : [[Int : Int]] = []
	//var arrProductIndex = [Int : [Int : Int]]() //[StoreId:storesIndex]
	var arrStoreProductIndex : [[Int : [Int : Int]]] = []
	var rowsInSection : [Int] = [] //rowCount
    var delegate : NavigatefromChildViewControllerDelegate?
	enum enumOrderCells : Int {
		case topStoreDetails = 0 // "topStoreDetails"
		case storeItem//= "storeItem"
		case storeDetails //= "storeDetails"
		case amountDetails //= "amountDetails"
	}
	var tableHeight = CGFloat(600.0)
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
	}
	override func viewWillAppear(_ animated: Bool) {
		self.getPastOrder()
		
	}
	
	func setUpDetails()
	{
		tableView.isHidden = arrPastOrder.count == 0
		cellType.removeAll()
		rowsInSection.removeAll()
		arrStoreIndexForProduct.removeAll()
		arrStoreProductIndex.removeAll()
		storeIndex.removeAll()
		arrCellType.removeAll()
		
		var sCount = 0 // section
		for order in arrPastOrder
		{
			var rowcount = 0 //row
			var strIndex = 0
			var storeProductIndex = [Int : [Int : Int]]()
			var storeIndexForProduct = [Int : Int]() //section:storesIndex
			for store in order.stores!
			{
				storeIndex[rowcount] = strIndex
				
				if rowcount == 0
				{
					cellType[rowcount] = enumOrderCells.topStoreDetails.rawValue
				}
				else
				{
					cellType[rowcount] =  enumOrderCells.storeDetails.rawValue
				}
				rowcount += 1
				var proIndex = 0
				var productIndex = [Int : Int]()
				for _ in store.products!
				{
					productIndex[rowcount] = proIndex
					proIndex += 1
					cellType[rowcount] = enumOrderCells.storeItem.rawValue
					storeIndexForProduct[rowcount] = strIndex
					rowcount += 1
				}
				storeProductIndex[store.storeId ?? 0] = productIndex
				
				strIndex += 1
			}
			cellType[rowcount] = enumOrderCells.amountDetails.rawValue
			rowcount += 1
			rowsInSection.append(rowcount)
			arrCellType.append(cellType)
			arrStoreProductIndex.append(storeProductIndex)
			arrStoreIndexForProduct.append(storeIndexForProduct)
			print("section : \(sCount) - RowCount : \(rowcount)")//
			cellType.removeAll()
			sCount += 1
		}
		self.tableView.reloadData()
	}
}
extension PastOrderVC : UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		arrPastOrder.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rowsInSection[section]
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch arrCellType[indexPath.section][indexPath.row] {
		case enumOrderCells.topStoreDetails.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
			cell.outerView.clipsToBounds = true
			cell.outerView.layer.cornerRadius = 8
			cell.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			cell.innerView.clipsToBounds = true
			cell.innerView.layer.cornerRadius = 8
			cell.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			////
			if let storeDetails  = arrPastOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
			{
				cell.lblStoreName.text = storeDetails.storeName ?? ""
				cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
				if let logoUrl = storeDetails.storeLogo
				{
					cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
				}
				else
				{
					//cell.imageStoreLogo.image =
					cell.imgStoreLogo.image = QUE_AVTAR//UIImage(named: "place_holder")?.withRenderingMode(.alwaysTemplate)
					cell.imgStoreLogo.tintColor = .gray
				}
			}
			////
			cell.selectionStyle = .none
			return cell
		case enumOrderCells.storeDetails.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
			if let storeDetails  = arrPastOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
			{
				cell.lblStoreName.text = storeDetails.storeName ?? ""
				cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
				if let logoUrl = storeDetails.storeLogo
				{
					cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
				}
				else
				{
					//cell.imageStoreLogo.image =
					cell.imgStoreLogo.image = QUE_AVTAR//UIImage(named: "place_holder")?.withRenderingMode(.alwaysTemplate)
					cell.imgStoreLogo.tintColor = .gray
				}
			}
			cell.selectionStyle = .none
			return cell
		case enumOrderCells.storeItem.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderItemsTVCell", for: indexPath) as! CurrentOrderItemsTVCell
			if let storeDetails  = arrPastOrder[indexPath.section].stores?[arrStoreIndexForProduct[indexPath.section][indexPath.row] ?? 0]
			{
				if let product  = storeDetails.products?[arrStoreProductIndex[indexPath.section][storeDetails.storeId ?? 0]?[indexPath.row] ?? 0]
				{
					cell.lblProductName.text = product.productName ?? ""
					//cell.lblProductDetails.text = product.productName ?? ""
					
					if storeDetails.canProvideService ?? 0 == 0
					{
						//cell.lblProductDetails.text = "Total amount for producst will be updated after  order purchased."
						cell.lblProductDetails.text = ""
					}
					else
					{
						if product.addons?.count ?? 0 > 0// || product.productOption.count ?? 0 > 1
						{
							var addon : [String] = []
							if let addOns = product.addons
							{
								for item in addOns
								{
									addon.append(item.addonName ?? "")
								}
							}
							/*if let options = product.productOption
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
										else if option.optionName?.lowercased() == "default"
										{
										}
										else
										{
											addon.append(option.optionName ?? "")
										}
									}
								}
							}*/
							cell.lblProductDetails.text = addon.joined(separator: ", ")
						}
						else
						{
							cell.lblProductDetails.text = "Regular"
						}
					}
				}
			}
			cell.imageTypeLogoWidth.constant = 0
			cell.bottomCountViewHeight.constant = 0
			cell.selectionStyle = .none
			return cell
		case enumOrderCells.amountDetails.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderDetailsTVCell", for: indexPath) as! CurrentOrderDetailsTVCell
			cell.lblOrderAmount.text  = "\(Currency)\(String(format: "%.2f",arrPastOrder[indexPath.section].orderTotalAmount ?? 0))"
			cell.outerView.clipsToBounds = true
			cell.outerView.layer.cornerRadius = 8
			cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			cell.innerView.clipsToBounds = true
			cell.innerView.layer.cornerRadius = 8
			cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			let dateStr = arrPastOrder[indexPath.section].orderDate ?? ""
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			var date = dateFormatter.date(from:dateStr)!
            date = date.UTCtoLocal().toDate()!
			cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
			cell.selectionStyle = .none
            if arrPastOrder[indexPath.section].deliveryOption == ENUM_DeliveryOption.Standard.rawValue {
                cell.btnRepeatOrder.isHidden = true
            } else {
                cell.btnRepeatOrder.isHidden = false
                cell.btnRepeatOrder.setTitle(" \(arrPastOrder[indexPath.section].deliveryOption ?? "") Delivery ", for: .normal)
                scaleFont(byWidth: cell.btnRepeatOrder)
            }
            
			return cell
		default:
			break
		}
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.navigateToDetails(OrderObj: arrPastOrder[indexPath.section], isPastOrder: true)
    }
	
}
