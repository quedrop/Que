//
//  ViewAvailableDriverVC.swift
//  QueDropCustomer
//
//  Created by C100-174 on 22/09/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewAvailableDriverVC: UIViewController {
    
    //MARK:- CONSTANTS
    
    
    //MARK:- VARIABLES
//    var deliveryLatitude = ""
//    var deliveryLongtude = ""
    var deliveryOption = ""
    var arrDrivers = [NearbyDrivers]()
    var storeDetail : FathestStoreDetails?
    var timer = Timer()
    var isStoreMarked = false
    
    //MARK:- IBOUTLETS
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var viewMap: GMSMapView!
    @IBOutlet var viewLocating: UIView!
    @IBOutlet var activityIndicatore: UIActivityIndicatorView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
        setupGUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    //MARK:- INITIALIZATION AND SETUP
    func initialization() {
    }
    
    func setupGUI() {
        viewLocating.isHidden = true
        viewMap.animate(to: GMSCameraPosition(latitude: Double(defaultAddress?.latitude ?? "0.0")!, longitude: Double(defaultAddress?.longitude ?? "0.0")!, zoom: 9))
        loadData()
        RepeatTimer()
    }
    
    func RepeatTimer() {
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    @objc func loadData() {
        if isNetworkConnected {
            switch APP_DELEGATE.socketIOHandler?.socket?.status {
                case .connected?:
                    APP_DELEGATE.socketIOHandler?.getNearestDrivers(deliveryOption: deliveryOption, completion: { (driverArray, objStore) in
                        self.arrDrivers = driverArray
                        self.storeDetail = objStore
                        //BindData
                        self.bindDataOnMapView()
                    })
                break
                        
                default:
                    viewLocating.isHidden = false
                    print("Socket Not Connected")
                    break;
            }
        } else {
            showAlert(title: "Ooops..", message: kCHECK_INTERNET_CONNECTION)
        }
    }
    
    func bindDataOnMapView() {
        viewMap.clear()
        if arrDrivers.count > 0 {
            self.lblTitle.text = arrDrivers.count == 1 ? "\(arrDrivers.count) driver available" : "\(arrDrivers.count) drivers available"
            self.viewLocating.isHidden = true
            for objD in arrDrivers {
                var driverMarker = GMSMarker()
                let DLat = Double(objD.latitude!) ?? 0.0
                let DLong = Double(objD.longitude!) ?? 0.0
                let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: DLat) ?? 0.0, longitude: CLLocationDegrees(exactly: DLong) ?? 0.0)
                driverMarker = getMarker(title: "", desc: "\(objD.distance ?? 0) KM", image: UIImage(named: "motorcycle")!, position: pos)
                driverMarker.map = viewMap
            }
        } else {
            self.lblTitle.text = "Available drivers"
            viewLocating.isHidden = false
        }
        
            if let obj = storeDetail {
                //STORE MARKER
                var StoreMarker = GMSMarker()
                let storeLat = Double(obj.storeLat!) ?? 0.0
                let storeLong = Double(obj.storeLong!) ?? 0.0
                let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: storeLat) ?? 0.0, longitude: CLLocationDegrees(exactly: storeLong) ?? 0.0)
                StoreMarker = getMarker(title: obj.storeId! > 0 ? obj.storeName! : obj.userStoreName!, desc: obj.storeId! > 0 ? obj.storeAddress! : obj.userStoreAddress!, image: setImageTintColor(image: UIImage(named:  "mark_home"), color: THEME_COLOR)!, position: pos)
                StoreMarker.map = viewMap
                
                if !isStoreMarked {
                    viewMap.animate(to: GMSCameraPosition(latitude: storeLat, longitude: storeLong, zoom: 13))
                    isStoreMarked = true
                }
            }
       
        
    }
    
    func getMarker(title: String, desc: String, image:UIImage, position: CLLocationCoordinate2D) -> GMSMarker {
        // Creates a marker in the center of the map.
        let marker = GMSMarker(position: position)
        marker.icon = image
        marker.isDraggable = false
        marker.title = title
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.snippet = desc
        marker.appearAnimation = .pop
        return marker
    }
    
    //MARK:- BUTTONS
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
