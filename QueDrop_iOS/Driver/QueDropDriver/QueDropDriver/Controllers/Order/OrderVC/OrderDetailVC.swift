//
//  OrderDetailVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 30/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleMaps
import AMPopTip

class OrderDetailVC: UIViewController {
    //CONSTANTS
    var kTableHeaderHeight:CGFloat = 250.0
    
    //VARIABLES
    var orderId : Int = 0
    var orderDetails : OrderDetail?
    var routeInfoWindow : CustomRouteInfoView? = nil
    var photoPickerForSection : Int?
    var isFromPast : Bool = false
    var strPoliline : String = ""
    var headerView: UIView!
    var isPolilineDrawn : Bool = false
    var billingRowCount =  0
    var registeredStoreCount = 0
    var manualStoreCount = 0
    var manualStoreTotalAmount = 0
    var isTooltipShownFirst : Bool = true
    let popTip = PopTip()
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var constraintBtnConfirmHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBtnConfirmHeightRatio: NSLayoutConstraint!
    @IBOutlet weak var btnDriverNote: UIButton!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setMapCameraPositionToDriverCurrentLocation()
        setupGUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //loadOrderData()
        if let od = orderDetails {
            orderId = od.orderId!
        }
        getOrderDetail()
    }
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        tblView.register(UINib(nibName: "OrderUserCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderUserCell")
        tblView.register(UINib(nibName: "OrderStoreProductCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderStoreProductCell")
        tblView.register("OrderIdCell")
        tblView.register("OrderProductCell")
        tblView.register("OrderAmountDateCell")
        //tblView.register(UINib(nibName: "OrderProductCell", bundle: nil), forCellReuseIdentifier: "OrderIdCell")
    }
     
    func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
         setupToolTip()
        viewBG.backgroundColor = VIEW_BACKGROUND_COLOR
        
         lblTitle.text = "Order Details"
         lblTitle.textColor = .white
         lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
         
        tblView.rowHeight = UITableView.automaticDimension
         tblView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
         tblView.sectionFooterHeight = CGFloat.leastNormalMagnitude
         tblView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        
         //FOR STRECHY HEADER
        
        if isFromPast {
            kTableHeaderHeight = 0
        }
         headerView = tblView.tableHeaderView
         tblView.tableHeaderView = nil
         tblView.addSubview(headerView)
         tblView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
         tblView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
         updateHeaderView()
        
         drawBorder(view: btnConfirm, color: .clear, width: 0.0, radius: 5.0)
         drawBorder(view: tblView, color: .clear, width: 0.0, radius: 5.0)
        
        btnConfirm.isHidden = true
        btnConfirm.backgroundColor = THEME_COLOR
        btnConfirm.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 17.0))
        btnConfirm.setTitle("Confirm", for: .normal)
        btnConfirm.setTitleColor(.white, for: .normal)
        
        tblView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tblView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tblView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tblView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tblView.isHidden = true
        
//        if isFromPast {
//            btnConfirm.isHidden = true
//            constraintBtnConfirmHeightRatio.isActive = false
//            constraintBtnConfirmHeight.isActive = true
//            constraintBtnConfirmHeight.constant = 0
//        }
        
//        loadOrderData()
//        getOrderDetail()
        

    }
    
    func setupToolTip() {
        popTip.appearHandler = { popTip in
            self.isTooltipShownFirst = false
        };
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnTap = true
        popTip.arrowSize = CGSize(width: 12, height: 12)
        popTip.textColor = .white
        popTip.bubbleColor = .black
        popTip.cornerRadius = 8.0
    }
    //MARK:- LOAD ORDER DATA
    func loadOrderData() {
        btnConfirm.isHidden = false
        
        if (orderDetails?.driverNote!.count)! > 0 {
             btnDriverNote.isHidden = false
            if isTooltipShownFirst {
                if (orderDetails?.driverNote!.count)! > 0 {
                   //SHOW TOOLTIP
                    if(!popTip.isVisible) {
                        if orderDetails?.orderStatus! == OrderStatus.Delivered.rawValue || orderDetails?.orderStatus! == OrderStatus.Cancelled.rawValue {
                        }else {
                            popTip.show(text: orderDetails?.driverNote ?? "", direction: .auto, maxWidth: 200, in: self.view, from: btnDriverNote.frame)
                        }
                    }
               }
            }
           
        } else {
            btnDriverNote.isHidden = true
        }
        
        if orderDetails?.orderStatus! == OrderStatus.Accepted.rawValue{
            constraintBtnConfirmHeightRatio.isActive = true
            constraintBtnConfirmHeight.isActive = false
            btnConfirm.setTitle("Confirm", for: .normal)
        }else if orderDetails?.orderStatus! == OrderStatus.Dispatch.rawValue{
            constraintBtnConfirmHeightRatio.isActive = true
            constraintBtnConfirmHeight.isActive = false
            btnConfirm.setTitle("View QR Code", for: .normal)
        }else{
            constraintBtnConfirmHeightRatio.isActive = false
            constraintBtnConfirmHeight.isActive = true
            constraintBtnConfirmHeight.constant = 0
            btnDriverNote.isHidden = true
            //HIDE MAP SECTION
            
        }
        self.tblView.isHidden = false
        
        if !isPolilineDrawn && (orderDetails?.orderStatus != OrderStatus.Delivered.rawValue && orderDetails?.orderStatus != OrderStatus.Cancelled.rawValue) {
            self.FetchPolylineForRoute(to_lat: self.orderDetails!.deliveryLatitude!, to_long: self.orderDetails!.deliveryLongitude!)
        }
        
        //BILLING DETAIL
        if let billingDetails =  self.orderDetails?.billingDetail{
            let rsCount = billingDetails.registeredStores?.count ?? 0
            let msCount = billingDetails.manualStores?.count ?? 0
             registeredStoreCount = 0 //rsCount //TODO: UNCOMMENT TO SHOW REGISTERED STORE COUNT
             manualStoreCount = msCount
            
             billingRowCount = rsCount + msCount + 1
           /* if orderDetails?.orderStatus == OrderStatus.Delivered.rawValue {
                billingRowCount += 1
             }*/
            if rsCount == 0
            {
                billingRowCount += 1
            }
            
           
            if msCount > 0 {
                manualStoreTotalAmount = billingDetails.manualStores!.map({$0.storeAmount!}).reduce(0, +)
            }
        }
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
    }
    
    //MARK:- DRAW PATH ON MAP
    func drawPathOnMap(witPolyline : String) {
        isPolilineDrawn = true
        strPoliline = witPolyline
        let path = GMSPath(fromEncodedPath: witPolyline)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.map = viewMap
        polyline.strokeColor = strokeColor
        
        DispatchQueue.main.async {
            if self.viewMap != nil {
                let bounds = GMSCoordinateBounds(path: path!)
                self.viewMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
            }
        }
        
        //ADD DELIVERY ADDRESS MARKER
        let latitude = orderDetails?.deliveryLatitude ?? "0.0"
        let longitude = orderDetails?.deliveryLongitude ?? "0.0"
        let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
        let  detailMarker = GMSMarker(position: pos)
        detailMarker.icon = UIImage(named: "markerBlue")
        detailMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        detailMarker.isTappable = false
        detailMarker.map = viewMap
        
        //ADD DISTANCE MARKER
        let centerPoint = (polyline.path?.coordinate(at: (polyline.path?.count() ?? 0) / 2))!   //block for small deails view in center of rout path
        //let sView = UIView()
        
        let distance = getDistance(lat1: Double(orderDetails?.deliveryLatitude ?? "") ?? 0.0, lon1: Double(orderDetails?.deliveryLongitude ?? "") ?? 0.0, lat2: CURRENT_LATITUDE, lon2: CURRENT_LONGITUDE)
        let approxTime = getAppoxTime(lat1: Double(orderDetails?.deliveryLatitude ?? "") ?? 0.0, lon1: Double(orderDetails?.deliveryLongitude ?? "") ?? 0.0, lat2: CURRENT_LATITUDE, lon2: CURRENT_LONGITUDE)
        
        DispatchQueue.main.async {
            if self.routeInfoWindow != nil {
                self.routeInfoWindow = nil
            }
            self.routeInfoWindow = CustomRouteInfoView(nibName: "CustomRouteInfoView", bundle: nil)
            
            self.routeInfoWindow?.setValues(distance: distance, time: approxTime)
            let  distanceMArker = GMSMarker(position: centerPoint)
            distanceMArker.iconView = self.routeInfoWindow?.view
            distanceMArker.infoWindowAnchor = CGPoint(x: 1, y: 1)
            distanceMArker.isTappable = false
            distanceMArker.accessibilityHint = "Hint"
             if self.viewMap != nil {
                self.viewMap.selectedMarker = distanceMArker
                distanceMArker.map = self.viewMap
                self.viewMap.animate(toBearing: -60.0)
            }
           
        }
    }
    
    
    //MARK:- MAP RELATED METHODS
    @objc func setMapCameraPositionToDriverCurrentLocation()  {
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(CURRENT_LATITUDE) )!, longitude: CLLocationDegrees(exactly: Double(CURRENT_LONGITUDE) )!)
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 15.0)
        viewMap.camera = camera
        viewMap.isMyLocationEnabled = true
        viewMap.animate(to: camera)
        viewMap.delegate  = self
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ncNOTIFICATION_LOCATION_UPDATE), object: nil)
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func btnBack(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnConfirmClicked(_ sender: Any) {
        if doValidationForOrderRecipt() {
            if orderDetails?.orderStatus! == OrderStatus.Dispatch.rawValue{
                 self.navigateToConfirmOrderScreen()
            }else{
                if isNetworkConnected {
                    switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                        case .connected?:
                            if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                                APP_DELEGATE!.socketIOHandler?.updateOrderStatus(orderStatus: OrderStatus.Dispatch.rawValue, orderId: orderDetails!.orderId!, customerId: (orderDetails?.customerDetail!.userId)!, completion: { (isChnaged) in
                                    if (isChnaged) {
                                        //NAVIGATE TO CONFIRM SCREEN
                                        self.navigateToConfirmOrderScreen()
                                    }
                                })
                            }
                            break
                        default:
                           print("Socket Not Connected")
                    }
                } else {
                    ShowToast(message: kCHECK_INTERNET_CONNECTION)
                }
            }
             
        }else {
            ShowToast(message: "Please Attach all the receipt first")
        }
    }
    
    @IBAction func btnDriverNoteClicked(_ sender : UIButton) {
        if let objOrder = orderDetails {
            if objOrder.driverNote!.count > 0 {
                //SHOW TOOLTIP
                if(!popTip.isVisible) {
                    popTip.show(text: objOrder.driverNote ?? "", direction: .auto, maxWidth: 200, in: self.view, from: btnDriverNote.frame)
                }else {
                    popTip.hide()
                }
                
            }
        }
    }
    func doValidationForOrderRecipt() -> Bool {
        if (orderDetails?.stores?.count)! > 0 {
            let arr = orderDetails?.stores?.filter{($0.orderReceipt!).count > 0}
            if arr!.count == (orderDetails?.stores?.count)! {
                return true
            }
            return false
        }
        return false
    }
    
    @objc func btnChatClicked(sender : UIButton) {
        
        if let objCustomer = orderDetails?.customerDetail {
            var name = "\(objCustomer.firstName ?? "") \(objCustomer.lastName ?? "")"
            if (objCustomer.firstName!.length) > 0
            {
                name = "\(objCustomer.firstName ?? "") \(objCustomer.lastName ?? "")"
            } else {
                name = "\(objCustomer.email?.components(separatedBy: "@")[0] ?? "")"
            }
            
            let imgUrl = (objCustomer.userImage?.isValidUrl())! ? objCustomer.userImage ?? "" : "\(URL_USER_IMAGES)\(objCustomer.userImage ?? "")"
            
            let strId = objCustomer.userId
            
            let nextViewController = HomeStoryboard.instantiateViewController(withIdentifier: "DriverChatVC") as! DriverChatVC
           nextViewController.receiver_id = strId!
           nextViewController.receiver_name = name
           nextViewController.receiver_profile = imgUrl
            nextViewController.orderId = orderDetails?.orderId ?? 0
            nextViewController.orderStatus = orderDetails?.orderStatus ?? ""
           self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @objc func btnAddReceiptClicked(sender : UIButton) {
        photoPickerForSection = sender.tag
        let objStore = orderDetails?.stores![photoPickerForSection! - 1]
        
        if objStore!.orderReceipt!.count > 0{
                //REMOVE
            removeStoreReceipt(storeId: objStore!.storeId!, userStoreId: objStore!.userStoreId!, orderId: orderDetails!.orderId!)
        } else {
            //ADD
            let vc = MainStoryboard.instantiateViewController(withIdentifier: "PhotoPickerVC") as! PhotoPickerVC
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.isForRecipt = true
            present(vc, animated: true, completion: nil)
        }
    }
    
    func navigateToConfirmOrderScreen() {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ConfirmDeliveryVC") as! ConfirmDeliveryVC
        vc.orderDetails = orderDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    func getOrderDetail()  {
        if isNetworkConnected {
            getSingleOrderDetail(orderId:/* orderDetails!.orderId!*/orderId)
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    //MARK:- EXTRA
       func removeNotificationOnservers(notificationName : String){
           NotificationCenter.default.removeObserver(self, name:  NSNotification.Name(rawValue: notificationName), object: nil)
       }
       
    func createLocationMutableString(strLocation : String) -> NSMutableAttributedString {
           let iconSize = CGRect(x: 0, y: -calculateFontForWidth(size: 2.5), width: calculateFontForWidth(size: 9.0), height: calculateFontForWidth(size: 11.0))
           let attachment = NSTextAttachment();
           attachment.image = UIImage(named: "addressPin")
           attachment.bounds = iconSize
           
           let attachmentStr = NSAttributedString(attachment: attachment)
           
           let s1 = NSMutableAttributedString(string: " \(strLocation)")
           
           s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s1.length))
           s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s1.length))
           
           let finalStr = NSMutableAttributedString(string: "")
           finalStr.append(attachmentStr)
           finalStr.append(s1)
           
           return finalStr
       }
       
       func createProductMutableString(strProductName : String, strDetaail : String) -> NSMutableAttributedString {
           
           let s1 = NSMutableAttributedString(string: "\(strProductName)")
           let s2 = NSMutableAttributedString(string: "\n\(strDetaail)")
           
           s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))!, range: NSMakeRange(0, s1.length))
           s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s1.length))
           
           s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s2.length))
           s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s2.length))
           
           s1.append(s2)
           
           return s1
       }
       
       func createOrderIdMutableString(orderId : Int) -> NSMutableAttributedString {
           
           let s1 = NSMutableAttributedString(string: "Order ID: ")
           let s2 = NSMutableAttributedString(string: "#\(orderId)")
           
           s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s1.length))
           s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s1.length))
           
           s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))!, range: NSMakeRange(0, s2.length))
           s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s2.length))
           
           s1.append(s2)
           
           return s1
       }
    
    
      //MARK:- STRECHY HEADER RELATED METHODS
      func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isFromPast {
          updateHeaderView()
        }
      }
      
      func updateHeaderView() {
          var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: SCREEN_WIDTH, height: kTableHeaderHeight)
          if tblView.contentOffset.y < -kTableHeaderHeight {
              headerRect.origin.y = tblView.contentOffset.y
              headerRect.size.height = -tblView.contentOffset.y
          }
          headerView.frame = headerRect
      }
}

//MARK:- TABLEVIEW DELEGATE & DATASORURCE METHOD

extension OrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (orderDetails?.stores!.count)! + 5 // +2 for note, filling
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == (orderDetails?.stores!.count)! + 1 {
            return 1
        } else if section == (orderDetails?.stores!.count)! + 2 {
            return 0
        } else if section == (orderDetails?.stores!.count)! + 3 {
            return manualStoreCount > 0 ? 1 : 0
        }  else if section == (orderDetails?.stores!.count)! + 4 {
            return billingRowCount
        }else {
            return (orderDetails?.stores![section - 1].products!.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else if section == (orderDetails?.stores!.count)! + 1 {
            return nil
        }
        else if section == (orderDetails?.stores!.count)! + 2 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderUserCell") as! OrderUserCell
            let objCustomer = orderDetails?.customerDetail
            if (objCustomer?.firstName!.length)! > 0
            {
                cell.lblName.text = "\(objCustomer?.firstName ?? "") \(objCustomer?.lastName ?? "")"
            } else {
                cell.lblName.text = "\(objCustomer?.email?.components(separatedBy: "@")[0] ?? "")"
            }
            cell.lblLocation.text = "+\(objCustomer?.countryCode ?? 0) \(objCustomer?.phoneNumber ?? "")"
            if let imgUrl = objCustomer?.userImage{
                cell.imgUser.sd_setImage(with: imgUrl.getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
            }
            else {
                cell.imgUser.image = USER_AVTAR
            }
            cell.ratingView.rating = Double(objCustomer!.rating!)
            cell.lblOrderId.text = "\n"
            cell.imgDash.isHidden = false
//            if  orderDetails?.orderStatus == OrderStatus.Delivered.rawValue || orderDetails?.orderStatus == OrderStatus.Cancelled.rawValue {
//                cell.btnChat.isHidden = true
//            }else {
//                cell.btnChat.isHidden = false
//            }
            cell.btnChat.isHidden = false
            
            cell.viewTimer.isHidden = true
            cell.lblMinutes.isHidden = true
            cell.btnChat.addTarget(self, action: #selector(btnChatClicked(sender:)), for: .touchUpInside)
            //cell.lblOrderId.attributedText = createOrderIdMutableString(orderId: orderDetails?.orderId ?? 0)
            return cell
        } else if  section == (orderDetails?.stores!.count)! + 3 || section == (orderDetails?.stores!.count)! + 4 {
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
            returnedView.backgroundColor = .groupTableViewBackground
            return returnedView
        } else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderStoreProductCell") as! OrderStoreProductCell
            let objStore = orderDetails?.stores![section - 1]
            cell.lblStoreName.text = objStore?.storeName
            cell.lblStoreLocation.attributedText = createLocationMutableString(strLocation: objStore!.storeAddress!)
            if let logoUrl = objStore!.storeLogo{
                cell.imgStore.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                //cell.imgStore.sd_setImage(with:  URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), completed: nil)
            }
            else {
                cell.imgStore.image = QUE_AVTAR
            }
            
            cell.constraintBtnReceiptWidth.constant = 45
            
            
            if objStore!.orderReceipt!.count > 0{
                cell.imgReceipt.sd_setImage(with:  URL(string: "\(URL_ORDER_RECEIPT_IMAGES)\(objStore!.orderReceipt!)"), completed: nil)
                cell.btnAddReceipt.setImage(UIImage() , for: .normal)
                cell.btnAddReceipt.setBackgroundImage(UIImage(), for: .normal)
                 cell.constraintimgCloseWidth.constant = 20;
            }else {
                cell.imgReceipt.image = nil
                cell.btnAddReceipt.setImage(UIImage(), for: .normal)
                cell.btnAddReceipt.setBackgroundImage(UIImage(named: "add_receipt"), for: .normal)
                cell.constraintimgCloseWidth.constant = 0;
            }
            
            cell.updateConstraints()
            cell.layoutIfNeeded()
            
            cell.btnAddReceipt.tag = section
            cell.btnAddReceipt.addTarget(self, action: #selector(btnAddReceiptClicked(sender:)), for: .touchUpInside)
            
            /*if isFromPast {
                cell.btnAddReceipt.isHidden = true
            } else {
                cell.btnAddReceipt.isHidden = false
            }*/
            
             if orderDetails?.orderStatus == OrderStatus.Accepted.rawValue || orderDetails?.orderStatus == OrderStatus.Placed.rawValue {
                cell.btnAddReceipt.isHidden = false
                cell.imgClose.isHidden = false
             }else {
                cell.btnAddReceipt.isHidden = true
                cell.imgClose.isHidden = true
             }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderIdCell", for: indexPath) as! OrderIdCell
            cell.lblProductName.attributedText = createOrderIdMutableString(orderId: orderDetails?.orderId ?? 0)
            cell.imgSeparator.isHidden = false
            if orderDetails?.deliveryOption == DELIVERY_OPTION.Standard.rawValue {
                cell.constraintImgExpressWidth.constant = 0.0
                cell.constraintLabelExpressWidth.constant = 0.0
            } else {
                cell.constraintImgExpressWidth.constant = 26.0
                cell.constraintLabelExpressWidth.constant = 60.0
            }
            return cell
        } else if indexPath.section == (orderDetails?.stores!.count)! + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderAmountDateCell", for: indexPath) as! OrderAmountDateCell
            let dateStr = orderDetails!.orderDate ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var date = dateFormatter.date(from:dateStr)!
            date = date.UTCtoLocal().toDate()!
            //let date = dateFormatter.date(from:dateStr)!
            cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
            //cell.lblOrderAmount.text  = "\(Currency)\(orderDetails!.orderAmount ?? 0)"
            return cell
        }
        else if indexPath.section == (orderDetails?.stores!.count)! + 3 {
             if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC {
                  cell.lblTnCNote.attributedText = add(stringList: ["Please attach the receipt. After then manual store items Bill will shown. "], font: UIFont(name: "Montserrat-Regular", size: 15.0)!)
                  cell.selectionStyle = .none
                  return cell
              }
          }
        else if indexPath.section == (orderDetails?.stores!.count)! + 4 {
              let couponDiscount = orderDetails?.billingDetail?.couponDiscount ?? 0
              let orderDiscount = orderDetails?.billingDetail?.orderDiscount ?? 0
              if indexPath.row == 0 && registeredStoreCount == 0
              {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
                    if manualStoreCount == 0 {
                        cell.billDetailsHeaderHeight.constant = 0
                    }else {
                        cell.billDetailsHeaderHeight.constant = 30
                    }
                  
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
                  if couponDiscount == 0 && orderDiscount == 0
                  {
                      cell.viewOrderAndCouponDiscount.isHidden = true
                  }
                  else
                  {
                      cell.viewOrderDiscount.isHidden  = orderDiscount == 0
                      cell.viewCouponDiscount.isHidden = couponDiscount == 0
                      cell.lblCouponDiscountAmt.text = "\(Currency)\(couponDiscount)"
                      cell.lblOrderDiscountAmt.text = "\(Currency)\(orderDiscount)"
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
                  cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(orderDetails?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
                  cell.StoreDiscountView.isHidden = orderDetails?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
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
                          cell.lblCouponDiscountAmt.text = "\(Currency)\(couponDiscount)"
                          cell.lblOrderDiscountAmt.text = "\(Currency)\(orderDiscount)"
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
                  cell.lblStoreAmt.text = manualStoreDetials?.storeAmount ?? 0 == 0 ? "-" : "\(Currency)\(manualStoreDetials?.storeAmount ?? 0)"
                  cell.selectionStyle = .none
                  return cell
              }
              else
              {
                
                  let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderOtherBillDetailsTVCell", for: indexPath) as! ConfirmOrderOtherBillDetailsTVCell
                
                    if manualStoreCount == 0 {
                        cell.constraintViewMnualStoreTotalHeight.constant = 0
                    } else {
                        cell.constraintViewMnualStoreTotalHeight.constant = 40
                        cell.lblManualStoreTotal.text = "\(Currency)\(manualStoreTotalAmount)"
                    }
                    
                if orderDetails?.orderStatus == OrderStatus.Delivered.rawValue {
                    cell.viewYouEarn.isHidden = false
                } else {
                    cell.viewYouEarn.isHidden = true
                }
                
                  cell.lblToPayAmt.text = "\(Currency)\(orderDetails?.billingDetail?.driverTotalEarn ?? 0)"
                  cell.lblServiceChargeAmt.text = orderDetails?.billingDetail?.tip ?? 0 == 0 ? "-" : "\(Currency)\(orderDetails?.billingDetail?.tip ?? 0)"
                  cell.lblDeliveryFeeAmt.text = orderDetails?.billingDetail?.deliveryCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(orderDetails?.billingDetail?.deliveryCharge ?? 0)"
                  cell.viewShoppingCharge.isHidden = orderDetails?.billingDetail?.shoppingFeeDriver ?? 0 == 0
                  cell.lblShoppingFeeAmt.text = "\(Currency)\(orderDetails?.billingDetail?.shoppingFeeDriver ?? 0)"
                  cell.selectionStyle = .none
                  return cell
              }
          }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell", for: indexPath) as! OrderProductCell
            let objProduct = orderDetails?.stores![indexPath.section - 1].products![indexPath.row]
            cell.lblProductName.attributedText = createProductMutableString(strProductName: objProduct!.productName!, strDetaail: objProduct!.productDescription!)
            
            if indexPath.row ==  (orderDetails?.stores![indexPath.section - 1].products!.count)! - 1 {
        
                if indexPath.section == orderDetails?.stores!.count {
                    cell.imgSeparator.isHidden = true
                } else  {
                    cell.imgSeparator.isHidden = false
                    cell.imgSeparator.image = nil
                    cell.imgSeparator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
                }
            } else {
                cell.imgSeparator.isHidden = true
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  && section == (orderDetails?.stores!.count)! + 1{
            return 0.0
        }
        else if section == (orderDetails?.stores!.count)! + 3
        {
            if isFromPast {
                return 0
            }
            return manualStoreCount > 0 ? 5 : 0
        }
        else if section == (orderDetails?.stores!.count)! + 4
        {
            return 5
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && section == (orderDetails?.stores!.count)! + 1{
            return 0.0
        }else if section == (orderDetails?.stores!.count)! + 3
        {
            if isFromPast {
                return 0
            }
            return manualStoreCount > 0 ? 5 : 0
        }
        else if section == (orderDetails?.stores!.count)! + 4
        {
            return 5
        }else {
            return 74.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == (orderDetails?.stores!.count)! + 3
        {
            if isFromPast {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == (orderDetails?.stores!.count)! + 3
        {
            if isFromPast {
                return 0
            }
        }
        return 31.0
    }
    
}

//MARK: - PHOTO PICKER DELEGATE
extension OrderDetailVC : PhotoPickerVCDelegate {
    func imagePicked(img: UIImage) {
        let objStore = orderDetails?.stores![photoPickerForSection! - 1]
        if objStore?.canProvideService == 0 {
            openBillAmountPopup(orderId: orderDetails!.orderId!, orderStoreId: objStore!.orderStoreId!, img: img)
        } else {
            //CALL UPLOAD RECEIPT API
            uploadOrderStoreReceipt(orderId: orderDetails!.orderId!, orderStoreId: objStore!.orderStoreId!, imgReceipt: img, amount: "0")
        }
    }
}

//MARK: - GMSMAPVIEW DELEGATE
extension OrderDetailVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if !isFromPast {
            let vc = HomeStoryboard.instantiateViewController(withIdentifier: "DeliveryRouteVC") as! DeliveryRouteVC
            vc.orderDetails = orderDetails
            vc.strPolyline = strPoliline
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openBillAmountPopup(orderId : Int, orderStoreId : Int, img : UIImage) {
        let alert = UIAlertController(title: "Enter Bill Amount", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Amount"
            textField.keyboardType = .numbersAndPunctuation
            textField.textColor = .black
            textField.font = UIFont(name: fFONT_MEDIUM, size: 15.0)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            if (textField?.text!.count)! > 0 {
                self.uploadOrderStoreReceipt(orderId: orderId, orderStoreId: orderStoreId, imgReceipt: img, amount: (textField?.text!)!)
            }else {
                ShowToast(message: "Bill amount is complusory for manual store. Please enter bill amount")
            }
        }))
        
        self.parent?.present(alert, animated: true, completion: nil)
    }
    
}
