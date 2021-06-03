//
//  DeliveryRouteVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 31/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleMaps

class DeliveryRouteVC: UIViewController {
    //CONSTANTS
       
    //VARIABLES
    var orderDetails : OrderDetail?
    var futureOrderDetails : FutureOrders?
    var routeInfoWindow : CustomRouteInfoView? = nil
    var driverLatitude : Double = 0.0
    var driverLongitude : Double = 0.0
    var strPolyline : String = ""
    var arrSortedStores = [[String:Any]]() //SORTED ARRAY
    var isFromFutureOrder : Bool = false
    var  currentMarker = GMSMarker()
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitleTrip: UILabel!
    @IBOutlet weak var lblRunningTrip: UILabel!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var viewContainer: CardView!
    @IBOutlet weak var collectionStore: UICollectionView!
   
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
       super.viewDidLoad()
       setMapCameraPositionToDriverCurrentLocation()
       allNotificationCenterObservers()
       initializations()
       setupGUI()
    }
   
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       
    }
   //MARK:- SETUP & INITIALISATION
   func initializations()  {
        collectionStore.register("StoreSlidingCell")
   }
    
   func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
                       
        lblTitle.text = "Delivery Route"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
       
        lblTitleTrip.text = "Running Trip"
        lblTitleTrip.textColor = SKYBLUE_COLOR
        lblTitleTrip.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18.0))
    
        lblRunningTrip.text = "0 mins(0 kms)"
        lblRunningTrip.textColor = .darkGray
        lblRunningTrip.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 15.0))
    
        loadData()
   }
    
    func allNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setMapCameraPositionToDriverCurrentLocation), name: NSNotification.Name(rawValue: ncNOTIFICATION_LOCATION_UPDATE), object: nil)
    }
    
    func loadData() {
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(CURRENT_LATITUDE) )!, longitude: CLLocationDegrees(exactly: Double(CURRENT_LONGITUDE) )!)
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 15.0)
        viewMap.camera = camera
        viewMap.isMyLocationEnabled = true
        viewMap.animate(to: camera)
        
        driverLongitude = CURRENT_LONGITUDE
        driverLatitude = CURRENT_LATITUDE
        
        let deliveryLat = isFromFutureOrder ? futureOrderDetails?.deliveryLatitude ?? "0.0" : orderDetails?.deliveryLatitude ?? "0.0"
        let deliveryLong = isFromFutureOrder ? futureOrderDetails?.deliveryLongitude ?? "0.0" : orderDetails?.deliveryLongitude ?? "0.0"
        
        let distance = getDistance(lat1:driverLatitude, lon1: driverLongitude, lat2: Double(deliveryLat) ?? 0.0, lon2: Double(deliveryLong) ?? 0.0)
        let approxTime = getAppoxTime(lat1:driverLatitude, lon1: driverLongitude, lat2: Double(deliveryLat) ?? 0.0, lon2: Double(deliveryLong) ?? 0.0)
        
        if approxTime == "0 mins" {
            lblRunningTrip.text = "Nearer to destination"
        }else {
            lblRunningTrip.text = "\(approxTime)(\(distance))"
        }
        
        //ADD DELIVERY ADDRESS MARKER
        let latitude = deliveryLat
        let longitude = deliveryLong
        let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
        let  detailMarker = GMSMarker(position: pos)
        detailMarker.icon = UIImage(named: "destination_mark")
        detailMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        detailMarker.isTappable = false
        detailMarker.map = viewMap
        
        //ADD CURRENT MARKER
        let current_latitude = CURRENT_LATITUDE
        let current_longitude = CURRENT_LONGITUDE
        let current_pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(current_latitude) )!, longitude: CLLocationDegrees(exactly: Double(current_longitude) )!)
        currentMarker = GMSMarker(position: current_pos)
        currentMarker.icon = UIImage(named: "current_marker")
        currentMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        currentMarker.isTappable = false
        currentMarker.map = viewMap
        
//        if strPolyline.count > 0 {
//            drawPathOnMap(witPolyline: strPolyline)
//        }else {
//            self.FetchPolylineForRoute(to_lat: self.orderDetails!.deliveryLatitude!, to_long: self.orderDetails!.deliveryLongitude!)
//        }
        
        for objStore in isFromFutureOrder ? futureOrderDetails!.stores! : orderDetails!.stores! {
            var d = [String : Any]()
            d["store"] = objStore
            
            let distance = getDistance(lat1: Double(objStore.latitude ?? "") ?? 0.0, lon1: Double(objStore.longitude ?? "") ?? 0.0, lat2: CURRENT_LATITUDE, lon2: CURRENT_LONGITUDE)
            if distance.count > 0{
                let a = distance.components(separatedBy: " ")
                if a.count > 0 {
                    d["distance"] = Double(a[0] )
                } else {
                    d["distance"] = 0.0
                }
            }else {
                d["distance"] = 0.0
            }
            arrSortedStores.append(d)
        }
        arrSortedStores = arrSortedStores.sorted { $0["distance"] as? Double ?? .zero < $1["distance"] as? Double ?? .zero }
        
        collectionStore.backgroundColor = .clear
        collectionStore.delegate = self
        collectionStore.dataSource = self
        collectionStore.reloadData()
        
        
        for i in 0..<arrSortedStores.count {
            let obj = arrSortedStores[i]
            let objStore = obj["store"] as! Stores
            
            if i == 0 {
                self.FetchPolylineForRoute(to_lat: objStore.latitude ?? "", to_long: objStore.longitude ?? "", from_lat: "\(CURRENT_LATITUDE)", from_long: "\(CURRENT_LONGITUDE)")
            } else {
                let prevObj = arrSortedStores[i - 1]
                let prevObjStore = prevObj["store"] as! Stores
                var toLat = ""
                var toLong = ""
                toLat =  objStore.latitude ?? ""
                toLong =  objStore.longitude ?? ""
                
                self.FetchPolylineForRoute(to_lat: toLat, to_long: toLong, from_lat: prevObjStore.latitude ?? "", from_long: prevObjStore.longitude ?? "")
            }
            
            let lastObj = arrSortedStores.last
            let lastObjStore = lastObj!["store"] as! Stores
            self.FetchPolylineForRoute(to_lat: deliveryLat, to_long: deliveryLong, from_lat: lastObjStore.latitude ?? "", from_long: lastObjStore.longitude ?? "")
            
            //ADD STORE MARKER
            DispatchQueue.main.async {
               let storeWindow = StoreNumberInfoWindow(nibName: "StoreNumberInfoWindow", bundle: nil)
                let point =  CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(objStore.latitude ?? "")! )!, longitude: CLLocationDegrees(exactly: Double(objStore.longitude ?? "")! )!)
                storeWindow.setValues(number: "\(i + 1)")
                self.routeInfoWindow?.setValues(distance: distance, time: approxTime)
                let  m = GMSMarker(position: point)
                m.iconView = storeWindow.view
                m.infoWindowAnchor = CGPoint(x: 1, y: 1)
                m.isTappable = false
                self.viewMap.selectedMarker = m
                m.map = self.viewMap
            }
        }
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func btnBack(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- MAP RELATED METHODS
    @objc func setMapCameraPositionToDriverCurrentLocation()  {
        let NewPosition = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(CURRENT_LATITUDE) )!, longitude: CLLocationDegrees(exactly: Double(CURRENT_LONGITUDE) )!)
       /* let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 15.0)
        viewMap.camera = camera
        viewMap.isMyLocationEnabled = true
        viewMap.animate(to: camera)*/
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        
        currentMarker.position = NewPosition
        CATransaction.commit()

        viewMap.animate(toLocation: currentMarker.position)
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
        
        
        
        /*
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
            self.viewMap.selectedMarker = distanceMArker
            distanceMArker.map = self.viewMap

            self.viewMap.animate(toBearing: -60.0)
        }*/
        self.viewMap.animate(toBearing: -60.0)
    }
}

//MARK:- UICOLLECIONVIEW DELEGATE DATASOURCE METHODS
extension DeliveryRouteVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (arrSortedStores.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreSlidingCell", for: indexPath) as! StoreSlidingCell
        let d = arrSortedStores[indexPath.row]
        let objStore = d["store"] as! Stores //orderDetails?.stores![indexPath.row]
        cell.lblStoreName.text = objStore.storeName
        cell.lblLocation.text = objStore.storeAddress
        if let logoUrl = objStore.storeLogo{
           cell.imgStore.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
       }
       else {
           cell.imgStore.image = QUE_AVTAR
       }
        cell.lblKms.text = "\(getDistance(lat1: driverLatitude, lon1: driverLongitude, lat2: Double(objStore.latitude ?? "") ?? 0.0, lon2: Double(objStore.longitude ?? "") ?? 0.0))"
        cell.btnRating.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 80.0, height:collectionView.frame.height)
    }
    
    
}
