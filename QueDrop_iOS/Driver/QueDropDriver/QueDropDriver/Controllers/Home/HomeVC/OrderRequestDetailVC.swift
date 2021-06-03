//
//  OrderRequestDetailVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 26/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps
import FloatRatingView
import AMPopTip

@objc protocol OrderRequestDetailVCDelegate:NSObjectProtocol{
    func OrderRejection()
    func OrderAccept(dicResult : [String:Any])
}

class OrderRequestDetailVC: BaseViewController {
    //CONSTANTS
    var kTableHeaderHeight:CGFloat = 250.0
    
    //VARIABLE
    var delegate:OrderRequestDetailVCDelegate?
    var isTimerLabelAdded = false
    var objOrderDetail : OrderDetail?
    var routeInfoWindow : CustomRouteInfoView? = nil
    var orderRequestTime : TimeInterval = 0.0
    var headerView: UIView!
    var isFromNotification : Bool = false
    var orderId : Int = 0
     let popTip = PopTip()
    
    var billingRowCount =  0
    var registeredStoreCount = 0
    var manualStoreCount = 0
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblOrderRequest: UITableView!
    @IBOutlet weak var viewMap: GMSMapView!
    
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var lblTimer: MZTimerLabel!
    @IBOutlet weak var btnDriverNote: UIButton!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        allNotificationCenterObservers()
        setMapCameraPositionToDriverCurrentLocation()
        setupGUI()
    }

    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
      
   }
   
   //MARK:- SETUP & INITIALISATION
   func initializations()  {
        tblOrderRequest.register("OrderIdCell")
        tblOrderRequest.register(UINib(nibName: "OrderStoreProductCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderStoreProductCell")
        tblOrderRequest.register("OrderProductCell")
   }
    
   func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        setupToolTip()
    
        lblTitle.text = "Request Details"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        tblOrderRequest.rowHeight = UITableView.automaticDimension
        tblOrderRequest.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tblOrderRequest.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tblOrderRequest.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        
        //FOR STRECHY HEADER
        headerView = tblOrderRequest.tableHeaderView
        tblOrderRequest.tableHeaderView = nil
        tblOrderRequest.addSubview(headerView)
        tblOrderRequest.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tblOrderRequest.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
    
        lblName.textColor = .black
        lblName.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        lblTimer.textColor = SKYBLUE_COLOR
        lblTimer.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 10.0))
        lblTimer.text = "01:00"
        makeCircular(view: imgUser)
        addDashedCircle(withColor: .darkGray, view: viewTimer)
    
        drawBorder(view: btnAccept, color: .clear, width: 0.0, radius: 8.0)
        drawBorder(view: btnReject, color: .clear, width: 0.0, radius: 8.0)
       
        btnAccept.backgroundColor = GREEN_COLOR
        btnAccept.setTitle("ACCEPT", for: .normal)
        btnAccept.setTitleColor(.white, for: .normal)
        btnAccept.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
     
        btnReject.backgroundColor = RED_COLOR
        btnReject.setTitle("REJECT", for: .normal)
        btnReject.setTitleColor(.white, for: .normal)
        btnReject.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
       
        tblOrderRequest.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tblOrderRequest.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tblOrderRequest.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tblOrderRequest.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
       
       //JOIN DRIVER WITH SOCKET IF NOT
       JoinDriverWithSocket()
    
        if isFromNotification {
            getOrderDetail(orderId: orderId)
        }else {
            //LOAD ORDER REQUEST DATA
            loadOrderREquestData()
        }
   }

    func setupToolTip() {
           popTip.shouldDismissOnTapOutside = true
           popTip.shouldDismissOnTap = true
           popTip.arrowSize = CGSize(width: 12, height: 12)
           popTip.textColor = .white
           popTip.bubbleColor = .black
           popTip.cornerRadius = 8.0
       }
   func allNotificationCenterObservers() {
       NotificationCenter.default.addObserver(self, selector: #selector(setMapCameraPositionToDriverCurrentLocation), name: NSNotification.Name(rawValue: ncNOTIFICATION_LOCATION_UPDATE), object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(orderRejectFromHome(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_REJECT_FROM_HOME_SCREEN), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(orderAcceptedResult(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_ACCEPTED_RESULT), object: nil)
    //if isFromNotification {
       NotificationCenter.default.addObserver(self, selector: #selector(orderRequestTimeout(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_REQUEST_TIMEOUT), object: nil)
    //}
    NotificationCenter.default.addObserver(self, selector: #selector(orderRequestClearance(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_CLEAR_REQUEST), object: nil)
   }
    //MARK:- LOAD ORDER REQUEST DATA
    func loadOrderREquestData() {
        viewMap.clear()
        if objOrderDetail != nil{
            if objOrderDetail!.driverNote!.count > 0 {
                //SHOW TOOLTIP
                if(!popTip.isVisible) {
                    popTip.show(text: objOrderDetail!.driverNote ?? "", direction: .auto, maxWidth: 200, in: self.view, from: btnDriverNote.frame)
                }
                self.btnDriverNote.isHidden = false
            } else {
                self.btnDriverNote.isHidden = true
            }
            //BILLING DETAIL
            if let billingDetails = objOrderDetail?.billingDetail{
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
            
            let objCustomer = objOrderDetail?.customerDetail
            if (objCustomer?.firstName!.length)! > 0
            {
                lblName.text = "\(objCustomer?.firstName ?? "") \(objCustomer?.lastName ?? "")"
            } else {
                lblName.text = "\(objCustomer?.email?.components(separatedBy: "@")[0] ?? "")"
            }
            lblLocation.attributedText = createLocationMutableString(strLocation: objCustomer!.address!)
            if let imgUrl = objCustomer?.userImage{
                imgUser.sd_setImage(with: imgUrl.getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
            }
            else {
                imgUser.image = USER_AVTAR
            }
             ratingView.rating = Double(objCustomer!.rating!)
            ratingView.isUserInteractionEnabled = false
            //CALCULTE ORDER TIME
            if isFromNotification {
                orderRequestTime = getSecondsBetweenDates(date1: Date(), date2:serverToLocal(date: objOrderDetail!.requestDate!)! )
            }
           print("Order Request Time : \(orderRequestTime)")
            //CHECK IF TIME IS <= 1 MINUTE THEN DISPLAY THAT ORDER OTHERWISE REJECT THAT ORDER.
            if  Double(orderRequestTime) > 0 /* && Double(orderRequestTime) <= kDRIVER_REQUEST_TIME*/ {
                if isFromNotification{
                    APP_DELEGATE?.socketIOHandler?.joinOrderRoom(orderId: orderId)
                }
                tblOrderRequest.delegate = self
                tblOrderRequest.dataSource = self
                tblOrderRequest.reloadData()
                setUpTimerLabel()
                DispatchQueue.main.async {
                    self.FetchPolylineForRoute(to_lat: self.objOrderDetail!.deliveryLatitude!, to_long: self.objOrderDetail!.deliveryLongitude!)
                }
            } else {
                lblTimer.reset()
                btnAccept.isEnabled = false
                btnReject.isEnabled = false
                rejectOrder()
                ShowToast(message: "Order Request Time Out")
            }
        }
    }
    
    func getOrderDetail(orderId : Int) {
           if isNetworkConnected {
               switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                   case .connected?:
                       if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                           APP_DELEGATE!.socketIOHandler?.fetchOrderDetails(orderId: orderId, completion: { (objOrder) in
                               self.objOrderDetail = objOrder
                               if self.objOrderDetail != nil{
                                   self.loadOrderREquestData()
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
    
    //MARK:- SOCKET RELATED METHODS
   func JoinDriverWithSocket() {
        switch APP_DELEGATE!.socketIOHandler?.socket?.status{
           case .connected?:
               if (!APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                   let dict:NSMutableDictionary = NSMutableDictionary()
                   dict.setValue(USER_OBJ?.userId, forKey: "user_id")
                   APP_DELEGATE!.socketIOHandler?.joinSocketWithData(data: dict)
               }
               break
           default:
              print("Socket Not Connected")
       }
   }
    
    //MARK:- STRECHY HEADER RELATED METHODS
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: SCREEN_WIDTH, height: kTableHeaderHeight)
        if tblOrderRequest.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tblOrderRequest.contentOffset.y
            headerRect.size.height = -tblOrderRequest.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    //MARK:- MAP RELATED METHODS
    @objc func setMapCameraPositionToDriverCurrentLocation()  {
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(CURRENT_LATITUDE) )!, longitude: CLLocationDegrees(exactly: Double(CURRENT_LONGITUDE) )!)
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 15.0)
        viewMap.camera = camera
        viewMap.isMyLocationEnabled = true
        viewMap.animate(to: camera)
        
        removeNotificationOnservers(notificationName: ncNOTIFICATION_LOCATION_UPDATE)
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
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s1.length))
        
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s2.length))
        
        s1.append(s2)
        
        return s1
    }
    
    func setUpTimerLabel() {
        lblTimer.reset()
        lblTimer.timeFormat = "mm:ss"
        lblTimer.timerType = MZTimerLabelTypeTimer
        lblTimer.setCountDownTime(TimeInterval(orderRequestTime))
        lblTimer.start()
        if isFromNotification {
            lblTimer.delegate = self
        }
        isTimerLabelAdded = true
    }
    
    func stopTimerLabel()  {
        lblTimer.pause()
    }
    @objc func orderRejectFromHome(notification : Notification) {
        let dic = notification.userInfo
        if dic!["order_id"] as? Int == objOrderDetail?.orderId {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func orderAcceptedResult(notification:Notification) {
        let d = notification.userInfo
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            if visibleViewCtrl.isKind(of: OrderRequestDetailVC.self) {
                ShowToast(message: d!["message"] as! String)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func orderRequestTimeout(notification:Notification) {
        let d = notification.userInfo
        if objOrderDetail != nil {
            if d!["order_id"] as? Int == objOrderDetail?.orderId {
                //REJECT THAT ORDER
                if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                    if visibleViewCtrl.isKind(of: OrderRequestDetailVC.self) {
                        ShowToast(message: "Your request time is over. Wait for next request.")
                    }
                }
                rejectOrder()
            }
        }
    }
    
    @objc func orderRequestClearance(notification : Notification) {
        let d = notification.userInfo
        if objOrderDetail != nil {
            if d!["order_id"] as? Int == objOrderDetail?.orderId {
                if (self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.OrderRejection)))!) {
                        self.delegate?.OrderRejection()
                        
                    }
            }
        }
    }
    //MARK:- DRAW PATH ON MAP
    func drawPathOnMap(witPolyline : String) {
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
        let latitude = objOrderDetail?.deliveryLatitude ?? "0.0"
        let longitude = objOrderDetail?.deliveryLongitude ?? "0.0"
        let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
        let  detailMarker = GMSMarker(position: pos)
        detailMarker.icon = UIImage(named: "markerBlue")
        detailMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        detailMarker.isTappable = false
        detailMarker.map = viewMap
        
        //ADD DISTANCE MARKER
        let centerPoint = (polyline.path?.coordinate(at: (polyline.path?.count() ?? 0) / 2))!   //block for small deails view in center of rout path
        //let sView = UIView()
        
        let distance = getDistance(lat1: Double(objOrderDetail?.deliveryLatitude ?? "") ?? 0.0, lon1: Double(objOrderDetail?.deliveryLongitude ?? "") ?? 0.0, lat2: CURRENT_LATITUDE, lon2: CURRENT_LONGITUDE)
        let approxTime = getAppoxTime(lat1: Double(objOrderDetail?.deliveryLatitude ?? "") ?? 0.0, lon1: Double(objOrderDetail?.deliveryLongitude ?? "") ?? 0.0, lat2: CURRENT_LATITUDE, lon2: CURRENT_LONGITUDE)
        
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
            self.viewMap.selectedMarker = distanceMArker
            distanceMArker.map = self.viewMap
            
            self.viewMap.animate(toBearing: -60.0)
        }
    }
    
    //MARK: - BUTTON ACTION
    @IBAction func btnBack(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDriverNoteClicked(_ sender : UIButton) {
        if let objOrder = objOrderDetail {
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
    @IBAction func btnAcceptOrder(_ sender : UIButton) {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        if let obj = objOrderDetail {
                            let d = getSingleOrderRequestQueue(orderId:  obj.orderId!)
                            var orderDrivers = ""
                            if d.count > 0 {
                                orderDrivers = d["order_drivers"] as! String
                            }
                            
                            if isFromNotification {
                                APP_DELEGATE!.socketIOHandler?.acceptOrderRequest(orderId: obj.orderId!, customerId: (obj.customerDetail!.userId)!, driverIds: orderDrivers, completion: { (dicResult) in
                                    if dicResult["status"] as! Int == 1 {
                                        self.tabBarController?.selectedIndex = 2
                                         
                                    } else {
                                        ShowToast(message: dicResult["message"] as! String)
                                    }
                                    NotificationCenter.default.post(name: NSNotification.Name(ncNOTIFICATION_CLEAR_REQUEST), object: nil, userInfo: ["order_id" : obj.orderId!])
                                    self.navigationController?.popViewController(animated: true)
                                })
                            } else {
                               if d.count > 0 {
                                    APP_DELEGATE!.socketIOHandler?.acceptOrderRequest(orderId: obj.orderId!, customerId: (obj.customerDetail!.userId)!, driverIds: orderDrivers, completion: { (dicResult) in
                                        if (self.delegate?.responds(to: #selector(self.delegate?.OrderAccept(dicResult:))))! {
                                            self.delegate?.OrderAccept(dicResult: dicResult)
                                        }
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                }
                            }
                        }
                    }
                    break
                default:
                   print("Socket Not Connected")
            }
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    @IBAction func btnRejectOrder(_ sender : UIButton) {
       rejectOrder()
    }
    
    func rejectOrder() {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                         if let obj = objOrderDetail {
                             APP_DELEGATE!.socketIOHandler?.rejectOrder(orderId: obj.orderId!, customerId: obj.customerDetail!.userId!, completion: { (isRejected) in
                                 if isRejected {
                                  
                                  if self.isFromNotification {
                                      NotificationCenter.default.post(name: NSNotification.Name(ncNOTIFICATION_CLEAR_REQUEST), object: nil, userInfo: ["order_id" : self.objOrderDetail!.orderId!])
                                  } else {
                                      if (self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.OrderRejection)))!) {
                                                                         self.delegate?.OrderRejection()
                                             
                                                                     }
                                  }
                                 
                                  self.navigationController?.popViewController(animated: true)
                                 }
                             })

                         }
                    }
                    break
                default:
                   print("Socket Not Connected")
            }
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    
}

//MARK:- MZTIMERLABEL DELEGATE METHOD
extension OrderRequestDetailVC : MZTimerLabelDelegate{
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        ShowToast(message: "Your request time is over. Wait for next request.")
        if isFromNotification {
            rejectOrder()
        }
        
    }
}

//MARK:- TABLEVIEW DELEGATE & DATASORURCE METHOD
extension OrderRequestDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (objOrderDetail?.stores!.count)! + 3 // + 2 note , Billing
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section > 0 && section <= (objOrderDetail?.stores!.count)! {
            return (objOrderDetail?.stores![section - 1].products!.count)!
        }
        else if section == (objOrderDetail?.stores!.count)! + 1
        {
            return manualStoreCount > 0 ? 1 : 0
        }
        else if section == (objOrderDetail?.stores!.count)! + 2
        {
            return 0//billingRowCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 && section <= (objOrderDetail?.stores!.count)! {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderStoreProductCell") as! OrderStoreProductCell
            let objStore = objOrderDetail?.stores![section - 1]
            cell.lblStoreName.text = objStore?.storeName
            cell.lblStoreLocation.attributedText = createLocationMutableString(strLocation: objStore!.storeAddress!)
            if let logoUrl = objStore!.storeLogo{
                cell.imgStore.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
            }
            else {
                cell.imgStore.image = QUE_AVTAR
            }
           
            return cell
        }
        else if  section == (objOrderDetail?.stores!.count)! + 1 || section == (objOrderDetail?.stores!.count)! + 2 {
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5))
            returnedView.backgroundColor = .groupTableViewBackground
            return returnedView
        }
       
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "OrderIdCell", for: indexPath) as! OrderIdCell
           cell.lblProductName.attributedText = createOrderIdMutableString(orderId: objOrderDetail?.orderId ?? 0)
           cell.imgSeparator.isHidden = false
           if objOrderDetail?.deliveryOption == DELIVERY_OPTION.Standard.rawValue {
               cell.constraintImgExpressWidth.constant = 0.0
               cell.constraintLabelExpressWidth.constant = 0.0
           } else {
               cell.constraintImgExpressWidth.constant = 26.0
               cell.constraintLabelExpressWidth.constant = 60.0
           }
            cell.layoutIfNeeded()
           return cell
        }
        else if indexPath.section == (objOrderDetail?.stores!.count)! + 1 {
             if let cell = tableView.dequeueReusableCell(withIdentifier: "TermAndConditionChildTVC", for: indexPath) as? TermAndConditionChildTVC {
                  cell.lblTnCNote.attributedText = add(stringList: ["Please attach the receipt. After then manual store items Bill will shown. "], font: UIFont(name: "Montserrat-Regular", size: 15.0)!)
                  cell.selectionStyle = .none
                  return cell
              }
          }
        else if indexPath.section == (objOrderDetail?.stores!.count)! + 2 {
              let couponDiscount = objOrderDetail?.billingDetail?.couponDiscount ?? 0
              let orderDiscount = objOrderDetail?.billingDetail?.orderDiscount ?? 0
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
                  cell.lblRegisterdStoreName.text = "\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
                  cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
                  cell.StoreDiscountView.isHidden = objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
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
                  cell.lblRegisterdStoreName.text = "\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
                  
                  cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
                  cell.StoreDiscountView.isHidden = objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                  cell.viewOrderAndCouponDiscount.isHidden = true
                  cell.selectionStyle = .none
                  return cell
              }else if  indexPath.row < registeredStoreCount
              {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderRegisterdStoreBillDetailsTVCell", for: indexPath) as! ConfirmOrderRegisterdStoreBillDetailsTVCell
                  cell.billDetailsHeaderHeight.constant = 0
                  cell.viewRegisterdStoreDetails.isHidden = false
                  cell.viewBottomSaperator.isHidden = false
                  cell.lblRegisterdStoreName.text = "\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeName ?? "") Items Total"
                  cell.lblRegisterdStoreItemTotalAmt.text = "\(Currency)\(objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].storeAmount ?? 0)"
                  cell.StoreDiscountView.isHidden = objOrderDetail?.billingDetail?.registeredStores?[indexPath.row].isStoreOffer ?? 0 == 0
                  if indexPath.row == (objOrderDetail?.billingDetail?.registeredStores?.count  ?? 0 - 1)
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
                  let manualStoreDetials = objOrderDetail?.billingDetail?.manualStores?[indexcount]
                  cell.lblStoreName.text = "\(manualStoreDetials?.storeName ?? "") Items Total"
                  cell.lblStoreAmt.text = manualStoreDetials?.storeAmount ?? 0 == 0 ? "-" : "\(Currency)\(manualStoreDetials?.storeAmount ?? 0)"
                  cell.selectionStyle = .none
                  return cell
              }
              else
              {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmOrderOtherBillDetailsTVCell", for: indexPath) as! ConfirmOrderOtherBillDetailsTVCell
                  cell.lblToPayAmt.text = "\(Currency)\(objOrderDetail?.billingDetail?.totalPay ?? 0)"
                  cell.lblServiceChargeAmt.text = objOrderDetail?.billingDetail?.serviceCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(objOrderDetail?.billingDetail?.serviceCharge ?? 0)"
                  cell.lblDeliveryFeeAmt.text = objOrderDetail?.billingDetail?.deliveryCharge ?? 0 == 0 ? "FREE" : "\(Currency)\(objOrderDetail?.billingDetail?.deliveryCharge ?? 0)"
                  cell.viewShoppingCharge.isHidden = objOrderDetail?.billingDetail?.shoppingFee ?? 0 == 0
                  cell.lblShoppingFeeAmt.text = "\(Currency)\(objOrderDetail?.billingDetail?.shoppingFee ?? 0)"
                  cell.selectionStyle = .none
                  return cell
              }
          }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell", for: indexPath) as! OrderProductCell
            let objProduct = objOrderDetail?.stores![indexPath.section - 1].products![indexPath.row]
            cell.lblProductName.attributedText = createProductMutableString(strProductName: objProduct!.productName!, strDetaail: objProduct!.productDescription!)
            
            return cell
        }
       return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        /*if section == 0 {
            return 0.0
        }
        return UITableView.automaticDimension*/
        if section == 0 {
            return 0.0
        } else if section > 0 && section <= (objOrderDetail?.stores!.count)! {
            return UITableView.automaticDimension
        }
        else if section == (objOrderDetail?.stores!.count)! + 1
        {
            return manualStoreCount > 0 ? 5 : 0
        }
        else if section == (objOrderDetail?.stores!.count)! + 2
        {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        /*if section == 0 {
            return 0.0
        }else {
            return 74.0
        }*/
        if section == 0 {
           return 0.0
       } else if section > 0 && section <= (objOrderDetail?.stores!.count)! {
            return 74.0
       }
       else if section == (objOrderDetail?.stores!.count)! + 1
       {
           return manualStoreCount > 0 ? 5 : 0
       }
       else if section == (objOrderDetail?.stores!.count)! + 2
       {
           return 5
       }
       return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 31.0
    }
    
}
