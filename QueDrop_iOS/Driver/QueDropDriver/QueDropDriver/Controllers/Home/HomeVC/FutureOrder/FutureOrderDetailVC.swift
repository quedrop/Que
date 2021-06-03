//
//  FutureOrderDetailVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 16/06/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleMaps
import FloatRatingView

class FutureOrderDetailVC: UIViewController {
    //CONSTANTS
    var kTableHeaderHeight:CGFloat = 250.0
    
    //VARIABLES
    var orderId : Int = 0
    var orderDetails : FutureOrders?
    var routeInfoWindow : CustomRouteInfoView? = nil
    var strPoliline : String = ""
    var headerView: UIView!
    var isPolilineDrawn : Bool = false
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var constraintBtnConfirmHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBtnConfirmHeightRatio: NSLayoutConstraint!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewCustomerInfo: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    
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
            orderId = od.recurringOrderId!
        }
        getOrderDetail()
    }
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        tblView.register(UINib(nibName: "OrderUserCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderUserCell")
        tblView.register(UINib(nibName: "OrderStoreProductCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "OrderStoreProductCell")
        tblView.register("OrderProductCell")
        tblView.register("OrderAmountDateCell")
        tblView.register(UINib(nibName: "OrderProductCell", bundle: nil), forCellReuseIdentifier: "OrderIdCell")
    }
    
    func setupGUI() {
        viewCustomerInfo.isHidden = true
        updateViewConstraints()
        self.view.layoutIfNeeded()
        viewBG.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Order Details"
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tblView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tblView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        
        lblName.textColor = .black
        lblName.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 15.0))
        
        lblLocation.textColor = .darkGray
        lblLocation.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 12.0))
        
        ratingView.isUserInteractionEnabled = false
        drawBorder(view: btnChat, color: .clear, width: 0.0, radius: 5.0)
        makeCircular(view: imgUser)
        
        //FOR STRECHY HEADER
        
        headerView = tblView.tableHeaderView
        tblView.tableHeaderView = nil
        tblView.addSubview(headerView)
        tblView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tblView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
        
        drawBorder(view: btnConfirm, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: tblView, color: .clear, width: 0.0, radius: 5.0)
        
        tblView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tblView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tblView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tblView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        tblView.isHidden = true
        
    }
    
    //MARK:- LOAD ORDER DATA
    func loadOrderData() {
        
        self.tblView.isHidden = false
        viewCustomerInfo.isHidden = false
        
        self.FetchPolylineForRoute(to_lat: self.orderDetails!.deliveryLatitude!, to_long: self.orderDetails!.deliveryLongitude!)
        
        tblView.delegate = self
        tblView.dataSource = self
        tblView.reloadData()
        
        if let objCustomer = orderDetails?.customerDetail {
            if (objCustomer.firstName!.length) > 0
            {
                lblName.text = "\(objCustomer.firstName ?? "") \(objCustomer.lastName ?? "")"
            } else {
                lblName.text = "\(objCustomer.email?.components(separatedBy: "@")[0] ?? "")"
            }
            lblLocation.attributedText = createLocationMutableString(strLocation: objCustomer.address!)
            if let imgUrl = objCustomer.userImage{
                imgUser.sd_setImage(with: imgUrl.getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
            }
            else {
                imgUser.image = USER_AVTAR
            }
            ratingView.rating = Double(objCustomer.rating!)
            btnChat.isHidden = true
        }
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
    
    @objc func btnChatClicked(sender : UIButton) {
        
        /*if let objCustomer = orderDetails?.customerDetail {
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
         }*/
    }
    
    func getOrderDetail()  {
        if isNetworkConnected {
            getSingleFutureOrderDetail(orderId: orderId)
        } else {
            ShowToast(message: kCHECK_INTERNET_CONNECTION)
        }
    }
    
    @objc func btnAcceptClicked(btn : UIButton) {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        let entryId = (orderDetails?.recurringOrderEntries![btn.tag].recurringEntryId)!
                        APP_DELEGATE?.socketIOHandler?.acceptRejectFutureOrderRequest(recurringOrderId: orderDetails!.recurringOrderId!, recurringEntryId: entryId, isAccept: 1, completion: { (dicResult) in
                            if dicResult["status"] as! Int == 1 {
                                self.getOrderDetail()
                            }
                            ShowToast(message: dicResult["message"] as! String)
                            
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
    
    @objc func btnRejectClicked(btn : UIButton) {
        if isNetworkConnected {
            switch APP_DELEGATE!.socketIOHandler?.socket?.status{
                case .connected?:
                    if (APP_DELEGATE!.socketIOHandler!.isJoinSocket){
                        let entryId = (orderDetails?.recurringOrderEntries![btn.tag].recurringEntryId)!
                        APP_DELEGATE?.socketIOHandler?.acceptRejectFutureOrderRequest(recurringOrderId: orderDetails!.recurringOrderId!, recurringEntryId: entryId, isAccept: 0, completion: { (dicResult) in
                            if dicResult["status"] as! Int == 1 {
                                self.getOrderDetail()
                            }
                            ShowToast(message: dicResult["message"] as! String)
                            
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
    
    func createRecurranceMutableString(objEntry : RecurringOrderEntries) -> NSMutableAttributedString {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var date = df.date(from:objEntry.orderDeliveryDatetime!)!
        date = date.UTCtoLocal().toDate()!
        
        let df1 = DateFormatter()
        df1.dateFormat = "EEEE"
        
        let df3 = DateFormatter()
        df3.dateFormat = "hh:mm a"
        
        let df2 = DateFormatter()
        df2.dateFormat = "dd MMMM yyyy"
        
        let s1 = NSMutableAttributedString(string: "\(df1.string(from: date)) at \(df3.string(from: date))\n")
        let s2 = NSMutableAttributedString(string: "\(df2.string(from: date))\n")
        let s3 = NSMutableAttributedString(string: orderDetails!.recurringType!)
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 15.0))!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s1.length))
        
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 14.0))!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, s2.length))
        
        s3.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 14.0))!, range: NSMakeRange(0, s3.length))
        s3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, s3.length))
        
        s1.append(s2)
        s1.append(s3)
        return s1
    }
    
    
    //MARK:- STRECHY HEADER RELATED METHODS
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
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

//MARK: - GMSMAPVIEW DELEGATE
extension FutureOrderDetailVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "DeliveryRouteVC") as! DeliveryRouteVC
        vc.futureOrderDetails = orderDetails
        vc.strPolyline = strPoliline
        vc.isFromFutureOrder = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- TABLEVIEW DELEGATE & DATASORURCE METHOD
extension FutureOrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (orderDetails?.stores!.count)! + 2 // + 1 For Recurring entries
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section > 0 && section <= (orderDetails?.stores!.count)! {
            return (orderDetails?.stores![section - 1].products!.count)!
        } else if section == (orderDetails?.stores!.count)! + 1 {
            return (orderDetails?.recurringOrderEntries!.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 && section <= (orderDetails?.stores!.count)! {
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "OrderStoreProductCell") as! OrderStoreProductCell
            let objStore = orderDetails?.stores![section - 1]
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
        else if  section == (orderDetails?.stores!.count)! + 1 {
            let main = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50.0))
            main.backgroundColor = .white
            let returnedView = UIView(frame: CGRect(x: 0, y: 8, width: tableView.bounds.width, height: 5))
            returnedView.backgroundColor = .groupTableViewBackground
            main.addSubview(returnedView)
            let lbl = UILabel(frame: CGRect(x: 16, y: 13, width: tableView.bounds.width - 32, height: main.bounds.height - ( returnedView.bounds.height + 5)))
            lbl.text = "Recurrance Order Requests"
            lbl.textColor = .gray
            lbl.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 15.0))
            main.addSubview(lbl)
            return main
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderIdCell", for: indexPath) as! OrderProductCell
            cell.lblProductName.attributedText = createOrderIdMutableString(orderId: orderDetails?.recurringOrderId ?? 0)
            cell.imgSeparator.isHidden = false
            return cell
        }
        else if indexPath.section > 0 && indexPath.section <= (orderDetails?.stores!.count)! {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell", for: indexPath) as! OrderProductCell
            let objProduct = orderDetails?.stores![indexPath.section - 1].products![indexPath.row]
            cell.lblProductName.attributedText = createProductMutableString(strProductName: objProduct!.productName!, strDetaail: objProduct!.productDescription!)
            
            return cell
        } else if indexPath.section == (orderDetails?.stores!.count)! + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecurranceCell", for: indexPath) as! RecurranceCell
            let objEntry = orderDetails?.recurringOrderEntries![indexPath.row]
            
            cell.lblEntry.attributedText = createRecurranceMutableString(objEntry: objEntry!)
            
            cell.btnAccept.tag = indexPath.row
            cell.btnReject.tag = indexPath.row
            cell.stackButton.isHidden = false
            
            if objEntry?.isAccepted == 1 {
                if objEntry?.driverId == USER_ID {
                    drawBorder(view: cell.btnAccept, color: GREEN_COLOR, width: 0.5, radius: 5.0)
                    cell.btnAccept.setTitleColor(GREEN_COLOR, for: .normal)
                    cell.btnAccept.setTitle("ACCEPTED", for: .normal)
                    cell.btnAccept.backgroundColor = .clear
                }
            } else {
                
            }
            
            if (objEntry?.rejectedDrivers!.count)! > 0 {
                let arrR = objEntry?.rejectedDrivers?.components(separatedBy: ",")
                if (arrR?.contains("\(USER_ID)"))! {
                    cell.btnRejected.isHidden = false
                    cell.stackButton.isHidden = true
                } else {
                    cell.btnRejected.isHidden = true
                    cell.stackButton.isHidden = false
                }
            } else {
                cell.btnRejected.isHidden = true
            }
            
            cell.btnAccept.addTarget(self, action: #selector(btnAcceptClicked(btn:)), for: .touchUpInside)
            cell.btnReject.addTarget(self, action: #selector(btnRejectClicked(btn:)), for: .touchUpInside)
          //  cell.lblProductName.attributedText = createProductMutableString(strProductName: objProduct!.productName!, strDetaail: objProduct!.productDescription!)
            
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
        } else {
            return UITableView.automaticDimension
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.0
        } else if section > 0 && section <= (orderDetails?.stores!.count)! {
            return 74.0
        } else if section == (orderDetails?.stores!.count)! + 1 {
            return 50.0
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
