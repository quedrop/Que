//
//  ConfirmedOrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 02/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import PassKit
import Braintree
import IHProgressHUD

class ConfirmedOrderVC: BaseViewController {

	@IBOutlet var btnBack: UIButton!
	@IBOutlet var imgDriver: UIImageView!
	@IBOutlet var lblDriverName: UILabel!
	@IBOutlet var driverRating: HCSStarRatingView!
	@IBOutlet var tableView: UITableView!
    
    
	enum enumOrderSections : Int{
		case receipts = 0
		case note
		case billDetails
		case otherStuff
	}
    
	var billingRowCount =  0
	var registeredStoreCount = 0
	var manualStoreCount = 0
	var orderBillingDetails : OrderBillingDetails? = nil
	var orderId = 0
    var tip : Float = 0
    let btnApplePay = PKPaymentButton(paymentButtonType: .inStore, paymentButtonStyle: .black)
    
    //PAYMNET RELATED
       var token = ""
       var billingAddress = ""
       var paymentNetwork = ""
       var paymentMethod = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnApplePay.addTarget(self, action: #selector(actionPayNow( _ :)), for: .touchUpInside)
        self.tableView.isHidden = true
		self.tableView.delegate = self
		self.tableView.dataSource = self
		getOrderDetails(of: orderId)
        
        // Do any additional setup after loading the view.
    }
    
	//MARK:- Action Methods
	@IBAction func actionRatingChanged(_ sender: HCSStarRatingView) {
		//ShowToast(message: "Rating : \(sender.value)")
        let pickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "GiveReviewVC") as? GiveReviewVC
        pickerViewController?.setDefaultValues(driverId: sender.tag, orderId: orderId, ratingValue: sender.value)
        pickerViewController?.modalPresentationStyle = .overFullScreen
        pickerViewController?.delegate = self
        self.present(pickerViewController!, animated: false, completion: nil)
	}
	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	//MARK:- Functions
	func setValue(_ orderId : Int){
		self.orderId = orderId
	}
	func setUpdetails()
	{
		if let details = orderBillingDetails
		{
			if let billingDetails = details.billingDetail{
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
			if let driver = details.driverDetail
			{
                let imgUrl = /*URL_USER_IMAGES +*/ (driver.userImage ?? "").getUserImageURL()
				self.lblDriverName.text = "\(driver.firstName ?? "") \(driver.lastName ?? "")"
				self.imgDriver.sd_setImage(with:  imgUrl, placeholderImage: USER_AVTAR, context: nil)
                let driverRating = driver.rating ?? 0
                if driverRating > 0
                {
                    self.driverRating.value = CGFloat(driverRating)
                }
                self.driverRating.tag = driver.userId ?? 0
                self.driverRating.isUserInteractionEnabled = true
			}
		}
        self.tableView.isHidden = false
        self.tableView.reloadData()
	}
}
extension ConfirmedOrderVC : ratingViewDelegate{
    func UpdateValue(ratingValue: CGFloat) {
        self.driverRating.value = ratingValue
    }
}
extension ConfirmedOrderVC : UITableViewDelegate,UITableViewDataSource{
	func numberOfSections(in tableView: UITableView) -> Int {
		4
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case enumOrderSections.receipts.rawValue:
				return orderBillingDetails?.storeReceipts?.count ?? 0
			case enumOrderSections.note.rawValue:
				return manualStoreCount > 0 ? 1 : 0
			case enumOrderSections.billDetails.rawValue:
				return billingRowCount
			case enumOrderSections.otherStuff.rawValue:
				return 1
		default:
			return 0
		}
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
			case enumOrderSections.note.rawValue:
				let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 3))
				returnedView.backgroundColor = .groupTableViewBackground
				return returnedView
			case enumOrderSections.billDetails.rawValue:
				let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 3))
				returnedView.backgroundColor = .groupTableViewBackground
				return returnedView
			
			default:
				return UIView()
		}
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch section {
			case enumOrderSections.note.rawValue:
				return 3
			case enumOrderSections.billDetails.rawValue:
				return 3
			default:
				return 0
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
			case enumOrderSections.receipts.rawValue:
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmedOrderReceiptTVCell", for: indexPath) as! ConfirmedOrderReceiptTVCell
				let imgUrl = "\(URL_ORDER_RECEIPT_IMAGES)\(orderBillingDetails?.storeReceipts?[indexPath.row] ?? "")"
				cell.imageReceipt.sd_setImage(with: URL(string: imgUrl), placeholderImage: QUE_AVTAR, completed: nil)
				
				cell.selectionStyle = .none
				return cell
			case enumOrderSections.note.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC
			{
				cell.lblTnCNote.attributedText = add(stringList: ["When Driver Attachd the receipt. After then manual Sore items Bill will shown. "], font: UIFont(name: "Montserrat-Regular", size: 14.0)!,forSingleNote: true)
				cell.selectionStyle = .none
				return cell
			}
		case enumOrderSections.billDetails.rawValue:
			let couponDiscount = orderBillingDetails?.billingDetail?.couponDiscount ?? 0
			let orderDiscount = orderBillingDetails?.billingDetail?.orderDiscount ?? 0
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
				cell.lblRegisterdStoreName.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(String(format: "%.2f", orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0))"
				cell.StoreDiscountView.isHidden = orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                                  cell.lblStoreNameDiscount.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                                  cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
                                              }
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
				cell.selectionStyle = .none
				return cell
			}
			else if indexPath.row == 0 && registeredStoreCount > 1
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
				cell.billDetailsHeaderHeight.constant = 30
				cell.viewRegisterdStoreDetails.isHidden = false
				cell.viewBottomSaperator.isHidden = false
				cell.lblRegisterdStoreName.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0))"
				cell.StoreDiscountView.isHidden = orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                                  cell.lblStoreNameDiscount.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                                  cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
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
				cell.lblRegisterdStoreName.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
				cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0))"
				cell.StoreDiscountView.isHidden = orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                if !cell.StoreDiscountView.isHidden{
                                                  cell.lblStoreNameDiscount.text = "\(orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "")'s Discount"
                                                  cell.lblStoreDiscountAmt.text = "\(Currency)\(String(format:"%.2f", orderBillingDetails?.billingDetail?.registeredStores?[indexPath.row].storeDiscount ?? 0))"
                                              }
				if indexPath.row == (orderBillingDetails?.billingDetail?.registeredStores?.count  ?? 0 - 1)
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
				let manualStoreDetials = orderBillingDetails?.billingDetail?.manualStores?[indexcount]
				cell.lblStoreName.text = "\(manualStoreDetials?.storeName ?? "") Items Total"
				cell.lblStoreAmt.text = manualStoreDetials?.storeAmount ?? 0 == 0 ? "-" : "\(Currency)\(String(format: "%.2f",manualStoreDetials?.storeAmount ?? 0))"
				cell.selectionStyle = .none
				return cell
			}
			else
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderOtherBillDetailsTVCell", for: indexPath) as! ConfirmOrderOtherBillDetailsTVCell
				cell.lblToPayAmt.text = "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.totalPay ?? 0))"
				cell.lblServiceChargeAmt.text = orderBillingDetails?.billingDetail?.serviceCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.serviceCharge ?? 0))"
				cell.lblDeliveryFeeAmt.text = orderBillingDetails?.billingDetail?.deliveryCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.deliveryCharge ?? 0))"
				cell.viewShoppingCharge.isHidden = orderBillingDetails?.billingDetail?.shoppingFee ?? 0 == 0
				cell.lblShoppingFeeAmt.text = "\(Currency)\(String(format: "%.2f",orderBillingDetails?.billingDetail?.shoppingFee ?? 0))"
				cell.selectionStyle = .none
				return cell
			}
			case enumOrderSections.otherStuff.rawValue:
				let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmedOrderDetailsTVCell", for: indexPath) as! ConfirmedOrderDetailsTVCell
                cell.viewContainerApplePay.removeArrangedSubview(btnApplePay)
                cell.viewContainerApplePay.addArrangedSubview(btnApplePay)
                cell.btnHelp.addTarget(self, action: #selector(ShowCustomerSupport( _ :)), for: .touchUpInside)
                cell.btnPayNow.addTarget(self, action: #selector(actionPayNow( _ :)), for: .touchUpInside)
                cell.btnTip1.addTarget(self, action: #selector(actionUpdateTip( _ :)), for: .touchUpInside)
                cell.btnTip1.tag = 20
                cell.btnTip2.addTarget(self, action: #selector(actionUpdateTip( _ :)), for: .touchUpInside)
                cell.btnTip2.tag = 30
                cell.btnTip3.addTarget(self, action: #selector(actionUpdateTip( _ :)), for: .touchUpInside)
                cell.btnTip3.tag = 50
                cell.btnNoTip.addTarget(self, action: #selector(actionUpdateTip( _ :)), for: .touchUpInside)
                cell.btnNoTip.tag = 100
				cell.selectionStyle = .none
				return cell
		default:
            let cell = UITableViewCell()
            cell.autoresizesSubviews = true
            
			return cell
		}
        let cell = UITableViewCell()
        cell.autoresizesSubviews = true
        
        return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section{
		case enumOrderSections.receipts.rawValue:
			let cell = tableView.cellForRow(at: indexPath) as! ConfirmedOrderReceiptTVCell
				let image = cell.imageReceipt.image ?? UIImage()
				let imageViewer = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewerVC") as! ImageViewerVC
				imageViewer.setImage(image: image)
				self.navigationController?.pushViewController(imageViewer, animated: true)
			break
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
		case enumOrderSections.receipts.rawValue:
			return 180
		default:
			return UITableView.automaticDimension
		}
	}
    @objc func ShowCustomerSupport(_ Sender : UIButton){
        let customerSupportView = self.storyboard?.instantiateViewController(withIdentifier: "CustomerSupportVC") as! CustomerSupportVC
        customerSupportView.setOrderId(orderId: orderId)
        self.navigationController?.pushViewController(customerSupportView, animated: true)
    }
    @objc func actionUpdateTip(_ Sender : UIButton){
        let tag = Sender.tag // 20,30,50,100
        if tag == 20
        {
            tip = 2.0
        }
        else if tag == 30
        {
            tip = 3.0
        }
        else if tag == 50
        {
            tip = 5.0
        }
        else if tag == 100
        {
            tip = 0
        }
    }
    
    //MARK:- Main Payment Method
    @objc func actionPayNow(_ Sender : UIButton){
        
        if isNetworkConnected {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentWebViewVC") as! PaymentWebViewVC
            vc.orderId = orderId
            vc.tip = tip
            vc.amount = orderBillingDetails?.billingDetail!.totalPay ?? 0.0
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
        
        
        
     /*   if isNetworkConnected {
            let applePayClient = BTApplePayClient(apiClient: APP_DELEGATE.braintreeClient!)
            
            applePayClient.paymentRequest { (paymentRequest, error) in
                guard let paymentRequest = paymentRequest else {
                    ShowToast(message: error!.localizedDescription)
                    return
                }
                
                var AppName = "QueDrop"
                if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
                    AppName = displayName
                }
                let totalAmt = (self.orderBillingDetails?.billingDetail?.totalPay ?? 0) + self.tip
                let paymentItem = PKPaymentSummaryItem.init(label: "\(AppName)", amount: NSDecimalNumber(value: totalAmt))
                
                paymentRequest.requiredBillingContactFields = [.postalAddress]

                // Set other PKPaymentRequest properties here
                paymentRequest.merchantCapabilities = .capability3DS
                paymentRequest.paymentSummaryItems = [ paymentItem ]
                let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]

                paymentRequest.currencyCode = "NGN" // "USD" // 1
                paymentRequest.countryCode = "NG" //"GB" // 2 UK
                paymentRequest.merchantIdentifier = "merchant.com.quedrop.pay"// 3
                paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS // 4
                paymentRequest.supportedNetworks = paymentNetworks // 5
                paymentRequest.paymentSummaryItems = [paymentItem] // 6
                
                if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                    as PKPaymentAuthorizationViewController?
                {
                    vc.delegate = self
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print("Error: Payment request is invalid.")
                }
            }
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
        */
        
    }
    
    func showSuccessAlert() {
        ShowToast(message: "The Apple Pay transaction is completed successfully.")
           DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            //self.showAlert(title: "Success!", message: "The Apple Pay transaction was complete.", completion: {_ in
                   //self.UpdateTabBar(index: tabBarIndex.order.rawValue)
                   self.popTwoViewBack()
              // })
           }
           
       }
}

extension ConfirmedOrderVC : PKPaymentAuthorizationViewControllerDelegate{
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
         dismiss(animated: true, completion: nil)
        
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
       // dismiss(animated: true, completion: nil)
        
        // Tokenize the Apple Pay payment
        let braintree = BTApplePayClient(apiClient: APP_DELEGATE.braintreeClient!)
        braintree.tokenizeApplePay(payment) { (nonce, error) in
            if error != nil {
                // Received an error from Braintree.
                // Indicate failure via the completion callback.
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                return
            }
            let dataCollector = BTDataCollector(apiClient: APP_DELEGATE.braintreeClient!)
            dataCollector.collectDeviceData { (clientDeviceData) in
                print("Data \(clientDeviceData)")
                
                //SEND NONCE TO SERVER
                let postalCode = payment.billingContact?.postalAddress?.postalCode
                let totalAmt = (self.orderBillingDetails?.billingDetail?.totalPay ?? 0) + self.tip
                
                API_ApplePay.shared.chargeApplePayForChange(orderId: self.orderId, amount: totalAmt, paymentMethodNonce: nonce!.nonce, deviceData: clientDeviceData, postalCode: postalCode!, responseData: { (paymentResponse) in
                    
                    let transactionId = paymentResponse.transactionId
                    switch APP_DELEGATE.socketIOHandler?.socket?.status{
                           case .connected?:
                            
                            let paymentType = "Apple Pay" // 2  for Apple pay
                            var token = payment.token.transactionIdentifier
                            do {
                                token = try self.encryptMessage(message: token)
                                //all fine with jsonData here
                            } catch {
                                //handle error
                                print(error)
                            }
                            
                            var billingAddress = ""
                            if #available(iOS 13.0, *) {
                                billingAddress = payment.token.paymentMethod.billingAddress?.description ?? ""
                                do {
                                    billingAddress = try self.encryptMessage(message: billingAddress)
                                    //all fine with jsonData here
                                } catch {
                                    //handle error
                                    print(error)
                                }
                            }
                            let paymentDate = "\(DateFormatter(format: "yyyy-MM-dd HH:mm:ss").string(from: Date()))"
                            var paymentNetwork = payment.token.paymentMethod.network?.rawValue ?? ""
                            do {
                                paymentNetwork = try self.encryptMessage(message: paymentNetwork)
                                //all fine with jsonData here
                            } catch {
                                //handle error
                                print(error)
                            }
                            let paymentMethod = payment.token.paymentMethod.type.rawValue
                            let d = ["order_id" : self.orderId ,
                                            "user_id" : USER_OBJ?.userId ?? 0 ,
                                       "payment_type" : "\(paymentType)",
                                       "total_amount" : "\(totalAmt)",
                                       "payment_date" : "\(paymentDate)" ,
                                       "billing_address" : "\(billingAddress)",
                                       "transaction_token": "\(token)",
                                       "payment_network":"\(paymentNetwork)",
                                       "payment_method" :"\(paymentMethod)",
                                "driver_id" : self.orderBillingDetails?.driverDetail?.userId ?? 0,
                                "tip" : self.tip,
                                "transaction_id" : "\(transactionId ?? "")"] as [String : Any]
                            
                               APP_DELEGATE.socketIOHandler?.CompleteOrder(dic: d)
                               break
                           default:
                               print("Socket Not Connected")
                               break;
                           }
                    
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.showSuccessAlert()
                    
                    
                }) { (isDone, errorMessage) in
                    if !isDone {
                        ShowToast(message: errorMessage)
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    }
                }
               
            }
//            }
            // TODO: On success, send nonce to your server for processing.
            // If requested, address information is accessible in `payment` and may
            // also be sent to your server.

            // Then indicate success or failure based on the server side result of Transaction.sale
            // via the completion callback.
            // e.g. If the Transaction.sale was successful
            
        }
        
    }

   
}

//MARK:- INTERSWICTH PAYMENT WEBVIEW DELEGATE METHOD
extension ConfirmedOrderVC : PaymentWebViewVCDelegate {
    func paymentResultDidFinish(dic: [String : Any]) {
        if isNetworkConnected {
            if dic["ResponseCode"] as! String == "00" {
                IHProgressHUD.show()
                switch APP_DELEGATE.socketIOHandler?.socket?.status{
                    case .connected?:
                        let totalAmt = (self.orderBillingDetails?.billingDetail?.totalPay ?? 0) + self.tip
                        let bankCode = dic["BankCode"] as! String
                        let PaymentReference = dic["PaymentReference"] as! String
                        let RetrievalReferenceNumber = dic["RetrievalReferenceNumber"] as! String
                        let MerchantReference = dic["MerchantReference"] as! String
                        let cardNumber = dic["CardNumber"] as! String
                        let TransactionDate = dic["TransactionDate"] as! String
                    
                    //CALL COMPLETE ORDER API
                    let d = ["order_id" : self.orderId ,
                            "user_id" : USER_OBJ?.userId ?? 0 ,
                               "bank_code" : "\(bankCode)",
                               "payment_reference" : "\(PaymentReference)",
                               "retrieval_reference_number" : "\(RetrievalReferenceNumber)" ,
                               "merchant_reference" : "\(MerchantReference)",
                               "card_number": "\(cardNumber)",
                               "transaction_date":"\(TransactionDate)",
                        "driver_id" : self.orderBillingDetails?.driverDetail?.userId ?? 0,
                        "tip" : self.tip,
                        "transaction_amount" : "\(totalAmt)",
                        "response_code" : "\(dic["ResponseCode"] as! String)",
                        "response_desc" : "\(dic["ResponseDescription"] as! String)"] as [String : Any]
                        APP_DELEGATE.socketIOHandler?.CompleteOrderNew(dic: d, completion: { (dic) in
                            IHProgressHUD.dismiss()
                            
                            if(dic.value(forKey: "status").asInt() == 1) {
                               // ShowToast(message: dic.value(forKey: "message").asString())
                                let alert = UIAlertController(title: "Success", message: dic.value(forKey: "message").asString(), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.dismiss(animated: true) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                           self.popTwoViewBack()
                                        }
                                    }
                                    
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
//                                self.showAlert(title: "Success", message: dic.value(forKey: "message").asString())
//                                self.popTwoViewBack()
                            } else {
                                self.showAlert(title: "Failed", message: dic.value(forKey: "message").asString())
                            }
                        })
                    default:
                        print("Socket Not Connected")
                        break;
                }
                
            } else {
                showAlert(title: "Payment Failed", message: dic["ResponseDescription"] as! String)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        } else {
            showAlert(title: "Ooops..", message: kCHECK_INTERNET_CONNECTION)
        }
    }
}
