//
//  CartViewVC.swift
//  QueDrop
//
//  Created by C100-104 on 25/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import CoreLocation
protocol ManageListOfItemsInCartDelegate  {
	func updatedHeightRorRow(index : Int ,height : CGFloat)
}

class CartViewVC: BaseViewController {

	
	@IBOutlet var btnBack: UIButton!
	@IBOutlet var btnHome: UIButton!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var viewAddress: UIView!
	@IBOutlet var imageAddressType: UIImageView!
	@IBOutlet var lblUserAddressName: UILabel!
	@IBOutlet var lblUserAddress: UILabel!
	@IBOutlet var lblTime: UILabel!
	
	@IBOutlet var bottomView: UIView!
	@IBOutlet var lblItemPrice: UILabel!
	@IBOutlet var btnPlaceOrder: UIButton!
	@IBOutlet var viewEmptyCart: UIView!
	@IBOutlet var shimmerView: UIView!
	
	//ENUM
	enum enumCartSections : Int {
		case paymentMethods = -1
		case storesWithProduct
	//	case ReccuranceButton
		case deliveryType
        case viewDrivers
		case Coupon
		case billDetails
		case termAndCondition
		case note
		
	}
	enum termNoteType : String
	{
		case all = "All"
		case manualStore = "ManualStore"
		case recurringOrder = "RecurringOrder"
	}
	//var
    var isDeleteViewiWillOpen = false
    var deleteCustomView : DeleteCustomView?
    
	var note = ""
    var isCustomerOutOfRange = false
	var isItemRemovedFromCart = false
	var isTermAndConditionVisible = false
	var appliedCouponCode = ""
	var termNote : [CartTermNotes] = []
	var sectionCount = 0{
		didSet{
			if sectionCount == 0
			{
				viewAddress.isHidden = true
				bottomView.isHidden = true
				viewEmptyCart.isHidden = true
				shimmerView.isHidden = false
			}
			else if sectionCount == 1
			{
				viewAddress.isHidden = true
				bottomView.isHidden = true
				viewEmptyCart.isHidden = false
				shimmerView.isHidden = true
			}
			else
			{
				viewAddress.isHidden = false
				bottomView.isHidden = false
				shimmerView.isHidden = true
			}
		}
	}
	var itemsHeight : CGFloat = 0.0
	var itemsHeightAry : [Int : CGFloat] = [Int : CGFloat](){
		didSet{
				print("Ary",itemsHeightAry)
		}
	}
	var isDisplayingProduct = false
	var currStoreIndex = -1
	var isRecurringOrder = 0
	var currStoreId = 0
	var displyedProduct = 0
	var IsStoreDetails = [Int : String]() //[ indexpath : (Store / Product)]
	var StoreIndex = [Int : Int]() // [StoreIndex : indexpath.row]
	var itemsRowIndex = [Int : Int]() // [(StoreIndex / ProductIndex) : indexpath.row]
	var storewithProductCount = [Int : Int]() // [StoreId : ProductCount]
	var itemCount = [Int : Int]()
	var cartArray : [CartItems] = []
	var amountDetails : AmountDetails? = nil
	var itemsCount  = 0
	var finalAmt : Float = 0.0
	var deliveryTime = 0
    var storeCount = 0
    var manualStoreCount = 0
	var ismannualStoreAvailable = false
	var isTermAccepted = false
	var isCouponApplied = false
    var selectedDeliveryOption = ENUM_DeliveryOption.Standard.rawValue
    var isFromExplore = false
    
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		isItemRemovedFromCart = false
        isTermAccepted = isTermAndConditionTapped
        currScreen = .cart
	/*	if isLoginOrVerifyForOrder
		{
			if !isGuest
			{
				placeOrder()
			}
		}*/
		getCartDetails()
    }
	override func viewWillAppear(_ animated: Bool) {
		isTabbarHidden(true)
        currScreen = .cart
		if newItemAddedFromStore
		{
			newItemAddedFromStore = false
			getCartDetails()
		}
	}
	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func actionHome(_ sender: Any) {
        if isFromExplore {
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.tabBarController?.selectedIndex = 0
//            CATransaction.begin()
//            CATransaction.setCompletionBlock {
//                DispatchQueue.main.async {
//                  //  self.navigationController?.tabBarController?.selectedIndex = 0
//                    guard let VCS = self.navigationController?.viewControllers else {return }
//                    for controller in VCS {
//                        if controller.isKind(of: CustomerTabBarVC.self) {
//                            let tabVC = controller as! UITabBarController
//                            tabVC.selectedIndex = 0
//                            self.navigationController?.popToRootViewController(animated: true)
//                        }
//                    }
//                }
//            }
//            self.navigationController?.popViewController(animated: true)
//            CATransaction.commit()
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
		
	}
	
	@IBAction func actionPlaceOrder(_ sender: Any) {
        if isCustomerOutOfRange
        {
            ShowToast(message: "Please select near by Store Or change the location  \n Store Locations seems Out Of 20Km Range ")
        }
        else if isGuest
        {
            if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as? MobileVerificationVC
            {
                //LoginView.setupForGuest()
                isLoginOrVerifyForOrder = true
                let transition:CATransition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromTop
                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                self.navigationController?.pushViewController(LoginView, animated: false)
                //self.navigationController?.pushViewController(LoginView, animated: true)
            }
        } else if isTermAccepted
		{
			if validate()
			{
				 if USER_OBJ?.isPhoneVerified ?? 0 == 0{
					let storyboard = UIStoryboard(name: "Login", bundle: nil)
					if let PhoneVarifiedVC = storyboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as? MobileVerificationVC
					{
						isLoginOrVerifyForOrder = true
                        
						//LoginView.isPresented(true)
						//self.present(LoginView, animated: true	, completion: nil)
						let transition:CATransition = CATransition()
						transition.duration = 0.5
						transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
						transition.type = CATransitionType.push
						transition.subtype = CATransitionSubtype.fromTop
						self.navigationController?.view.layer.add(transition, forKey: kCATransition)
						self.navigationController?.pushViewController(PhoneVarifiedVC, animated: false)
						//self.navigationController?.pushViewController(PhoneVarifiedVC, animated: true)
					}
				}else{
					placeOrder()
				}
			} else {
				ShowToast(message: "Selected Store is Closed For now, Please Select another time To place Order.")
			}
		}else{
			ShowToast(message: "Please agree with our terms and conditions.")
		}
	}
	//MARK:- Functions
	func placeOrder()
	{
		print("Order Placed.")
		isLoginOrVerifyForOrder = false
        PlaceOrder()
	}
	func SetUpStoreItem()
	{
		//var store_index = 0
        if isItemRemovedFromCart
        {
            isItemRemovedFromCart = false
            if cartArray.count == 0
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
		sectionCount = cartArray.count != 0 ? 6 : sectionCount
        storeCount = 0
        manualStoreCount = 0
		termNote.removeAll()
		for index in 0..<cartTermNotes.count
		{
			if cartTermNotes[index].noteType ?? "" == termNoteType.manualStore.rawValue
			{
				if ismannualStoreAvailable
				{
					termNote.append(cartTermNotes[index])
				}
				
			}
			else if cartTermNotes[index].noteType ??  "" == termNoteType.recurringOrder.rawValue
			{
				if isRecurringOrder == 1 || isCouponApplied
				{
					termNote.append(cartTermNotes[index])
				}
			}
			else if cartTermNotes[index].noteType ??  "" == termNoteType.all.rawValue
			{
				termNote.append(cartTermNotes[index])
			}
		}
		if sectionCount == 0
		{
			viewEmptyCart.isHidden = true
			shimmerView.isHidden = false
		}
		else if sectionCount == 1
		{
			viewEmptyCart.isHidden = false
			shimmerView.isHidden = true
		}
		else
		{
			viewEmptyCart.isHidden = true
			shimmerView.isHidden = true
			self.setCommonDetails()
			var indexRow = -1
			var storeindex = 0
			itemsRowIndex.removeAll()
			IsStoreDetails.removeAll()
			StoreIndex.removeAll()
			//itemsRowIndex[0] = 0
           
			for cart in cartArray
			{
                storeCount += 1
				indexRow += 1
				itemsRowIndex[indexRow] = storeindex
				IsStoreDetails[indexRow] = "Store"
				var storeID = cart.storeDetails?.storeId ?? 0
				if storeID == 0
				{
					storeID = cart.storeDetails?.userStoreId ?? 0
                    manualStoreCount += 1
				}
				
				let productcount = storewithProductCount[storeID] ?? 0
				StoreIndex[indexRow] = storeindex
				for index in 0..<productcount
				{
					indexRow += 1
					StoreIndex[indexRow] = storeindex
					if index == productcount - 1
					{
						IsStoreDetails[indexRow] = "LastProduct"
					}
					else
					{
						IsStoreDetails[indexRow] = "Product"
					}
					itemsRowIndex[indexRow] = index
				}
				storeindex += 1
			}
		}
		
		self.tableView.reloadData()
	}
	func setCommonDetails()
	{
		lblUserAddressName.text = "Deliver to \(defaultAddress?.addressTitle ?? "")"
		lblUserAddress.text = defaultAddress?.address ?? ""
		
		lblItemPrice.text = "\(itemsCount) items | \(Currency) \(finalAmt)"
		self.lblTime.text = "\(self.deliveryTime) second"
		if self.deliveryTime > 60 //Seconds
		{
			let min = self.deliveryTime / 60
			self.lblTime.text = "\(min) min"
			if min > 60
			{
				let hours = min / 60
				self.lblTime.text = "\(hours) hour"
			}
		}
		if defaultAddress?.addressType?.lowercased() ==  "home"
		{
			imageAddressType.image = #imageLiteral(resourceName: "home_type_selected ")
		}
		else if defaultAddress?.addressType?.lowercased() ==  "work"
		{
			imageAddressType.image = #imageLiteral(resourceName: "office_type_selected")
		}
		else if defaultAddress?.addressType?.lowercased() ==  "hotel"
		{
			imageAddressType.image = #imageLiteral(resourceName: "hotel_type_selected")
		}
		else
		{
			imageAddressType.image = #imageLiteral(resourceName: "other_location_type_selected")
		}
	}
	func validate() -> Bool
	{
		var isOpen = false
		for cart in cartArray
		{
			
			if cart.storeDetails?.schedule?.count != 0
			{
				if cart.storeDetails?.canProvideService ?? 0 == 1
				{
					let index = self.matchTiming( storeDetails: cart.storeDetails!)
					isOpen = index > -1
					if !isOpen
					{
						return false
					}
				}
			}
		}
		return true
	}
	func matchTiming(storeDetails : StoreDetails) -> Int
	{
		let now = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat  = "EEEE"
		let dayInWeek = dateFormatter.string(from: now)
		var curr_index = -1
		for schedule in storeDetails.schedule ?? []
		{
			curr_index += 1
			if schedule.weekday?.lowercased() ?? "" == dayInWeek.lowercased()
			{
				let openingTime = schedule.openingTime ?? ""
				let o_hour = Int(openingTime.dropLast(6)) ?? 0
				let o_min = Int((openingTime.dropLast(3)).dropFirst(3)) ?? 0
				let opening = now.dateAt(hours: o_hour, minutes: o_min)
				let closingTime = schedule.closingTime ?? ""
				let c_hour = Int(closingTime.dropLast(6)) ?? 0
				let c_min = Int((closingTime.dropLast(3)).dropFirst(3)) ?? 0
				let closing = now.dateAt(hours: c_hour, minutes: c_min)
				
				if now >= opening &&
				  now <= closing
				{
				  return curr_index
				}
			}
		}
		
		//let schedule = self.storeDetails?.schedule?[dayOfWeek]
		
		return -1
	}
/*	func matchTiming(dayOfWeek : Int) -> Int
	{
		let now = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat  = "EEEE"
		let dayInWeek = dateFormatter.string(from: now)
		var curr_index = -1
		for schedule in self.storeDetails?.schedule ?? []
		{
			curr_index += 1
			if schedule.weekday?.lowercased() ?? "" == dayInWeek.lowercased()
			{
				let openingTime = schedule.openingTime ?? ""
				let o_hour = Int(openingTime.dropLast(6)) ?? 0
				let o_min = Int((openingTime.dropLast(3)).dropFirst(3)) ?? 0
				let opening = now.dateAt(hours: o_hour, minutes: o_min)
				let closingTime = schedule.closingTime ?? ""
				let c_hour = Int(closingTime.dropLast(6)) ?? 0
				let c_min = Int((closingTime.dropLast(3)).dropFirst(3)) ?? 0
				let closing = now.dateAt(hours: c_hour, minutes: c_min)
				
				if now >= opening &&
				  now <= closing
				{
				  return curr_index
				}
			}
		}
		
		//let schedule = self.storeDetails?.schedule?[dayOfWeek]
		
		return -1
	}*/
}
//MARK:- TableView Delegate
extension CartViewVC : UITableViewDelegate , UITableViewDataSource
{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionCount
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == enumCartSections.termAndCondition.rawValue //&& isTermAndConditionVisible
		{
			return  termNote.count != 0 ? termNote.count + 1 : 0
		}
        if section == enumCartSections.Coupon.rawValue
        {
            return storeCount == manualStoreCount ? 0 : 1
            
        }
		return section == enumCartSections.storesWithProduct.rawValue ? (cartArray.count + itemsCount) : 1
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
			case enumCartSections.storesWithProduct.rawValue:
				break
			case enumCartSections.note.rawValue:
				break
			default:
				let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
				returnedView.backgroundColor = .groupTableViewBackground
				return returnedView
		}
		return UIView()
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 5
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.section {
		case enumCartSections.storesWithProduct.rawValue:
			//if isDisplayingProduct && (storewithProductCount[currStoreId] ?? 0) - 1 > displyedProduct
			if IsStoreDetails[indexPath.row] ?? "" == "Product"
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedItemsOfStoreTVC", for: indexPath) as? SelectedItemsOfStoreTVC
						{
							if let product = cartArray[StoreIndex[indexPath.row] ?? 0].products?[itemsRowIndex[indexPath.row] ?? 0]
							{
								cell.lblProductName.text = product.productName ?? ""
								cell.lblQty.text  = "\(product.quantity ?? 0)"
								cell.btnDecreaseQty.addTarget(self, action: #selector(decreaseProductQty(_ :)), for: .touchUpInside)
								cell.btnCustomise.addTarget(self, action: #selector(customiseProduct(_ :)), for: .touchUpInside)
								cell.btnIncreaseQty.addTarget(self, action: #selector(increaseProductQty(_ :)), for: .touchUpInside)
								cell.btnRemoveItem.addTarget(self, action: #selector(removeProductFromCart(_ :)), for: .touchUpInside)
								let tag = indexPath.row
								//let tag  = ((StoreIndex[indexPath.row] ?? 0) * 100) + (itemsRowIndex[indexPath.row] ?? 0)
								print("Tag :: ",tag)
								cell.btnDecreaseQty.tag = tag
								cell.btnIncreaseQty.tag = tag
								cell.btnCustomise.tag = tag
								cell.btnRemoveItem.tag = tag
								if cartArray[StoreIndex[indexPath.row] ?? 0].storeDetails?.canProvideService ?? 0 == 0
								{
									cell.btnCustomiseHeight.constant = 0
									cell.btnCustomise.isHidden = true
									cell.lblTotalPrice.text = ""
									cell.lblProductAddons.text = "Total amount for product will be updated after  order purchased."
								}
								else
								{
									cell.lblTotalPrice.text = "\(Currency)\(String(format:"%.1f",product.productFinalPrice ?? 0))"
									if product.hasAddons ?? 0 == 1 || product.productOption?.count ?? 1 > 1
									{
										cell.btnCustomiseHeight.constant = 10
										cell.btnCustomise.isHidden = false
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
													else if option.optionName?.lowercased() == "default"
													{
													}
													else
													{
														addon.append(option.optionName ?? "")
													}
												}
											}
										}
										if addon.count == 0
										{
											cell.lblProductAddons.text = "Regular"
										}
										else
										{
											cell.lblProductAddons.text = addon.joined(separator: ", ")
										}
									}
									else
									{
										cell.btnCustomiseHeight.constant = 0
										cell.btnCustomise.isHidden = true
										cell.lblProductAddons.text = "Regular"
									}
									
									
								}
								
								cell.selectionStyle = .none
								displyedProduct += 1
								return cell
							}
						}
				
			}
			//else if isDisplayingProduct && ((storewithProductCount[currStoreId] ?? 0) - 1) == displyedProduct
			else if IsStoreDetails[indexPath.row] ?? "" == "LastProduct"
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedItemsOfStoreTVCLast", for: indexPath) as? SelectedItemsOfStoreTVC
						{
							if let product = cartArray[StoreIndex[indexPath.row] ?? 0].products?[itemsRowIndex[indexPath.row] ?? 0]
							{
								cell.btnDecreaseQty.addTarget(self, action: #selector(decreaseProductQty(_ :)), for: .touchUpInside)
								cell.btnIncreaseQty.addTarget(self, action: #selector(increaseProductQty(_ :)), for: .touchUpInside)
								cell.btnCustomise.addTarget(self, action: #selector(customiseProduct(_ :)), for: .touchUpInside)
								cell.btnRemoveItem.addTarget(self, action: #selector(removeProductFromCart(_ :)), for: .touchUpInside)
								let tag = indexPath.row
								//let tag  = ((StoreIndex[indexPath.row] ?? 0) * 100) + (itemsRowIndex[indexPath.row] ?? 0)
								print("Tag :: ",tag)
								cell.btnDecreaseQty.tag = tag
								cell.btnIncreaseQty.tag = tag
								cell.btnCustomise.tag = tag
								cell.btnRemoveItem.tag = tag
								cell.OuterView.clipsToBounds = true
								cell.OuterView.layer.cornerRadius = 8
								cell.OuterView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
								cell.InnerView.clipsToBounds = true
								cell.InnerView.layer.cornerRadius = 8
								cell.InnerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
								cell.lblProductName.text = product.productName ?? ""
								cell.lblQty.text  = "\(product.quantity ?? 0)"
								//cell.lblTotalPrice.text = "\(Currency)\(product.productFinalPrice ?? 0)"
								if cartArray[StoreIndex[indexPath.row] ?? 0].storeDetails?.canProvideService ?? 0 == 0
								{
									cell.btnCustomiseHeight.constant = 0
									cell.btnCustomise.isHidden = true
									cell.lblTotalPrice.text = ""
									cell.lblProductAddons.text = "Total amount for producst will be updated after  order purchased."
								}
								else
								{
									cell.lblTotalPrice.text = "\(Currency)\(String(format:"%.1f", product.productFinalPrice ?? 0))"
									if product.hasAddons ?? 0 == 1 || product.productOption?.count ?? 1 > 1
									{
										cell.btnCustomiseHeight.constant = 10
										cell.btnCustomise.isHidden = false
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
													else if option.optionName?.lowercased() == "default"
													{
													}
													else
													{
														addon.append(option.optionName ?? "")
													}
												}
											}
										}
										if addon.count == 0
										{
											cell.lblProductAddons.text = "Regular"
										}
										else
										{
											cell.lblProductAddons.text = addon.joined(separator: ", ")
										}
									}
									else
									{
										cell.btnCustomiseHeight.constant = 0
										cell.btnCustomise.isHidden = true
										cell.lblProductAddons.text = "Regular"
									}
									
									
								}
								
								
								cell.selectionStyle = .none
								isDisplayingProduct  = false
								displyedProduct = 0
								return cell
							}
						}
				
			}
			else if IsStoreDetails[indexPath.row] ?? "" == "Store"
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "StoreDetailsTVC", for: indexPath) as? StoreDetailsTVC
				{
					currStoreIndex += 1
					//itemsRowIndex[indexPath.row] = currStoreIndex
					if let storeDetails = cartArray[itemsRowIndex[indexPath.row] ?? 0].storeDetails
					{
						displyedProduct = 0
						
						isDisplayingProduct = true
						self.currStoreId = storeDetails.storeId ?? 0
						//cell.tableView.tag = indexPath.row + 1
						//cell.cartDelegate = self 
						//cell.products.removeAll()
						//cell.products.append(contentsOf:  cartArray[currStoreIndex].products ?? [])
						//itemCount = [storeDetails.storeId ?? 0 : cartArray[indexPath.section].products?.count ?? 0]
						
						cell.btnCancel.tag = cartArray[itemsRowIndex[indexPath.row] ?? 0].cartId ?? 0
						cell.btnCancel.addTarget(self, action: #selector(removeStoreFromOrder(_ :)), for: .touchUpInside)
						if let logoUrl = storeDetails.storeLogo
						{
							cell.imageStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
						}
						else
						{
							//cell.imageStoreLogo.image =
							cell.imageStoreLogo.image = QUE_AVTAR //UIImage(named: "place_holder")?.withRenderingMode(.alwaysTemplate)
							cell.imageStoreLogo.tintColor = .gray
						}
						let TapGesture = UITapGestureRecognizer(target: self, action: #selector(goToStore(_:)))
						cell.imageStoreLogo.addGestureRecognizer(TapGesture)
						cell.imageStoreLogo.isUserInteractionEnabled = true
						cell.imageStoreLogo.tag = indexPath.row
						//cell.imageStoreLogo.contentMode = .scaleAspectFill
						cell.lblStoreName.text  = storeDetails.storeName ?? ""
						cell.lblStoreAddress.text = storeDetails.storeAddress ?? ""
						//cell.tableView.reloadData()
						let lat = Double(storeDetails.latitude ?? "") ?? 0
						let lon = Double(storeDetails.longitude ?? "") ?? 0
                        cell.lblStoreDistance.text = self.Storedistance(lat1: lat, lon1: lon, in_time: false)
						
					}
					cell.selectionStyle = .none
					return cell
				}
			}
			
//		case enumCartSections.ReccuranceButton.rawValue:
//			if let cell = tableView.dequeueReusableCell(withIdentifier: "RecurringButtonTVC", for: indexPath) as? RecurringButtonTVC
//			{
//				cell.btnRecurranceOrder.addTarget(self, action: #selector(RecurranceOrder(_ :)), for: .touchUpInside)
//				cell.selectionStyle = .none
//				return cell
//			}
		case enumCartSections.paymentMethods.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTVC", for: indexPath) as? PaymentMethodTVC
			{
				cell.selectionStyle = .none
				return cell
			}
		case enumCartSections.deliveryType.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryTimeOptionTVC", for: indexPath) as? DeliveryTimeOptionTVC
			{
				/*cell.btnAdvanceOrder.addTarget(self, action: #selector(RecurranceOrder(_ :)), for: .touchUpInside)
				cell.btnAdvanceOrder.tag = 11
				cell.btnAdvanceOrderSelection.addTarget(self, action: #selector(RecurranceOrder(_ :)), for: .touchUpInside)
				cell.btnAdvanceOrderSelection.tag = 12
				cell.btnDeliveryNowSelection.addTarget(self, action: #selector(RecurranceOrder(_ :)), for: .touchUpInside)
				cell.btnDeliveryNowSelection.tag = 13*/
                
                cell.btnExpress.addTarget(self, action: #selector(btnExpressDeliveryClicked(btn:)), for: .touchUpInside)
                cell.btnStandard.addTarget(self, action: #selector(btnStandardDeliveryClicked(btn:)), for: .touchUpInside)
                
                if selectedDeliveryOption == ENUM_DeliveryOption.Standard.rawValue {
                    cell.imgStandard.isHighlighted = false
                    cell.imgExpress.isHighlighted = true
                } else {
                    cell.imgStandard.isHighlighted = true
                    cell.imgExpress.isHighlighted = false
                }
                
				cell.selectionStyle = .none
				return cell
			}
            
        case enumCartSections.viewDrivers.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewDriverCell", for: indexPath) as? ViewDriverCell
            {
                cell.selectionStyle = .none
                return cell
            }
            
		case enumCartSections.Coupon.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "CouponTVC", for: indexPath) as? CouponTVC
			{
				cell.lblDiscountAmount.isHidden = !isCouponApplied
				
				cell.lblDiscountAmount.text = "You Saved Additional \(Currency)\(amountDetails?.couponDiscountPrice ?? 0)"
				cell.selectionStyle = .none
				return cell
			}
		case enumCartSections.billDetails.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "BillDetailsOptionTVC", for: indexPath) as? BillDetailsOptionTVC
			{
                cell.lblDeliveryCharges.text = amountDetails?.deliveryCharge ?? 0 != 0 ? "\(Currency)\(String(format: "%.2f", amountDetails?.deliveryCharge ?? 0))" : "Free"
				cell.lblServiceCharges.text  = amountDetails?.serviceCharge ?? 0 != 0 ? "\(Currency)\(String(format: "%.2f",amountDetails?.serviceCharge ?? 0))" : "Free"
				
				cell.lblItemTotal.text  = "\(Currency)\(String(format: "%.2f",amountDetails?.totalItemsPrice ?? 0))"
				if amountDetails?.orderDiscountValue ?? 0 == 0 && amountDetails?.couponDiscountPrice ?? 0 == 0
				{
					cell.viewMainDiscount.isHidden = true
				}
				else
				{
					cell.viewMainDiscount.isHidden = false
					if amountDetails?.orderDiscountValue ?? 0 != 0 {
						cell.viewOrderDiscount.isHidden = false
						cell.lblOrderDiscount.text = "\(Currency)\(String(format: "%.2f",amountDetails?.orderDiscountValue ?? 0))"
					}else{
						cell.viewOrderDiscount.isHidden = true
					}
					if amountDetails?.couponDiscountPrice ?? 0 != 0
					{
						cell.viewCoupenDiscount.isHidden = false
						cell.lblCoupenDiscount.text = "\(Currency)\(String(format: "%.2f",amountDetails?.couponDiscountPrice ?? 0))"
					}else {
						cell.viewCoupenDiscount.isHidden = true
					}
				}
                if !ismannualStoreAvailable
                {
                    cell.shoppingLabelHeight.constant = 10
                    cell.lblShoppingFee.text = ""
                    cell.lblShoppingFeeLabel.text = ""
                    cell.btnShowShoppingFee.isHidden = true
                }
                else
                {
                    cell.shoppingLabelHeight.constant = 40
                    cell.btnShowShoppingFee.isHidden = false
                    cell.lblShoppingFee.text = amountDetails?.serviceCharge ?? 0 != 0 ? "\(Currency)\(String(format: "%.2f",amountDetails?.shoppingFee ?? 0))" : "Free"
                    cell.lblShoppingFeeLabel.text = "Shopping Fee"
                }
                cell.btnShowShoppingFee.addTarget(self, action: #selector(showChargeDetails(_ :)), for: .touchUpInside)
                cell.btnShowDeliveryFee.addTarget(self, action: #selector(showChargeDetails(_ :)), for: .touchUpInside)
                cell.btnShowServiceCharge.addTarget(self, action: #selector(showChargeDetails(_ :)), for: .touchUpInside)
				cell.lblFinalAmount.text = "\(Currency)\(String(format: "%.2f",amountDetails?.grandTotal ?? 0))"
				cell.selectionStyle = .none
				return cell
			}
		case enumCartSections.termAndCondition.rawValue:
			if indexPath.row == 0
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionMainTVC", for: indexPath) as? TermAndConditionMainTVC
				{
					cell.btnTnC.addTarget(self, action: #selector(actionTermConditonTapped(_ :)), for: .touchUpInside)
                    cell.btnTnC.isSelected = isTermAccepted
                    if isTermAccepted
                    {
                        cell.btnTnC.backgroundColor = THEME_COLOR
                    } else {
                        cell.btnTnC.backgroundColor = .clear
                    }
					cell.selectionStyle = .none
					return cell
				}
			}
			else if indexPath.row == termNote.count   //lastCell
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC
				{
					cell.viewSeparator.isHidden = true
					cell.lblTnCNote.attributedText = add(stringList: [termNote[indexPath.row - 1].note ?? ""], font: UIFont(name: "Montserrat-Regular", size: 14.0)!)
					cell.selectionStyle = .none
					return cell
				}
			}
			else
			{
				if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC
				{
					cell.viewSeparator.isHidden = false
					cell.lblTnCNote.attributedText = add(stringList: [termNote[indexPath.row - 1].note ?? ""], font: UIFont(name: "Montserrat-Regular", size: 14.0)!)
					cell.selectionStyle = .none
					return cell
				}
			}
			
			break
		case enumCartSections.note.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTVC", for: indexPath) as? NoteTVC
			{
				cell.textView.text = note
				cell.textView.delegate = self
				cell.btnCancel.isHidden = note.isEmpty
				cell.btnCancel.addTarget(self, action: #selector(actionClearText(_ :)), for: .touchUpInside)
				cell.selectionStyle = .none
				return cell
			}
		default:
			return UITableViewCell()
		}
		
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case enumCartSections.Coupon.rawValue:
		
//			if isGuest, let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as? MobileVerificationVC
//			{
//				LoginView.setupForGuest()
//				isLoginOrVerifyForOrder = true
//				let transition:CATransition = CATransition()
//				transition.duration = 0.5
//				transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//				transition.type = CATransitionType.push
//				transition.subtype = CATransitionSubtype.fromTop
//				self.navigationController?.view.layer.add(transition, forKey: kCATransition)
//				self.navigationController?.pushViewController(LoginView, animated: false)
//				//self.navigationController?.pushViewController(LoginView, animated: true)
//			}
//			else
//			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ApplyCouponVC") as! ApplyCouponVC
				nextViewController.setTotalAmount(amount: amountDetails?.totalItemsPrice ?? 0)
				nextViewController.delegate = self
				nextViewController.modalPresentationStyle = .fullScreen
                nextViewController.selectedDeliveryOption = selectedDeliveryOption
				self.present(nextViewController, animated: false, completion: nil)
			//}
			//self.navigationController?.pushViewController(nextViewController, animated: true)
			break
            
       case enumCartSections.viewDrivers.rawValue:
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewAvailableDriverVC") as! ViewAvailableDriverVC
          vc.deliveryOption = selectedDeliveryOption
          self.navigationController?.pushViewController(vc, animated: true)
            break
		default:
			break
		}
	}
    //Calculate Distance Between two location
      func Storedistance(lat1:Double, lon1:Double , in_time : Bool ) -> String {
          let lat2 = Double(defaultAddress?.latitude ?? "0.0") ?? 0.0
          let lon2 = Double(defaultAddress?.longitude ?? "0.0") ?? 0.0
          let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
          let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)
          
          let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
          if in_time
          {
              let time = distanceInMeters / 400
              if time > 50 && time < 60
              {
                  print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
                  return "around 1 hour(\(time.rounded(toPlaces: 0))minits)"
              }
              else if time >= 60
              {
                  print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
                  return "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
              }
              else
              {
                  print("Minit : ",time.rounded(toPlaces: 0))
                  return "\(Int(time.rounded(toPlaces: 0))) min"
              }
          }
          else
          {
              let distanceInKM = distanceInMeters / 1000
              if distanceInMeters >= 1000
              {
                  //tmproutedist = "\(distanceInKM.rounded(toPlaces: 2)) KM"
                  if (distanceInKM.rounded(toPlaces: 2))  > 20
                  {
                    isCustomerOutOfRange = true
                    }
                  return "\(distanceInKM.rounded(toPlaces: 2)) km"
              }
              else
              {
                  //tmproutedist = "\(distanceInMeters.rounded(toPlaces: 2)) MTR"
                  return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
              }
          }
          //return "\(distanceInKM)"
          
          
      }
    
    @objc func btnStandardDeliveryClicked(btn : UIButton) {
        selectedDeliveryOption = ENUM_DeliveryOption.Standard.rawValue
        tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.deliveryType.rawValue)], with: .none)
        getCartDetails()
    }
    @objc func btnExpressDeliveryClicked(btn : UIButton) {
        selectedDeliveryOption = ENUM_DeliveryOption.Express.rawValue
        tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.deliveryType.rawValue)], with: .none)
        getCartDetails()
    }
    @objc func showChargeDetails( _ sender : UIButton)
    {
        let tag  = sender.tag
        if tag == 10
        {
            showAlert(title: "Service Charge", message: "A service charge is a fee collected to pay for services related to the primary product or service being purchased.")
        }
        else if tag == 20
        {
            showAlert(title: "Shopping Fee", message: "Products shopping fees is to be considered for those products which are added from manual stores.")
        }
        else if tag == 30
        {
            showAlert(title: "Delivery Fee", message: "A delivery Fee is the cost of transporting or delivering goods.")
        }
    }
	@objc func actionTermConditonTapped( _ sender : UIButton)
	{
        isTermAndConditionTapped = sender.isSelected
		self.isTermAccepted = sender.isSelected
	}
	@objc func actionClearText(_ sender: UIButton) {
		
		if self.tableView.indexPathsForVisibleRows?.contains(IndexPath(row: 0, section: enumCartSections.note.rawValue)) ?? false
		{
			if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: enumCartSections.note.rawValue)) as? NoteTVC
			{
				cell.textView.text = ""
			}
		}
		self.note = ""
		sender.isHidden  = true
	}
	@objc func goToStore(_ gesture : UITapGestureRecognizer){
		if let imageView = gesture.view as? UIImageView {
			print("Image Tapped")
				let index = imageView.tag
			//let productIndex = (itemsRowIndex[indexRow] ?? 0)
			if let storeDetails = cartArray[itemsRowIndex[index] ?? 0].storeDetails
			{
				if storeDetails.storeId ?? 0 != 0
				{
					if storeDetails.canProvideService ?? 0 == 0
					{
						let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
						nextViewController.setStoreId(storeId: storeDetails.storeId ?? 0 )
						self.navigationController?.pushViewController(nextViewController, animated: true)
					}
					else
					{
						let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
						nextViewController.setStoreId(storeId: storeDetails.storeId ?? 0)
						self.navigationController?.pushViewController(nextViewController, animated: true)
					}
				}
				else if storeDetails.userStoreId ?? 0 != 0
				{
					let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
					nextViewController.setUserStoreId(userStoreId: storeDetails.userStoreId ?? 0 )
					self.navigationController?.pushViewController(nextViewController, animated: true)
				}
			}
        }
		
		
	}
/*	@objc func showPickerforAdvancedDate(_ sender : UIButton){
		if let  cell = tableView.cellForRow(at: IndexPath(row: 0, section: enumCartSections.deliveryType.rawValue)) as? DeliveryTimeOptionTVC
		{
			cell.btnAdvanceOrderSelection.isSelected = true
			cell.btnDeliveryNowSelection.isSelected = false
		}
		
		if let pickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomDatePicker") as? CustomDatePicker
		{
			pickerViewController.delegate = self
			self.present(pickerViewController, animated: false, completion: nil)
		}
		
	}*/
	
	
	@objc func removeStoreFromOrder(_ sender : UIButton){
		let cartId = sender.tag
		//removeStoreOrderFromCart(cartId)
		
        self.isDeleteViewiWillOpen = true
        if deleteCustomView == nil
        {
            deleteCustomView = DeleteCustomView(nibName: "DeleteCustomView", bundle: nil)
            deleteCustomView?.delegate = self
            deleteCustomView?.isDeleteForCart = true
            deleteCustomView?.storeId = cartId
            deleteCustomView?.strMessage = "Are you sure you want to remove this store from the cart? You can't undo this action"
            deleteCustomView?.showDeleteView(viewDisplay: self.view)
            
        }
        else
        {
            deleteCustomView?.hideView()
            deleteCustomView = nil
        }
	}
	
	@objc func RecurranceOrder(_ sender : UIButton){
		if sender.tag == 11 || sender.tag == 12
		{
			if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecurringOrderVC") as? RecurringOrderVC
			{
				nextViewController.delegate = self
					self.navigationController?.pushViewController(nextViewController, animated: true)
			}
		}
		else if  sender.tag == 13
		{
			isRecurringOrder = 0
			SetUpStoreItem()
		}
	}
	@objc func removeProductFromCart(_ sender : UIButton){
		let indexRow = sender.tag
		let storeIndex = (StoreIndex[indexRow] ?? 0)
		let productIndex = (itemsRowIndex[indexRow] ?? 0)
		print("Remove Product : ",indexRow)
		if let product = cartArray[storeIndex].products?[productIndex]
		{
			let productId = product.cartProductId ?? 0
			let cartId = cartArray[storeIndex].cartId ?? 0
			RemoveProductFromCart(cartId, productId: productId)
		}
	}
	@objc func decreaseProductQty(_ sender : UIButton){
		let indexRow = sender.tag
		let storeIndex = (StoreIndex[indexRow] ?? 0)
		let productIndex = (itemsRowIndex[indexRow] ?? 0)
		print("Decrease : ",indexRow)
		if let product = cartArray[storeIndex].products?[productIndex]
		{
			let qty = product.quantity ?? 0
			let productId = product.cartProductId ?? 0
			let cartId = cartArray[storeIndex].cartId ?? 0
			if qty > 1
			{
				UpdateQtyOfProduct((qty - 1), productId: productId)
			}
			else
			{
				RemoveProductFromCart(cartId, productId: productId)
			}
		}
	}
	@objc func increaseProductQty(_ sender : UIButton){
		let indexRow = sender.tag
		let storeIndex = (StoreIndex[indexRow] ?? 0)
		let productIndex = (itemsRowIndex[indexRow] ?? 0)
		print("Decrease : ",indexRow)
		if let product = cartArray[storeIndex].products?[productIndex]
		{
			let qty = product.quantity ?? 0
			let productId = product.cartProductId ?? 0
			UpdateQtyOfProduct((qty + 1), productId: productId)
		}
	}
	@objc func customiseProduct(_ sender : UIButton){
		let indexRow = sender.tag
		let storeIndex = (StoreIndex[indexRow] ?? 0)
		let productIndex = (itemsRowIndex[indexRow] ?? 0)
		print("Customise : ",indexRow)
		if let product = cartArray[storeIndex].products?[productIndex]
		{
			let addonsViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "ItemAddOnVC") as! ItemAddOnVC
			//addonsViewController.setDetails(titleString: , id: productId)
			addonsViewController.delegate = self
			addonsViewController.setCustomiseDetails(titleString:  "Customize Item", cartProduct: product)
			
			addonsViewController.modalPresentationStyle = .fullScreen
			//self.navigationController?.pushViewController(addonsViewController, animated: true)
			present(addonsViewController, animated: true, completion: nil)
		}
		
		
	}
}

extension CartViewVC : DeleteCustomViewDelegate {
    func dismissDialog() {
        deleteCustomView?.hideView()
        deleteCustomView = nil
        //self.parentFillLayer.isHidden = true
    }
    
    func deleteStore(storeId: Int) {
        deleteCustomView?.hideView()
        deleteCustomView = nil
       // self.parentFillLayer.isHidden = true
       removeStoreOrderFromCart(storeId)
    }
}
extension CartViewVC : AcvanceOrderDetailsDelegate{
	func RecurringDate(recurringTypeId : Int , recurredOn : String ,recurringTime : String ,label : String , repatUntilDate : String)
	{
		isRecurringOrder = 1
		if let  cell = tableView.cellForRow(at: IndexPath(row: 0, section: enumCartSections.deliveryType.rawValue)) as? DeliveryTimeOptionTVC
		{
			cell.btnAdvanceOrderSelection.isSelected = true
			cell.btnDeliveryNowSelection.isSelected = false
		}
		print("||||||||||||||||||||||")
		print(recurringTypeId)
		print(recurredOn)
		print(recurringTime)
		print(label)
		print(repatUntilDate)
		print("||||||||||||||||||||||")
		structAdvancedOrderDeatils.recurringTypeId = recurringTypeId
		structAdvancedOrderDeatils.recurredOn = recurredOn
		structAdvancedOrderDeatils.recurringTime = recurringTime
		structAdvancedOrderDeatils.label = label
		structAdvancedOrderDeatils.repatUntilDate = repatUntilDate
		SetUpStoreItem()
	}
}
extension CartViewVC : CustomeTimerDelegate{
	func dismissTimer()
	{
		UpdateTabBar(index: tabBarIndex.order.rawValue)
		self.navigationController?.popToRootViewController(animated: false)
		
	}
}

extension CartViewVC : AddonsUpdateDelegate{
	func reloadCart(cartData: NSDictionary ,code : String = "") {
		
		//self.sectionCount = 0
		appliedCouponCode = code
		if cartData.count != 0
		{
			self.sectionCount = 6
			let data = cartData
			if let AmtDetails = data["amount_details"] as? NSDictionary{
				self.amountDetails = AmountDetails(json: JSON(AmtDetails))
				self.finalAmt = (self.amountDetails?.grandTotal ?? 0.0)
				self.deliveryTime =	self.amountDetails?.totalDeliveryTime ?? 0
				if self.amountDetails?.couponDiscountPrice ?? 0 > 0
				{
					self.isCouponApplied = true
				}
				//self.tableView.reloadRows(at: [IndexPath(row: 0, section: enumCartSections.billDetails.rawValue)], with: .automatic)
			}
			if let cartAry = data["cart_items"] as? NSArray
			{
				if self.cartArray.count != 0
				{
					self.cartArray.removeAll()
				}
				self.itemsCount = 0
				self.storewithProductCount.removeAll()
				for cart in cartAry
				{
					let cartObj : CartItems = CartItems(json: JSON(cart))
					self.itemsCount +=  cartObj.products?.count ?? 0
					var storeID = cartObj.storeDetails?.storeId ?? 0
					if storeID == 0
					{
						storeID = cartObj.storeDetails?.userStoreId ?? 0
					}
					
					if cartObj.products?[0].productId ?? 0 == 0
					{
						self.ismannualStoreAvailable = true
					}
					else if cartObj.storeDetails?.storeId ?? 0 == 0
					{
						self.ismannualStoreAvailable = true
					}
					self.storewithProductCount[storeID] = cartObj.products?.count ?? 0
					self.cartArray.append(cartObj)
				}
				print("Cart Array -:- ",self.cartArray)
			}
		}
		self.SetUpStoreItem()
	}
	func reloadCart()
	{
		getCartDetails()
	}
}

extension CartViewVC : ManageListOfItemsInCartDelegate
{
	func updatedHeightRorRow(index: Int, height: CGFloat) {
		itemsHeight = height
		itemsHeightAry[index] = height
		/*if itemsHeightAry[index] != nil
		{
			itemsHeightAry[index] = height
		}
		else
		{
			itemsHeightAry = [index:height]
		}*/
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	
	
}
extension CartViewVC : UITextViewDelegate
{
	func textViewDidChange(_ textView: UITextView) {
		self.note = textView.text
		if self.tableView.indexPathsForVisibleRows?.contains(IndexPath(row: 0, section: enumCartSections.note.rawValue)) ?? false
		{
			if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: enumCartSections.note.rawValue)) as? NoteTVC
			{
				cell.btnCancel.isHidden = textView.text.isEmpty
			}
		}
	}
}
