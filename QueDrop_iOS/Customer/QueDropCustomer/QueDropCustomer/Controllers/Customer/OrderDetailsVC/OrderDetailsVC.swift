//
//  OrderDetailsVC.swift
//  QueDrop
//
//  Created by C100-104 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import Foundation

enum enumOrderStatus : String {
    case accepted = "Accepted"
    case dispatched = "Dispatch"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
}
class OrderDetailsVC: BaseViewController {

	@IBOutlet var backButton: UIButton!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var driverViewHeight: NSLayoutConstraint! //0 -135
	@IBOutlet var imgDriver: UIImageView!
	@IBOutlet var lblDriverName: UILabel!
	@IBOutlet var btnChatWIthDriver: UIButton!
	@IBOutlet var driverRating: HCSStarRatingView!
	@IBOutlet var viewDriver: UIView!
    @IBOutlet weak var btnTrackOrder: UIButton!
    @IBOutlet var viewExpressDelivery: UIView!
    @IBOutlet var constraintViewExpressDeliveryHeight: NSLayoutConstraint! //44
    @IBOutlet var constraintMarginHeight: NSLayoutConstraint! //0
    @IBOutlet var imgExpress: UIImageView!
   // var scanner : QRCodeScannerController?
    
    var reScheduleOrderDetails : Order?
	var driverDetails : DriverDetail? =  nil
	var orderId = 0
    var isInScreen = false
	//var arrCurrentOrder : [CurrentOrder] = []
	var orderDetails : OrderDetails? = nil
    var isManualStorePriceUpdated = false
	var cellType = [Int : Int]() //row:Type
	var arrCellType : [ [Int : Int]] = []
	var storeIndex = [Int : Int]() //section:storesIndex
	var storeIndexForProduct = [Int : Int]() //section:storesIndex
	//var arrProductIndex = [Int : [Int : Int]]() //[StoreId:storesIndex]
	var arrStoreProductIndex : [[Int : [Int : Int]]] = []
	var rowsInSection : [Int] = [] //rowCount
	var arrReceipt : [String] = []
	var OrderStatusAtSection = 0
	var StoreReceptsAtSection = 2
	var ScanQRButtonAtSection = 3
	var isDriverAvailable  = false
	var billingRowCount =  0
	var registeredStoreCount = 0
	var manualStoreCount = 0
    var isReSceduleAvailable = false
    var isPastOrderDetails = false
	enum enumOrderCells : Int {
		case topStoreDetails = 0 // "topStoreDetails"
		case storeItem//= "storeItem"
		case storeDetails //= "storeDetails"
		case amountDetails //= "amountDetails"
	}
	enum enumsectionsOfDetails : Int {
		case orderStatus = 0
		case orderItems
        case driverNote
		case note
		case billDetails
		case StoreReceipts
		case ScanQRButton
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
        roundingCorners(viewExpressDelivery, byRoundingCorners: [.bottomLeft,.bottomRight], size: CGSize(width: 12.0,height: 12.0))
        viewExpressDelivery.backgroundColor = THEME_COLOR_2
        //imgExpress.image = setImageViewTintColor(img: imgExpress, color: .black)
		nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderStatus.rawValue), object: nil)
		nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.orderAccepted.rawValue), object: nil)
		nc.addObserver(self, selector: #selector(updateOrderCanceled(notification:)), name: Notification.Name(notificationCenterKeys.orderCancelled.rawValue), object: nil)
          nc.addObserver(self, selector: #selector(updateOrderStatus(notification:)), name: Notification.Name(notificationCenterKeys.timerValueUpdated.rawValue), object: nil)
		getOrderDetails(of: orderId)
		//setUpDetails()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		isInScreen = true
        self.isTabbarHidden(true)
	}
    override func viewWillDisappear(_ animated: Bool) {
        isInScreen = false
    }
	
	@IBAction func actionGoToChat(_ sender: Any) {
		//ShowToast(message: "Under Development.")
        if isDriverAvailable {
            if let driver = orderDetails!.driverDetail
            {
                if driver.firstName != nil
                {
                   // driverDetails = driver
                    let imgUrl = driver.userImage!.getUserImageURL().absoluteString//URL_USER_IMAGES + (driver.userImage ?? "")
                    let name = (driver.firstName ?? "") + " " + (driver.lastName ?? "")
                    let strId = driver.userId
                    
                    
                    let nextViewController = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "CustomerChatVC") as! CustomerChatVC
                    nextViewController.receiver_id = strId!
                    nextViewController.receiver_name = name
                    nextViewController.receiver_profile = imgUrl
                    nextViewController.orderId = orderDetails?.orderId ?? 0
                               nextViewController.orderStatus = orderDetails?.orderStatus ?? ""
                  self.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        }
	}
	
	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
    @IBAction func actionTrackOrder(_ sender: Any) {
        let driverLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "DriverLocationVC") as! DriverLocationVC
        driverLocationVC.setdriver(id: orderDetails?.driverDetail?.userId ?? 0, lat: orderDetails?.driverDetail?.latitude ?? "" , long: orderDetails?.driverDetail?.longitude ?? "", orderDetails: orderDetails!,deliveryLatitude: orderDetails?.deliveryLatitude ?? "" ,deliveryLongitude: orderDetails?.deliveryLongitude ?? "")
        self.navigationController?.pushViewController(driverLocationVC, animated: true)
    }
    
    func setOrderId(_ orderId : Int, _ isPastOrder : Bool = false)
	{
		self.orderId = orderId
        self.isPastOrderDetails = isPastOrder
//		arrCurrentOrder.removeAll()
//		arrCurrentOrder.append(order)
	}
	
	//MARK:- SetUp Methods
	func setUpDetails()
	{
		tableView.isHidden = orderDetails == nil
		cellType.removeAll()
	//	arrProductIndex.removeAll()
		storeIndexForProduct.removeAll()
		arrStoreProductIndex.removeAll()
		arrReceipt.removeAll()
		var ReceiptCount = 0
		//var sCount = enumsectionsOfDetails.orderItems // section
		
			var rowcount = 0 //row
			var strIndex = 0
			var storeProductIndex = [Int : [Int : Int]]()
		if let orderDtl = orderDetails
		{
            if orderDtl.deliveryOption == ENUM_DeliveryOption.Standard.rawValue {
                constraintMarginHeight.constant = 0
                viewExpressDelivery.isHidden = true
            } else {
                constraintMarginHeight.constant = 30
                viewExpressDelivery.isHidden = false
            }
            
            
            if orderDtl.orderStatus == enumOrderStatus.delivered.rawValue
            {
                isPastOrderDetails = true
            }
			arrReceipt.removeAll()
			for store in orderDtl.stores!
			{
				storeIndex[rowcount] = strIndex
				if !(store.orderReceipt?.isEmpty ?? true)
				{
					arrReceipt.append(store.orderReceipt ?? "")
				}
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
			cellType.removeAll()
			
			
			if let driver = orderDtl.driverDetail
			{
				if driver.firstName != nil
				{
					driverDetails = driver
					let imgUrl = driver.userImage!.getUserImageURL().absoluteString//URL_USER_IMAGES + (driver.userImage ?? "")
					let rating = driver.rating ?? 0
					driverRating.value = CGFloat(rating)
					imgDriver.sd_setImage(with: URL(string: imgUrl), placeholderImage: USER_AVTAR, context: nil)
					lblDriverName.text = (driver.firstName ?? "") + " " + (driver.lastName ?? "")
					isDriverAvailable = true
					UIView.animate(withDuration: 0.5, animations: {
						self.driverViewHeight.constant = 135
						self.view.layoutIfNeeded()
					}	)
                    self.btnTrackOrder.isHidden = false
                        if isPastOrderDetails
                        {/*
                            switch orderDtl.orderStatus {
                            case enumOrderStatus.accepted.rawValue,enumOrderStatus.dispatched.rawValue,enumOrderStatus.delivered.rawValue  :
                                btnChatWIthDriver.isHidden = false
                                break
                          
                            default :
                                btnChatWIthDriver.isHidden = true
                                break
                            }
                            */
                            self.btnChatWIthDriver.isHidden  = false
                            self.btnTrackOrder.isHidden = true
                        }
				}
                else
                {
                    isDriverAvailable = false
                    UIView.animate(withDuration: 0.1, animations: {
                        self.driverViewHeight.constant = 0
                        self.view.layoutIfNeeded()
                    }    )
                    
                }
			} else
			{
				isDriverAvailable = false
				UIView.animate(withDuration: 0.1, animations: {
					self.driverViewHeight.constant = 0
					self.view.layoutIfNeeded()
				}	)
				
			}
			if let billingDetails = orderDtl.billingDetail{
				let rsCount = billingDetails.registeredStores?.count ?? 0
				let msCount = billingDetails.manualStores?.count ?? 0
				 registeredStoreCount = rsCount
				 manualStoreCount = msCount
				
				billingRowCount = rsCount + msCount + 1
				if rsCount == 0
				{
					billingRowCount += 1
				}
			}
		}
		self.tableView.reloadData()
	}
	
	//MARK:- NOTIFICATION CENTER OBSERVER
	
	@objc func updateOrderCanceled(notification:Notification){
		self.navigationController?.popViewController(animated: true)
	}
	@objc func updateOrderStatus(notification:Notification){
		getOrderDetails(of: orderDetails?.orderId ?? 0)
		/*	if let d = notification.userInfo
		{
			if arrCurrentOrder.count > 0 {
				if d["order_id"] as? Int == arrCurrentOrder[0].orderId {
					if let currStatus = d["order_status"] as? String
					{
						ShowToast(message: "Status Update Called. \n Status : \(currStatus)")
						print("Current Order Stuas :: ",currStatus)
						//UPDATE STATUS IN TIME LINE
						if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: enumsectionsOfDetails.orderStatus.rawValue)) as? OrderStatusTVCell
						{
							cell.viewOrderStatus.currentIndex = 0
							switch currStatus {
							case enumOrderStatus.accepted.rawValue :
								cell.viewOrderStatus.currentIndex = 0
								break
							case enumOrderStatus.dispatched.rawValue :
									cell.viewOrderStatus.currentIndex = 1
								break
							case enumOrderStatus.delivered.rawValue :
									cell.viewOrderStatus.currentIndex = 2
								break
							case enumOrderStatus.cancelled.rawValue :
									cell.viewOrderStatus.currentIndex = -1
								break
							default :
									cell.viewOrderStatus.currentIndex = -1
								break
							}
						}
						
					}
				}
			}
		}*/
		//self.tableView.reloadData()
		
	}
}


extension OrderDetailsVC : UITableViewDelegate, UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		return orderDetails != nil ? 7 : 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case enumsectionsOfDetails.orderItems.rawValue:
			return rowsInSection[0]
		case enumsectionsOfDetails.StoreReceipts.rawValue:
			return arrReceipt.count > 0 ? 1 : 0
		case enumsectionsOfDetails.orderStatus.rawValue:
			if isPastOrderDetails
            {
                return 1
            }
            return isDriverAvailable ? 1 : 0
		case enumsectionsOfDetails.billDetails.rawValue:
			return billingRowCount
		case enumsectionsOfDetails.note.rawValue:
            if isPastOrderDetails
            { return 0 }
			return manualStoreCount > 0 ? 1 : 0
        case enumsectionsOfDetails.ScanQRButton.rawValue:
            return isPastOrderDetails ? 0 : 1
        case enumsectionsOfDetails.driverNote.rawValue:
            return orderDetails?.driverNote?.count == 0 ? 0 : 1
		default:
            
			return 1
		}
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
			case enumsectionsOfDetails.note.rawValue:
				let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
				returnedView.backgroundColor = VIEW_BG_COLOR//.groupTableViewBackground
				return returnedView
			case enumsectionsOfDetails.billDetails.rawValue:
				let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
				returnedView.backgroundColor =  VIEW_BG_COLOR//.groupTableViewBackground
				return returnedView
			case enumsectionsOfDetails.StoreReceipts.rawValue:
                let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
                returnedView.backgroundColor =  VIEW_BG_COLOR//.groupTableViewBackground
                return returnedView
            case  enumsectionsOfDetails.driverNote.rawValue:
                if orderDetails?.driverNote?.count == 0 {
                    return UIView()
                }else {
                   let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
                   returnedView.backgroundColor = VIEW_BG_COLOR//.groupTableViewBackground
                   return returnedView
                }
			default:
				return UIView()
		}
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch section {
        case enumsectionsOfDetails.note.rawValue:
            return 5
			case enumsectionsOfDetails.billDetails.rawValue:
				return 5
			case enumsectionsOfDetails.StoreReceipts.rawValue:
				return 5
            case enumsectionsOfDetails.driverNote.rawValue:
                return orderDetails?.driverNote?.count == 0 ? 0 : 5
			default:
				return 0
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		switch indexPath.section {
		case enumsectionsOfDetails.orderStatus.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusTVCell", for: indexPath) as! OrderStatusTVCell
			if !isPastOrderDetails
            {
                let status  = orderDetails?.orderStatus ?? ""
                switch status {
                case enumOrderStatus.accepted.rawValue :
                    cell.viewOrderStatus.currentIndex = 0
                    break
                case enumOrderStatus.dispatched.rawValue :
                        cell.viewOrderStatus.currentIndex = 1
                    break
                case enumOrderStatus.delivered.rawValue :
                        cell.viewOrderStatus.currentIndex = 2
                    break
                case enumOrderStatus.cancelled.rawValue :
                        cell.viewOrderStatus.currentIndex = -1
                    break
                default :
                        cell.viewOrderStatus.currentIndex = -1
                    break
                }
            }
            else
            {
                cell.viewOrderStatus.currentIndex = 2
            }
			return cell
		case enumsectionsOfDetails.orderItems.rawValue:
			switch arrCellType[0][indexPath.row] {
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
						cell.viewTimer.isHidden  = !isDriverAvailable
						
						////
						if let storeDetails  = orderDetails?.stores?[storeIndex[indexPath.row] ?? 0]
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
								cell.imgStoreLogo.image = UIImage(named: "place_holder")?.withRenderingMode(.alwaysTemplate)
								cell.imgStoreLogo.tintColor = .gray
							}
							cell.orderId = orderDetails?.orderId ?? 0
							//UserDefaults.standard.set(second, forKey: "oneMinTimerSec_\(orderId)")
							let orderStatus = orderDetails?.orderStatus ?? ""
							cell.viewTimer.isHidden = true
							cell.btnReSchedule.isHidden  = true
                            if !isPastOrderDetails
                            {
                                if orderStatus == "Placed"
                                {
                                    let dateStr = orderDetails?.orderDate ?? ""
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
                                        cell.lblTimerRunningTime .reset()
                                        cell.viewTimer.isHidden = false
                                        cell.btnReSchedule.isHidden  = true
                                        cell.lblTimerRunningTime.tag = (indexPath.section*100)+indexPath.row
                                        cell.lblTimerRunningTime.accessibilityHint = "ThreeMin"
                                        //cell.lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
                                        cell.lblTimerRunningTime.setCountDownTime(TimeInterval(seconds))
                                        cell.lblTimerRunningTime.start()
                                        //cell.lblTimerRunningTime.delegate = self
                                        self.isReSceduleAvailable = false
                                    }
                                    else
                                    {
                                        cell.viewTimer.isHidden = true
                                        self.isReSceduleAvailable = true
                                        cell.btnReSchedule.isHidden  = true
                                    }
                                }
                                else if orderStatus == "Accepted" || orderStatus == "Dispatch"
                                {
                                    cell.viewTimer.isHidden = false
                                    
                                    if (cell.lblTimerRunningTime.accessibilityHint == "Y"){
                                    }else {
                                        let dateStr = orderDetails?.updatedServerTime ?? ""
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                        
                                        var orderDate = dateFormatter.date(from:dateStr)!
                                        orderDate = orderDate.UTCtoLocal().toDate()!
                                        let difference = Calendar.current.dateComponents([.second], from: orderDate, to: Date())
                                        var seconds = difference.second ?? 0
                                        print(seconds)
                                        //setUpTimerLabel(indexPath: indexPath, second: seconds)
                                        cell.lblTimerRunningTime.accessibilityHint = "Custom"
                                        let mSec = orderDetails?.timerValue ?? 0
                                        if seconds < mSec
                                        {
                                            seconds = mSec - seconds
                                            if seconds <= 180
                                          {
                                              //Api Calling For reset Timer
                                              let d = ["user_id" : USER_OBJ?.userId ?? 0,
                                                       "order_id" : orderDetails?.orderId ?? 0] as [String : Any]
                                              APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                                          }
                                            cell.lblTimerRunningTime.delegate = self
                                            cell.lblTimerRunningTime .reset()
                                            //										cell.lblTimerRunningTime.timeFormat = "mm:ss"
                                            //										cell.lblTimerRunningTime.timerType = MZTimerLabelTypeTimer
                                            cell.lblTimerRunningTime.addTimeCounted(byTime: TimeInterval(seconds))
                                            cell.lblTimerRunningTime.start()
                                            //cell.lblTimerRunningTime.delegate = self
                                            
                                        }
                                        else if seconds > mSec
                                        {
                                            cell.lblTimerRunningTime.text = "..."
                                            
                                                //Api Calling For reset Timer
                                                let d = ["user_id" : USER_OBJ?.userId ?? 0,
                                                         "order_id" : orderDetails?.orderId ?? 0] as [String : Any]
                                                APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                                           
                                        }
                                    }
                                }
                                else
                                {
                                    cell.viewTimer.isHidden = false
                                    cell.btnReSchedule.isHidden  = true
                                    cell.lblTimerRunningTime.text = "00:00"
                                }
                            }
                            else
                            {
                                cell.viewTimer.isHidden = true
                                cell.btnReSchedule.isHidden = true
                            }
						}
						////
						cell.selectionStyle = .none
						return cell
					case enumOrderCells.storeDetails.rawValue:
						let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
						if let storeDetails  = orderDetails?.stores?[storeIndex[indexPath.row] ?? 0]
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
								cell.imgStoreLogo.image = UIImage(named: "place_holder")?.withRenderingMode(.alwaysTemplate)
								cell.imgStoreLogo.tintColor = .gray
							}
						}
						cell.selectionStyle = .none
						return cell
					case enumOrderCells.storeItem.rawValue:
						let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderItemsTVCell", for: indexPath) as! CurrentOrderItemsTVCell
						if let storeDetails  = orderDetails?.stores?[storeIndexForProduct[indexPath.row] ?? 0]
						{
							if let product  = storeDetails.products?[arrStoreProductIndex[0][storeDetails.storeId ?? 0]?[indexPath.row] ?? 0]
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
						cell.outerView.clipsToBounds = true
						cell.outerView.layer.cornerRadius = 8
						cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
						cell.innerView.clipsToBounds = true
						cell.innerView.layer.cornerRadius = 8
						cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
						let dateStr = orderDetails?.orderDate ?? ""
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
						var date = dateFormatter.date(from:dateStr)!
                        date = date.UTCtoLocal().toDate()!
						cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
						cell.selectionStyle = .none
						return cell
					
					default:
						break
				}
			break
		case enumsectionsOfDetails.note.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC
			{
				cell.lblTnCNote.attributedText = add(stringList: ["When Driver Attachd the receipt. After then manual Sore items Bill will shown. "], font: UIFont(name: "Montserrat-Regular", size: 14.0)!,forSingleNote: true)
				cell.selectionStyle = .none
				return cell
			}
        case enumsectionsOfDetails.driverNote.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC
            {
                cell.lblTnCNote.attributedText = addDriverNote(stringList: ["\(orderDetails?.driverNote ?? "")"], font: UIFont(name: "Montserrat-Regular", size: 14.0)!,forSingleNote: true)
                cell.selectionStyle = .none
                return cell
            }
		case enumsectionsOfDetails.billDetails.rawValue:
			let couponDiscount = orderDetails?.billingDetail?.couponDiscount ?? 0
			let orderDiscount = orderDetails?.billingDetail?.orderDiscount ?? 0
			if indexPath.row == 0 && registeredStoreCount == 0
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
				cell.billDetailsHeaderHeight.constant = 30
				cell.viewRegisterdStoreDetails.isHidden = true
				cell.StoreDiscountView.isHidden = true
				cell.viewOrderAndCouponDiscount.isHidden = true
				cell.viewBottomSaperator.isHidden = true
				cell.selectionStyle = .none
				return cell
			}
			else if indexPath.row == 0 && registeredStoreCount == 1
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
				cell.billDetailsHeaderHeight.constant = 30
				cell.viewRegisterdStoreDetails.isHidden = false
				cell.viewBottomSaperator.isHidden = false
				cell.lblRegisterdStoreName.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
				cell.StoreDiscountView.isHidden = orderDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                   cell.lblStoreNameDiscount.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                   cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
                               }
				if couponDiscount == 0 && orderDiscount == 0
				{
					cell.viewOrderAndCouponDiscount.isHidden = true
				}
				else
				{
					cell.viewOrderDiscount.isHidden  = orderDiscount == 0
					cell.viewCouponDiscount.isHidden = couponDiscount == 0
					cell.lblCouponDiscountAmt.text = "\(Currency)\(String(format: "%.2f", couponDiscount))"
					cell.lblOrderDiscountAmt.text = "\(Currency)\(String(format: "%.2f",orderDiscount))"
				}
				cell.selectionStyle = .none
				return cell
			}
			else if indexPath.row == 0 && registeredStoreCount > 1
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
				cell.billDetailsHeaderHeight.constant = 30
				cell.viewRegisterdStoreDetails.isHidden = false
				cell.viewBottomSaperator.isHidden = false
				cell.lblRegisterdStoreName.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
				cell.StoreDiscountView.isHidden = orderDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                   cell.lblStoreNameDiscount.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                   cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
                               }
				cell.viewOrderAndCouponDiscount.isHidden = true
				cell.selectionStyle = .none
				return cell
			}else if  indexPath.row < registeredStoreCount
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
				cell.billDetailsHeaderHeight.constant = 0
				cell.viewRegisterdStoreDetails.isHidden = false
				cell.viewBottomSaperator.isHidden = false
				cell.lblRegisterdStoreName.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0))"
				cell.StoreDiscountView.isHidden = orderDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                   cell.lblStoreNameDiscount.text = "\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                   cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
                               }
				if indexPath.row == (orderDetails?.billingDetail?.registeredStores?.count  ?? 0 - 1)
				{
					if couponDiscount == 0 && orderDiscount == 0
					{
						cell.viewOrderAndCouponDiscount.isHidden = true
					}
					else
					{
						cell.viewOrderDiscount.isHidden  = orderDiscount == 0
						cell.viewCouponDiscount.isHidden = couponDiscount == 0
						cell.lblCouponDiscountAmt.text = "\(Currency)\(String(format: "%.2f",couponDiscount))"
						cell.lblOrderDiscountAmt.text = "\(Currency)\(String(format: "%.2f",orderDiscount))"
					}
				}
				else{
					cell.viewOrderAndCouponDiscount.isHidden = true
				}
				cell.selectionStyle = .none
				return cell
			}
			else if (registeredStoreCount == 0 && indexPath.row > 0 && manualStoreCount >= indexPath.row ) || (registeredStoreCount <= indexPath.row && (registeredStoreCount + manualStoreCount) > indexPath.row)
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderManualStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderManualStoreBillDetailsTVCell
				var indexcount = 0
				if registeredStoreCount == 0
				{
					indexcount = indexPath.row - 1
				}
				else
				{
					indexcount = indexPath.row - registeredStoreCount
				}
				let manualStoreDetials = orderDetails?.billingDetail?.manualStores?[indexcount]
				cell.lblStoreName.text = "\(manualStoreDetials?.storeName ?? "") Items Total"
                isManualStorePriceUpdated = manualStoreDetials?.storeAmount ?? 0 != 0
				cell.lblStoreAmt.text = manualStoreDetials?.storeAmount ?? 0 == 0 ? "pending" : "\(Currency)\(String(format: "%.2f",manualStoreDetials?.storeAmount ?? 0))"
				cell.selectionStyle = .none
				return cell
			}
			else
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderOtherBillDetailsTVCell", for: indexPath) as! ConfirmOrderOtherBillDetailsTVCell
                if manualStoreCount > 0
                {
                    cell.lblToPayAmt.text = isManualStorePriceUpdated ? "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.totalPay ?? 0))" : "pending"
                }
                else
                {
                    cell.lblToPayAmt.text = "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.totalPay ?? 0))"
                }
				cell.lblServiceChargeAmt.text = orderDetails?.billingDetail?.serviceCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.serviceCharge ?? 0))"
				cell.lblDeliveryFeeAmt.text = orderDetails?.billingDetail?.deliveryCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.deliveryCharge ?? 0))"
				cell.viewShoppingCharge.isHidden = orderDetails?.billingDetail?.shoppingFee ?? 0 == 0
				cell.lblShoppingFeeAmt.text = "\(Currency)\(String(format: "%.2f",orderDetails?.billingDetail?.shoppingFee ?? 0))"
				cell.selectionStyle = .none
				return cell
			}
		case enumsectionsOfDetails.StoreReceipts.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "DriversReceiptTVCell", for: indexPath) as! DriversReceiptTVCell
			cell.collectionView.register("CategoriesCVCell")
			cell.collectionView.delegate = self
			cell.collectionView.dataSource = self
			cell.collectionView.reloadData()
			cell.selectionStyle = .none
			return cell
		case enumsectionsOfDetails.ScanQRButton.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTVCell", for: indexPath) as! ButtonTVCell
			if !isDriverAvailable
			{
                cell.button.isHidden = !isReSceduleAvailable
				cell.button.setTitle("Re-Schedule", for: .normal)
			}
			else
			{
                cell.button.isHidden = false
                let status  = orderDetails?.orderStatus ?? ""
                switch status {
                case enumOrderStatus.dispatched.rawValue :
                   break
                default :
                    break
                  }
				cell.button.setTitle("Scan QR", for: .normal)
			}
			cell.button.addTarget(self, action: #selector(actionShowScanner( _ :)), for: .touchUpInside)
			return cell
		default:
			break
		}
	
		return UITableViewCell()
	}
	
	@objc func actionShowScanner(_ sender : UIButton)
	{
		if isDriverAvailable
        {
            #if DEBUG
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmedOrderVC") as! ConfirmedOrderVC
             nextViewController.setValue(orderId)
             self.navigationController?.pushViewController(nextViewController, animated: true)
            #else
            let QRscanner =  QRCodeScannerController()
            QRscanner.delegate = self
            self.present(QRscanner, animated: true, completion: nil)
            #endif
        }
		else
		{
			//ShowToast(message: "Under Development.")
            reScheduleOrder(orderId: orderId)
		}
	}
}
//MARK:- Scanner Delegate
extension OrderDetailsVC : QRScannerCodeDelegate {
    
    func qrCodeScanningDidCompleteWithResult(result: String) {
           print("result:\(result)")
      //  ShowToast(message: result)
        if result == "\(orderId)"
        {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmedOrderVC") as! ConfirmedOrderVC
            //nextViewController.setStoreId(storeId: storeDetails.storeId ?? 0 )
            nextViewController.setValue(orderId)
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func qrCodeScanningFailedWithError(error: String) {
          print("error:\(error)")
    }
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
    }
    
    
}
extension OrderDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return arrReceipt.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCVCell", for: indexPath) as? CategoriesCVCell
		{
			let imgUrl = URL_ORDER_RECEIPT_IMAGES + arrReceipt[indexPath.row]
			cell.imageCategories.sd_setImage(with: URL(string: imgUrl),placeholderImage: QUE_AVTAR, completed: nil)
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.height - 10, height: collectionView.bounds.height - 10)
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! CategoriesCVCell
		let image = cell.imageCategories.image ?? UIImage()
		let imageViewer = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewerVC") as! ImageViewerVC
		imageViewer.setImage(image: image)
		self.navigationController?.pushViewController(imageViewer, animated: true)
		//self.present(imageViewer, animated: true, completion: nil)
	}
}

extension OrderDetailsVC : MZTimerLabelDelegate {
	func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        print("finish")
        let tag = timerLabel.tag
               let section = tag / 100
               let row = tag % 100
               if timerLabel.accessibilityHint ?? "" ==  "ThreeMin"
               {
                   let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? CurrentOrderHeaderTVCell
                   cell?.viewTimer.isHidden = true
                    self.isReSceduleAvailable = true
            let cell1 = tableView.cellForRow(at: IndexPath(row: 0, section: enumsectionsOfDetails.ScanQRButton.rawValue)) as? ButtonTVCell
            cell1?.button.isHidden = false
               }
    }
    func timerLabel(_ timerLabel: MZTimerLabel!, countingTo time: TimeInterval, timertype timerType: MZTimerLabelType) {
        if isInScreen
        {
            //print("Order Details")
            let orderStatus = orderDetails?.orderStatus ?? ""
            if orderStatus == "Accepted" || orderStatus == "Dispatch"
            {
                if time <= 180.0
                {
                    //Api Calling For reset Timer
                    let d = ["user_id" : USER_OBJ?.userId ?? 0,
                             "order_id" : orderDetails?.orderId ?? 0] as [String : Any]
                    APP_DELEGATE.socketIOHandler?.UpdateTimer(dic: d)
                }
            }
        }
    }
}
