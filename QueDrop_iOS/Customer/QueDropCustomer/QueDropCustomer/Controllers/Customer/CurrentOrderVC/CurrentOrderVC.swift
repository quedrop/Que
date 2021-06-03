//
//  CurrentOrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 27/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

protocol NavigatefromChildViewControllerDelegate {
    func navigateToDetails(OrderObj : CurrentOrder , isPastOrder : Bool)
}

class CurrentOrderVC: UIViewController {

	@IBOutlet var tableView: UITableView!
	
	var arrCurrentOrder : [CurrentOrder] = []
	var cellType = [Int : Int]() //row:Type
	var arrCellType : [ [Int : Int]] = []
	var storeIndex = [Int : Int]() //section:storesIndex
	var timerTracker = [IndexPath : Bool]()
	var arrStoreIndexForProduct : [[Int : Int]] = []
	//var arrProductIndex = [Int : [Int : Int]]() //[StoreId:storesIndex]
    var isInScreen = false
	var arrStoreProductIndex : [[Int : [Int : Int]]] = []
	var rowsInSection : [Int] = [] //rowCount
	var delegate : NavigatefromChildViewControllerDelegate?
	enum enumOrderCells : Int {
		case topStoreDetails = 0 // "topStoreDetails"
		case storeItem//= "storeItem"
		case storeDetails //= "storeDetails"
		case amountDetails //= "amountDetails"
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
        nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderStatus.rawValue), object: nil)
		nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderAccepted.rawValue), object: nil)
		nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderCancelled.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.timerValueUpdated.rawValue), object: nil)
    }
	override func viewWillAppear(_ animated: Bool) {
		isInScreen = true
        getCurrentOrder()
        
	}
    override func viewWillDisappear(_ animated: Bool) {
        isInScreen = false
    }
	func setUpDetails()
	{
		tableView.isHidden = arrCurrentOrder.count == 0
		cellType.removeAll()
		rowsInSection.removeAll()
		arrStoreIndexForProduct.removeAll()
		arrStoreProductIndex.removeAll()
		storeIndex.removeAll()
		arrCellType.removeAll()
		timerTracker.removeAll()
		var sCount = 0 // section
		for order in arrCurrentOrder
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
			//print("section : \(sCount) - RowCount : \(rowcount)")
			cellType.removeAll()
			sCount += 1
		}
		self.tableView.reloadData()
	}
	//Socket Event
	@objc func updateOrderStatus(notification:Notification){
		self.getCurrentOrder()

	}
	
	func setUpTimerLabel(indexPath : IndexPath , second : Int) {
		
		if let userCell = tableView.cellForRow(at: indexPath) as? CurrentOrderHeaderTVCell
		{
			userCell.lblTimerRunningTime.delegate = self
			userCell.lblTimerRunningTime .reset()
			userCell.lblTimerRunningTime.timeFormat = "mm:ss"
			userCell.lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
			userCell.lblTimerRunningTime.addTimeCounted(byTime: TimeInterval(second))
			userCell.lblTimerRunningTime.start()
			//userCell.lblTimerRunningTime.delegate = self
		}
    }
}

extension CurrentOrderVC : UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		arrCurrentOrder.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rowsInSection[section]
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	//	print("section : \(indexPath.section) - Row : \(indexPath.row)")
		switch arrCellType[indexPath.section][indexPath.row] {
		case enumOrderCells.topStoreDetails.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
			cell.outerView.clipsToBounds = true
			cell.outerView.layer.cornerRadius = 8
			cell.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			cell.innerView.clipsToBounds = true
			cell.innerView.layer.cornerRadius = 8
			cell.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
			cell.viewTimerRound.layer.cornerRadius = cell.viewTimerRound.bounds.width / 2
			cell.viewTimerRound.layer.borderWidth = 1.5
			cell.viewTimerRound.layer.borderColor = UIColor.green.cgColor
			
			////
			if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
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
				cell.orderId = arrCurrentOrder[indexPath.section].orderId ?? 0
				//UserDefaults.standard.set(second, forKey: "oneMinTimerSec_\(orderId)")
				let orderStatus = arrCurrentOrder[indexPath.section].orderStatus ?? ""
				cell.viewTimer.isHidden = true
				cell.btnReSchedule.isHidden  = true
				if orderStatus == "Placed"
				{
                    let dateStr = arrCurrentOrder[indexPath.section].orderDate ?? ""
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    var orderDate = dateFormatter.date(from:dateStr)!
                    orderDate = orderDate.UTCtoLocal().toDate()!
                    let difference = Calendar.current.dateComponents([.second], from: orderDate, to: Date())
                    var seconds = difference.second ?? 0
                    print(seconds)
					//let seconds  = UserDefaults.standard.integer(forKey: "oneMinTimerSec_\(cell.orderId)")
                    if seconds < AcceptOrderWaitingTime
                    {
                        seconds = AcceptOrderWaitingTime - seconds
                        cell.lblTimerRunningTime.delegate = self
                        
                        cell.lblTimerRunningTime.reset()
                        cell.viewTimer.isHidden = false
                        cell.lblTimerRunningTime.tag = (indexPath.section*100)+indexPath.row
                        cell.lblTimerRunningTime.accessibilityHint = "ThreeMin"
                        cell.btnReSchedule.isHidden  = true
                        //cell.lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
                        cell.lblTimerRunningTime.setCountDownTime(TimeInterval(seconds))
                        cell.lblTimerRunningTime.start()
                        //cell.lblTimerRunningTime.delegate = self
                        
                    }
					else
					{
						cell.viewTimer.isHidden = true
						cell.btnReSchedule.isHidden  = false
                        cell.btnReSchedule.tag = arrCurrentOrder[indexPath.section].orderId ?? 0
                        cell.btnReSchedule.addTarget(self, action: #selector(actionReschedule( _ :)), for: .touchUpInside)
					}
				}
				else if orderStatus == "Accepted" || orderStatus == "Dispatch"
				{
					cell.viewTimer.isHidden = false
					cell.btnReSchedule.isHidden  = true
					if (timerTracker[indexPath] ?? false) {
					}else {
						let dateStr = arrCurrentOrder[indexPath.section].updatedServerTime ?? ""
						let dateFormatter = DateFormatter()
                        
						dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
						var  orderDate = dateFormatter.date(from:dateStr)!
                        orderDate = orderDate.UTCtoLocal().toDate()!
						let difference = Calendar.current.dateComponents([.second], from: orderDate, to: Date())
						var seconds = difference.second ?? 0
						print(seconds)
                    
					print("==================================")
						print("OrderDate : ",dateFormatter.string(from: orderDate))
						print("Diffrence : ",difference)
						print("seconds : ",seconds)
					print("==================================")
						//setUpTimerLabel(indexPath: indexPath, second: seconds)
						cell.lblTimerRunningTime.accessibilityHint = "Custom"
						//cell.lblTimerRunningTime.timeFormat = "mm:ss"
                        let mSec = arrCurrentOrder[indexPath.section].timerValue ?? 0
						if seconds < mSec
						{
							seconds = mSec - seconds
                            if seconds <= 180
                            {
                                //Api Calling For reset Timer
                                let d = ["user_id" : USER_OBJ?.userId ?? 0,
                                         "order_id" : arrCurrentOrder[indexPath.section].orderId ?? 0] as [String : Any]
                                APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                            }
                            cell.lblTimerRunningTime.delegate = self
                            cell.lblTimerRunningTime .reset()
                            
                            //cell.lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
                            cell.lblTimerRunningTime.setCountDownTime(TimeInterval(seconds))
                            cell.lblTimerRunningTime.start()
                            //cell.lblTimerRunningTime.delegate = self
                            
						}
						else
						{
                            cell.lblTimerRunningTime.text = "..."
                             
                                 //Api Calling For reset Timer
                                 let d = ["user_id" : USER_OBJ?.userId ?? 0,
                                         "order_id" : arrCurrentOrder[indexPath.section].orderId ?? 0] as [String : Any]
                                 APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                             
						}
						timerTracker[indexPath] = true
					}
				}
                else
                {
                    cell.viewTimer.isHidden = false
                    cell.btnReSchedule.isHidden  = true
                    cell.lblTimerRunningTime.text = "00:00"
                }
				
			}
			////
			cell.selectionStyle = .none
			return cell
		case enumOrderCells.storeDetails.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
			if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
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
			if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[arrStoreIndexForProduct[indexPath.section][indexPath.row] ?? 0]
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
			cell.lblOrderAmount.text  = "\(Currency)\(String(format: "%.2f",arrCurrentOrder[indexPath.section].orderTotalAmount ?? 0))"
			cell.outerView.clipsToBounds = true
			cell.outerView.layer.cornerRadius = 8
			cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			cell.innerView.clipsToBounds = true
			cell.innerView.layer.cornerRadius = 8
			cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			let dateStr = arrCurrentOrder[indexPath.section].orderDate ?? ""
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			var date = dateFormatter.date(from:dateStr)!
            date = date.UTCtoLocal().toDate()!
			cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
			cell.selectionStyle = .none
            if arrCurrentOrder[indexPath.section].deliveryOption ==  ENUM_DeliveryOption.Standard.rawValue {
                cell.btnRepeatOrder.isHidden = true
            } else {
                cell.btnRepeatOrder.isHidden = false
                cell.btnRepeatOrder.setTitle(" \(arrCurrentOrder[indexPath.section].deliveryOption ?? "") Delivery ", for: .normal)
                scaleFont(byWidth: cell.btnRepeatOrder)
            }
			return cell
		default:
			break
		}
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.navigateToDetails(OrderObj: arrCurrentOrder[indexPath.section], isPastOrder: false)
	}
    
    @objc func actionReschedule(_ sender : UIButton)
    {
        let orderId = sender.tag
        self.reScheduleOrder(orderId: orderId)
    }
	
}

extension CurrentOrderVC : MZTimerLabelDelegate {
	func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        print("finish")
        let tag = timerLabel.tag
        let section = tag / 100
        let row = tag % 100
        if timerLabel.accessibilityHint ?? "" ==  "ThreeMin"
        {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? CurrentOrderHeaderTVCell
            cell?.viewTimer.isHidden = true
            cell?.btnReSchedule.isHidden = false
        }
    }
	func timerLabel(_ timerLabel: MZTimerLabel!, countingTo time: TimeInterval, timertype timerType: MZTimerLabelType) {
        if isInScreen
        {
                    //print("Current Order")
                let tag = timerLabel.tag
                let section = tag / 100
                // let row = tag % 100
                let orderStatus = arrCurrentOrder[section].orderStatus
                if orderStatus == "Accepted" || orderStatus == "Dispatch"
                {
                    if time <= 180.0
                    {
                        //Api Calling For reset Timer
                        let d = ["user_id" : USER_OBJ?.userId ?? 0,
                                 "order_id" : arrCurrentOrder[section].orderId ?? 0] as [String : Any]
                        APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                    }
                }
        }
	}
}
