//
//  HomeVC.swift
//  QueDropDriver
//
//  Created by KPA on 06/03/20.
//  Copyright © 2020 KPA. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps
import SwiftyJSON

class HomeVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    var isDriverOnline : Bool = false {
        didSet {
            if(isDriverOnline) {
                btnOnlineOffline.setImage(UIImage(named: "online"), for: .normal)
            } else {
                btnOnlineOffline.setImage(UIImage(named: "offline"), for: .normal)
            }
        }
    }
    var isTimerLabelAdded = false
    var objOrderDetail : OrderDetail?
    var routeInfoWindow : CustomRouteInfoView? = nil
    var orderRequestTime : TimeInterval = 0.0
    var userCell : OrderUserCell?
    var homeEarning : HomeEarning?
    
    //IBOUTLETS
    @IBOutlet weak var btnFutureOrder: UIButton!
    @IBOutlet weak var btnOnlineOffline: UIButton!
    @IBOutlet weak var btnEarning: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var tblOrderRequest: UITableView!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewORderRequest: CardView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewEarningContainer: CardView!
    @IBOutlet weak var collectionPager: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!
    
    //MARK:- VC LIFE CYCLE
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //tblOrderRequest.register("OrderUserCell")
        //tblOrderRequest.register("AcceptRejectCell")
        //tblOrderRequest.register("OrderStoreProductCell")
        tblOrderRequest.register(UINib(nibName: "OrderUserCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderUserCell")
        tblOrderRequest.register(UINib(nibName: "OrderStoreProductCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderStoreProductCell")
        tblOrderRequest.register("OrderProductCell")
    }
   
    func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
        
        setUpEarningView()
        
        self.btnFutureOrder.isHidden = true
        
        isDriverOnline = false
        drawShadow(view: btnOnlineOffline)
        drawBorder(view: btnAccept, color: .clear, width: 0.0, radius: 8.0)
        drawBorder(view: btnReject, color: .clear, width: 0.0, radius: 8.0)
        drawBorder(view: tblOrderRequest, color: .clear, width: 0.0, radius: 10.0)
        
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
        
        viewORderRequest.isHidden = true
        
        //JOIN DRIVER WITH SOCKET
        JoinDriverWithSocket()
        
        if getCurrentOrderRequest() == 0 {}
        else {
            checkForOrder(orderId: getCurrentOrderRequest())
            //getOrderDetail(orderId: getCurrentOrderRequest())
        }
       // getOrderDetail(orderId: 368)
        
        let tapToDetail = UITapGestureRecognizer(target: self, action: #selector(naviagetToOrderRequestDetail))
        tapToDetail.numberOfTapsRequired = 1
        tblOrderRequest.addGestureRecognizer(tapToDetail)
        
        
    }

    func allNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setMapCameraPositionToDriverCurrentLocation), name: NSNotification.Name(rawValue: ncNOTIFICATION_LOCATION_UPDATE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(driverStatus(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_SOCKET_DRIVER_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(driverStatusHasChange(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_SOCKET_CHANGE_DRIVER_STATUS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newOrderRequest(notification:)), name: NSNotification.Name(ncNOTIFICATION_NEW_ORDER_REQUEST), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderAcceptedResult(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_ACCEPTED_RESULT), object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(orderRequestTimeout(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_REQUEST_TIMEOUT), object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(orderRequestClearance(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_CLEAR_REQUEST), object: nil)
    }
    
    func setUpEarningView(){
        lblNoData.textColor = .gray
        lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        drawBorder(view: collectionPager, color: .clear, width: 0.0, radius: 5.0)
        viewEarningContainer.isHidden = true
        collectionPager.delegate = self
        collectionPager.dataSource = self
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
                getDriverWorkingStatus()
                break
            default:
               print("Socket Not Connected")
        }
                  
    }
    
    func getDriverWorkingStatus()  {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        APP_DELEGATE!.socketIOHandler?.getDriverWorkingStatus()
                    }
                    break
                default:
                   print("Socket Not Connected")
            }
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    
    func changeDriverWorkingStatus()  {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        APP_DELEGATE!.socketIOHandler?.ChangeDriverWorkingStatus(isOnline: isDriverOnline ? false : true)
                    }
                    break
                default:
                   print("Socket Not Connected")
            }
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
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
                                APP_DELEGATE?.socketIOHandler?.joinOrderRoom(orderId: orderId)
                                self.loadOrderRequestData()
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
    
    func checkForOrder(orderId : Int)  {
        let dic = getSingleOrderRequestQueue(orderId: orderId)
        if dic.count > 0 {
            let dicDetail = dic["order_details"] as! NSDictionary
            if dicDetail.count > 0 {
                let ObjDetail: OrderDetail = OrderDetail(json: JSON(dicDetail))
                objOrderDetail = ObjDetail
                if self.objOrderDetail != nil{
                    self.loadOrderRequestData()
                }
            } else {
                getOrderDetail(orderId: orderId)
            }
            
        } else {
            getOrderDetail(orderId: orderId)
        }
    }
    // MARK: - BUTTONS ACTIONS
    @IBAction func btnFutureOrderClicked(_ sender: Any) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "FutureOrderVC") as! FutureOrderVC
        navigationController?.pushViewController(vc, animated: true)
        //generateLocalNotification(title: "Identity verification", body: "dss", identifier: "Notification.driver_verifiy")
    }
    
    @IBAction func btnOnlineOfflineClicked(_ sender: Any) {
        if(USER_OBJ?.isDriverVerified != 0) {
            changeDriverWorkingStatus()
            //isDriverOnline = !isDriverOnline
        } else {
            showAlert(title:"Alert", message:  "You can't go online until your identity is verify by admin.")
        }
    }
    
    @IBAction func btnEarningClicked(_ sender: Any) {
        viewEarningContainer.isHidden = false
        collectionPager.reloadData()
        pageControl.currentPage = 0
        //CALL API FOR GET LATEST EARNING DATA
        getHomeEarningData()
    }
    
    @IBAction func btnEarningClosedClicked(_ sender: Any) {
        viewEarningContainer.isHidden = true
    }
    
    @objc func btnEarningPageClicked(btn : UIButton) {
        if btn.tag == 0 {
            //NAVIGATE TO VIEW ALL ORDER
            let vc = HomeStoryboard.instantiateViewController(withIdentifier: "ViewAllOrderVC") as! ViewAllOrderVC
            vc.arrOrders = homeEarning!.orderDetails!
            navigationController?.pushViewController(vc, animated: true)
        } else {
            //NAVIGATE TO VIEW WEEKLY RECORD
            self.tabBarController?.selectedIndex = tTAB_EARNING
            APP_DELEGATE?.FromHomeEarning = true
        }
        viewEarningContainer.isHidden = true
    }
    @objc func naviagetToOrderRequestDetail() {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderRequestDetailVC") as! OrderRequestDetailVC
        vc.objOrderDetail = objOrderDetail
        if userCell != nil{
            vc.orderRequestTime = (userCell?.lblTimer.getTimeRemaining())!
            vc.delegate = self
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- MAP RELATED METHODS
    @objc func setMapCameraPositionToDriverCurrentLocation()  {
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(CURRENT_LATITUDE) )!, longitude: CLLocationDegrees(exactly: Double(CURRENT_LONGITUDE) )!)
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 15.0)
        viewMap.camera = camera
        viewMap.isMyLocationEnabled = true
        viewMap.settings.myLocationButton = true
        viewMap.animate(to: camera)
        
        removeNotificationOnservers(notificationName: ncNOTIFICATION_LOCATION_UPDATE)
    }
    
    //MARK:- SOCKET FUNCTION OBSERVERS
    @objc func driverStatus(notification: Notification) {

        let dic = notification.userInfo
        let dicData = dic!["data"] as! [String:Any]
        isDriverOnline = dicData["driver_status"] as! Bool
        //removeNotificationOnservers(notificationName: ncNOTIFICATION_SOCKET_DRIVER_STATUS)
    }
    
    @objc func driverStatusHasChange(notification : Notification) {
        let dic = notification.userInfo as! [String : Any]
        isDriverOnline = (dic["is_online"] as! Int) == 1 ? true : false
    }
    
    @objc func newOrderRequest(notification: Notification) {
        viewMap.clear()
        let dic = notification.userInfo as! [String : Any]
        objOrderDetail = dic["order_detail"] as? OrderDetail
        loadOrderRequestData()
    }
    
    /*@objc func OrderRequestFromPush(notification: Notification) {
           viewMap.clear()
           let dic = notification.userInfo as! [String : Any]
            let d = dic["push_info"] as! [String : Any]
            if isNetworkConnected {
                switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                    case .connected?:
                        if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                            APP_DELEGATE!.socketIOHandler?.fetchOrderDetails(orderId: Int(d["order_id"] as! String)!, completion: { (objOrder) in
                                                                        
                                var dic = [String:Any]()
                                dic["order_id"] = Int(d["order_id"] as! String)!
                                dic["customer_id"] = Int(d["customer_id"] as! String)!
                                dic["order_drivers"] = d["order_drivers"] as! String
                                dic["order_details"] = objOrder.toDict()
                                
                                APP_DELEGATE?.socketIOHandler?.joinOrderRoom(orderId: Int(d["order_id"] as! String)!)
                                
                                addOrderRequestToQueue(dic: dic)
                                if getCurrentOrderRequest() == 0 {
                                    setCurrentOrderReequest(orderId: Int(PUSH_USER_INFO["order_id"] as! String)!)
                                    self.objOrderDetail = objOrder
                                    self.loadOrderRequestData()
                                }
                            })
                        }
                        break
                    default:
                       print("Socket Not Connected")
                }
            } else {
                //ShowToast(message: kCHECK_INTERNET_CONNECTION)
            }
        
       }*/
    
    @objc func orderAcceptedResult(notification:Notification) {
        let d = notification.userInfo
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            if visibleViewCtrl.isKind(of: HomeVC.self) {
                ShowToast(message: d!["message"] as! String)
            }
        }
        self.viewMap.clear()
        self.viewORderRequest.isHidden = true
        APP_DELEGATE?.socketIOHandler?.loadNextOrderIfThere()
    }
    
    @objc func orderRequestTimeout(notification:Notification) {
        let d = notification.userInfo
        if objOrderDetail != nil {
            if d!["order_id"] as? Int == objOrderDetail?.orderId {
                //REJECT THAT ORDER
                if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
                    if visibleViewCtrl.isKind(of: HomeVC.self) {
                        ShowToast(message: "Your request time is over. Wait for next request.")
                    }
                }
                
                rejectOrder()
                //postNotification(withName: ncNOTIFICATION_ORDER_REJECT_FROM_HOME_SCREEN, userInfo: ["order_id" : objOrderDetail?.orderId ?? 0])
                
            }
        }
    }
    
    @objc func orderRequestClearance(notification : Notification) {
        let d = notification.userInfo
        if objOrderDetail != nil {
            if d!["order_id"] as? Int == objOrderDetail?.orderId {
                self.objOrderDetail = nil
                self.viewORderRequest.isHidden = true
                self.viewMap.clear()
                APP_DELEGATE!.socketIOHandler?.loadNextOrderIfThere()
                self.setMapCameraPositionToDriverCurrentLocation()
            }
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
    
    func createOrderIdMutableString(orderId : Int, deliveryOption : String) -> NSMutableAttributedString {
        
        let s1 = NSMutableAttributedString(string: "Order ID: ")
        let s2 = NSMutableAttributedString(string: "#\(orderId)")
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s1.length))
        
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s2.length))
        
        s1.append(s2)
        
        if deliveryOption == DELIVERY_OPTION.Express.rawValue {
            let s3 = NSMutableAttributedString(string: "  with")
            let s4 = NSMutableAttributedString(string: " \(deliveryOption) Delivery")
            
            s3.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s3.length))
            s3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s3.length))
            
            s4.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0))!, range: NSMakeRange(0, s4.length))
            s4.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s4.length))
            //s4.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.patternDash.rawValue | NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, s4.length))
            
            s1.append(s3)
            s1.append(s4)
        }
        
        
        return s1
    }
    
    func setUpTimerLabel() {
        userCell = tblOrderRequest.headerView(forSection: 0) as? OrderUserCell
        userCell!.lblTimer.reset()
        userCell!.lblTimer.timeFormat = "mm:ss"
        userCell!.lblTimer.timerType = MZTimerLabelTypeTimer
        userCell!.lblTimer.setCountDownTime(TimeInterval(orderRequestTime))
        userCell!.lblTimer.start()
        userCell!.lblTimer.delegate = self
        isTimerLabelAdded = true
    }
    
    func loadOrderRequestData() {
        isTimerLabelAdded = false
        viewMap.clear()
        if objOrderDetail != nil{
            //CALCULTE ORDER TIME
            orderRequestTime = getSecondsBetweenDates(date1: Date(), date2:serverToLocal(date: objOrderDetail!.requestDate!)! )
           print("Order Request Time : \(orderRequestTime)")
            //CHECK IF TIME IS <= 1 MINUTE THEN DISPLAY THAT ORDER OTHERWISE REJECT THAT ORDER.
          if  Double(orderRequestTime) > 0 /*&& Double(orderRequestTime) <= kDRIVER_REQUEST_TIME*/ {
                viewORderRequest.isHidden = false
                tblOrderRequest.delegate = self
                tblOrderRequest.dataSource = self
                tblOrderRequest.reloadData()
                DispatchQueue.main.async {
                    self.FetchPolylineForRoute(to_lat: self.objOrderDetail!.deliveryLatitude!, to_long: self.objOrderDetail!.deliveryLongitude!)
                }
            } else {
                rejectOrder()
            }
        }
    }
    
    //MARK:- ORDER ACCEPT REJECT ACTION
    @IBAction func btnAcceptOrder(sender : UIButton) {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        let d = getSingleOrderRequestQueue(orderId:  objOrderDetail!.orderId!)
                        
                        if d.count > 0 {
                            APP_DELEGATE!.socketIOHandler?.acceptOrderRequest(orderId: objOrderDetail!.orderId!, customerId: (objOrderDetail?.customerDetail!.userId)!, driverIds: d["order_drivers"] as! String, completion: { (dicResult) in
                            
                                if dicResult["status"] as! Int == 1 {
                                    self.stopTimerLabel()
                                    self.objOrderDetail = nil
                                    self.viewORderRequest.isHidden = true
                                    self.viewMap.clear()
                                    self.tabBarController?.selectedIndex = 2
                                } else {
                                    ShowToast(message: dicResult["message"] as! String)
                                    self.rejectOrder()
                                }
                                self.setMapCameraPositionToDriverCurrentLocation()
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
    @IBAction func btnRejectOrder(sender : UIButton) {
        self.stopTimerLabel()
        rejectOrder()
    }
    
    func rejectOrder() {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        if objOrderDetail != nil {
                            APP_DELEGATE!.socketIOHandler?.rejectOrder(orderId: objOrderDetail!.orderId!, customerId: objOrderDetail!.customerDetail!.userId!, completion: { (isRejected) in
                                if isRejected {
                                    self.objOrderDetail = nil
                                    self.viewORderRequest.isHidden = true
                                    self.viewMap.clear()
                                    APP_DELEGATE!.socketIOHandler?.loadNextOrderIfThere()
                                    self.setMapCameraPositionToDriverCurrentLocation()
                                    
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
    
    func stopTimerLabel() {
        userCell = tblOrderRequest.headerView(forSection: 0) as? OrderUserCell
        userCell?.lblTimer.pause()
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
                self.viewMap!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 150.0))
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
    
}

//MARK:- TABLEVIEW DELEGATE & DATASORURCE METHOD

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (objOrderDetail?.stores!.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 || section == 2 {
            return (objOrderDetail?.stores![section - 1].products!.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderUserCell") as! OrderUserCell
            let objCustomer = objOrderDetail?.customerDetail
            if (objCustomer?.firstName!.length)! > 0
            {
                cell.lblName.text = "\(objCustomer?.firstName ?? "") \(objCustomer?.lastName ?? "")"
            } else {
                cell.lblName.text = "\(objCustomer?.email?.components(separatedBy: "@")[0] ?? "")"
            }
            cell.lblLocation.attributedText = createLocationMutableString(strLocation: objCustomer!.address!)
            if let imgUrl = objCustomer?.userImage{
                cell.imgUser.sd_setImage(with: imgUrl.getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
            }
            else {
                cell.imgUser.image = USER_AVTAR
            }
            cell.lblOrderId.attributedText = createOrderIdMutableString(orderId: objOrderDetail?.orderId ?? 0, deliveryOption: objOrderDetail?.deliveryOption ?? "")
            cell.ratingView.rating = Double(objCustomer!.rating!)
            return cell
        } else {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderStoreProductCell") as! OrderStoreProductCell
            let objStore = objOrderDetail?.stores![section - 1]
            cell.lblStoreName.text = objStore?.storeName
            cell.lblStoreLocation.attributedText = createLocationMutableString(strLocation: objStore!.storeAddress!)
            if let logoUrl = objStore!.storeLogo{
                cell.imgStore.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                //cell.imgStore.sd_setImage(with:  URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), completed: nil)
            }
            else {
                cell.imgStore.image = QUE_AVTAR
            }
            if !isTimerLabelAdded {
                setUpTimerLabel() //SET UP TIMER LABEL ONCE SECTION 0 IS GENERATED
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell", for: indexPath) as! OrderProductCell
        let objProduct = objOrderDetail?.stores![indexPath.section - 1].products![indexPath.row]
        cell.lblProductName.attributedText = createProductMutableString(strProductName: objProduct!.productName!, strDetaail: objProduct!.productDescription!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 78.0
        }else {
            return 74.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 31.0
    }
    
}

//MARK:- GOOGLE MAP DELEGATE METHODS

extension HomeVC: GMSMapViewDelegate {
   /* func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if self.routeInfoWindow != nil {
            self.routeInfoWindow?.view.removeFromSuperview()
            self.routeInfoWindow = nil
        
    }*/
}

//MARK:- MZTIMERLABEL DELEGATE METHOD
extension HomeVC : MZTimerLabelDelegate{
    func timerLabel(_ timerLabel: MZTimerLabel!, finshedCountDownTimerWithTime countTime: TimeInterval) {
        ShowToast(message: "Your request time is over. Wait for next request.")
        postNotification(withName: ncNOTIFICATION_ORDER_REJECT_FROM_HOME_SCREEN, userInfo: ["order_id" : objOrderDetail?.orderId ?? 0])
        if objOrderDetail != nil {
            rejectOrder()
        }
    }
}

//MARK:- ORDER REQUEST DETAIL DELEGATE METHOD
extension HomeVC : OrderRequestDetailVCDelegate{
    func OrderRejection() {
        self.viewORderRequest.isHidden = true
        APP_DELEGATE!.socketIOHandler?.loadNextOrderIfThere()
        self.viewMap.clear()
        stopTimerLabel()
        isTimerLabelAdded = false
        self.setMapCameraPositionToDriverCurrentLocation()
    }
    
    func OrderAccept(dicResult: [String : Any]) {
        self.viewORderRequest.isHidden = true
        self.viewMap.clear()
        isTimerLabelAdded = false
        stopTimerLabel()
        if dicResult["status"] as! Int == 1 {
            self.tabBarController?.selectedIndex = 2
        } else {
            ShowToast(message: dicResult["message"] as! String)
            //rejectOrder()
        }
        self.setMapCameraPositionToDriverCurrentLocation()
    }
}

//MARK:- COLLECTIONVIEW METHODS
extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if homeEarning != nil{
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EarningPagerCell", for: indexPath) as! EarningPagerCell
        if indexPath.row == 0 {
            cell.btnView.setTitle("View All Orders".uppercased(), for: .normal)
            cell.lblTitle1.text = "last order".uppercased()
            
            let dateStr = homeEarning?.lastOrderDate ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            var date = dateFormatter.date(from:dateStr)!
            date = date.UTCtoLocal().toDate()!
            cell.lblTitle2.text = "Last Order at \n\(DateFormatter(format: "hh:mm a").string(from: date))"
            
            cell.lblPrice.text = "\(Currency)\(homeEarning?.lastOrderTotalEarning ?? 0.0)"
        } else {
            cell.btnView.setTitle("See weekly summary".uppercased(), for: .normal)
            cell.lblTitle1.text = "today".uppercased()
            cell.lblTitle2.text = "\(homeEarning?.todayTotalOrder ?? 0) Trip Completed"
            cell.lblPrice.text = "\(Currency)\(homeEarning?.todayTotalEarning  ?? 0.0)"
        }
        cell.btnView.tag = indexPath.row
        cell.btnView.addTarget(self, action: #selector(btnEarningPageClicked(btn:)), for: .touchUpInside)
        
        DispatchQueue.main.async {
            drawBorder(view: cell.viewPrice, color: .lightGray, width: 0.5, radius: Float(cell.viewPrice.bounds.height/2.0))
            drawBorder(view: cell.lblPrice, color: .lightGray, width: 0.5, radius: Float(cell.lblPrice.bounds.height/2.0))
        }
        
        drawBorder(view: cell.btnView, color: .clear, width: 0.0, radius: 5.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: viewEarningContainer.bounds.width, height: viewEarningContainer.bounds.height - pageControl.bounds.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }
}
