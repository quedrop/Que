//
//  DriverLocationVC.swift
//  QueDrop
//
//  Created by C205 on 10/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import GoogleMaps
import  IHProgressHUD

class DriverLocationVC: UIViewController {

    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    var orderDetails : OrderDetails? = nil
    var orderId = 0
    var driverId = 0
    var oldLocation : CLLocationCoordinate2D?
    var newLocation : CLLocationCoordinate2D?
    var driverLat = ""
    var driverLong = ""
    var deliveryLatitude = ""
    var deliveryLongitude = ""
    var isPathDrawwn : Bool = false
    // Map Variables
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var zoomLevel: Float = 15.0
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nc.addObserver(self, selector: #selector(handleUpdateDriverLocation(notification:)), name: Notification.Name(notificationCenterKeys.driverLocationChanged.rawValue), object: nil)
        let d = ["driver_id" : driverId] as [String : Any]
        APP_DELEGATE.socketIOHandler?.StartDriverLocationUpdate(dic: d)
       // setUpMap()
        //Location Manager code to fetch current location
        newLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(driverLat) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(driverLong) ?? 0)!)
        oldLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(driverLat) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(driverLong) ?? 0)!)
         self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
        IHProgressHUD.show()
        setUpMap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
            
             self.drawRouteOnMap(lat: self.driverLat, long: self.driverLong)
        })
       
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        let d = ["driver_id" : driverId] as [String : Any]
        APP_DELEGATE.socketIOHandler?.StopDriverLocationUpdate(dic: d)
    }
   
   //MARK:- Handle PostNotification
    @objc func handleUpdateDriverLocation(notification:Notification){
        if let d = notification.userInfo
        {
            if d["driver_id"] as? Int == driverId {
                if let latitude = d["latitude"] as? String, let longitude = d["longitude"] as? String
                {
                    print("Current latitude :: ",latitude)
                    print("Current longitude :: ",longitude)
                    let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
                    if newLocation != nil
                    {   oldLocation = newLocation   }
                    newLocation = pos
                    if !isPathDrawwn {
                //        drawRouteOnMap(lat: latitude, long: <#T##String#>)
                    }
                }
            }
        }
        refreshMapWithNewLocation()
    }
    //Update Driver Location On Map
    func refreshMapWithNewLocation()
    {
        
        refreshLocation()
    }
    
    //MARK:- Functions
    func setdriver(id : Int,lat : String, long : String, orderDetails : OrderDetails, deliveryLatitude : String,deliveryLongitude :  String){
        self.orderDetails = orderDetails
        self.driverId = id
        self.driverLong = long
        self.driverLat = lat
        self.deliveryLatitude = deliveryLatitude
        self.deliveryLongitude = deliveryLongitude
    }
    
    //MARK:- Manage Map
    func setUpMap()
    {
        self.mapView.isMyLocationEnabled = true
        
        //let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
        let camera = GMSCameraPosition.camera(withLatitude: newLocation?.latitude ?? CLLocationDegrees(exactly: 0)!,
                                              longitude: newLocation?.longitude ?? CLLocationDegrees(exactly: 0)!,
                                              zoom:  15.0,
                                              bearing: 0,
                                              viewingAngle:  0)
        mapView.camera = camera
        marker.position = newLocation!
        marker.icon = #imageLiteral(resourceName: "driver")
        marker.appearAnimation = .pop
        marker.isDraggable = false
        mapView.delegate = self
        
        DispatchQueue.main.async
            {
                self.marker.map = self.mapView
        }
       
        self.mapView?.animate(to: camera)
    }
    func refreshLocation()
    {
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        
        marker.position = newLocation! //CLLocationCoordinate2DMake([[d valueForKey:@"currentLat"] doubleValue], [[d valueForKey:@"currentLong"] doubleValue]);
        /*
        let getAngle = angle(fromCoordinate: oldLocation!, toCoordinate: newLocation!)
        let startLocation = CLLocation(latitude: oldLocation?.latitude  ?? CLLocationDegrees(), longitude: oldLocation?.longitude ?? CLLocationDegrees())
        let endLocation = CLLocation(latitude: newLocation?.latitude ?? CLLocationDegrees(), longitude: newLocation?.longitude ?? CLLocationDegrees())
        let distance = startLocation.distance(from: endLocation)
        if distance > 2
        {
            marker.rotation = CLLocationDegrees(getAngle * (180.0 / .pi)) //[[d valueForKey:@"degree"] doubleValue];
        }
        */
        CATransaction.commit()

        mapView.animate(toLocation: marker.position)
        
    }
    func angle(fromCoordinate first: CLLocationCoordinate2D, toCoordinate second: CLLocationCoordinate2D) -> Float {

        let deltaLongitude = Float(second.longitude - first.longitude)
        let deltaLatitude = Float(second.latitude - first.latitude)
        let angle: Float = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)

        if deltaLongitude > 0 {
            return angle
        } else if deltaLongitude < 0 {
            return angle + .pi
        } else if deltaLatitude < 0 {
            return .pi
        }

        return 0.0
    }
    
    //MARK:- Fetch Path PoliString
    func fetchRoute() {

        let session = URLSession.shared

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(deliveryLatitude),\(deliveryLongitude)&destination=\(driverLat),\(driverLong)&sensor=false&mode=driving&key=\(GoogleMapKey)")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }
            else
            {
                print("error in JSONSerialization")
                return
            }

            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }

            guard let route = routes[0] as? [String: Any] else {
                return
            }

            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }

            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }

            //Call this method to draw path on map
            
            self.drawPath(from: polyLineString)
        })
        task.resume()
    }
    
    func fetchRoute(to_lat : String , to_long : String, from_lat:String, from_long : String) {

        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(from_lat ),\(from_long)&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GoogleMapKey)")!
        print("URL :: ",url)
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let jsonResponse : [String:Any]?
            if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
            {
                jsonResponse = jsonResult
            }
            else
            {
                print("error in JSONSerialization")
                return
            }

            guard let routes = jsonResponse!["routes"] as? [Any] else {
                return
            }
            if routes.count == 0
            {
                return
            }
            guard let route = routes[0] as? [String: Any] else {
                return
            }

            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }

            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }

            //Call this method to draw path on map
            
            self.drawPath(from: polyLineString)
        })
        task.resume()
    }
    //Draw line on map
        func drawPath(from polyStr: String){
           
            IHProgressHUD.dismiss()
            //self.oldPolyline = polyline
            DispatchQueue.main.async
            {

                 let path = GMSPath(fromEncodedPath: polyStr)
                 let polyline = GMSPolyline(path: path)
                 polyline.strokeWidth = 5.0
                polyline.map = self.mapView // Google MapView
                 polyline.strokeColor = strokeColor
                
             if self.mapView != nil
             {
              let bounds = GMSCoordinateBounds(path: path!)
              self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
             }
            }
    }
    
    func drawRouteOnMap( lat : String, long : String) {
        var arrSortedStores = [[String:Any]]()
        for objStore in orderDetails!.stores! {
            var d = [String : Any]()
            d["store"] = objStore
            let dist = distance(lat1: Double(objStore.latitude ?? "") ?? 0.0, lon1: Double(objStore.longitude ?? "") ?? 0.0, lat2: Double(lat) as! Double, lon2: Double(long) as! Double)
            if dist.count > 0{
                let a = dist.components(separatedBy: " ")
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
        
        for i in 0..<arrSortedStores.count {
            let obj = arrSortedStores[i]
            let objStore = obj["store"] as! CurrentOrderStores
            
            if i == 0 {
                DispatchQueue.main.async {
                    self.fetchRoute(to_lat: objStore.latitude ?? "", to_long: objStore.longitude ?? "", from_lat: "\(lat)", from_long: "\(long)")
                }
            } else {
                let prevObj = arrSortedStores[i - 1]
                let prevObjStore = prevObj["store"] as! CurrentOrderStores
                var toLat = ""
                var toLong = ""
                toLat =  objStore.latitude ?? ""
                toLong =  objStore.longitude ?? ""
                DispatchQueue.main.async {
                    self.fetchRoute(to_lat: toLat, to_long: toLong, from_lat: prevObjStore.latitude ?? "", from_long: prevObjStore.longitude ?? "")
                }
            }
            
            let lastObj = arrSortedStores.last
            let lastObjStore = lastObj!["store"] as! CurrentOrderStores
            DispatchQueue.main.async {
                self.fetchRoute(to_lat: self.orderDetails!.deliveryLatitude ?? "", to_long: self.orderDetails!.deliveryLongitude ?? "", from_lat: lastObjStore.latitude ?? "", from_long: lastObjStore.longitude ?? "")
            }
            
            //ADD STORE MARKER
            DispatchQueue.main.async {
               let storeWindow = StoreNumberInfoWindow(nibName: "StoreNumberInfoWindow", bundle: nil)
                let point =  CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(objStore.latitude ?? "")! )!, longitude: CLLocationDegrees(exactly: Double(objStore.longitude ?? "")! )!)
                storeWindow.setValues(number: "\(i + 1)")
                let  m = GMSMarker(position: point)
                m.iconView = storeWindow.view
                m.infoWindowAnchor = CGPoint(x: 1, y: 1)
                m.isTappable = false
                self.mapView.selectedMarker = m
                m.map = self.mapView
            }
        }
        IHProgressHUD.dismiss()
    }
    //Calculate Distance Between two location
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> String {
        
        let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        
        let time = distanceInMeters / 400
        if time > 50 && time < 60
        {
            print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
        }
        else if time >= 60
        {
            print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
            //tmproutetime = "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
        }
        else
        {
            print("Minit : ",time.rounded(toPlaces: 0))
           //// tmproutetime = "\(Int(time.rounded(toPlaces: 0))) min"
        }
        
        
        let distanceInKM = distanceInMeters / 1000
        if distanceInMeters >= 1000
        {
            //tmproutedist = "\(distanceInKM.rounded(toPlaces: 2)) KM"
            return "\(distanceInKM.rounded(toPlaces: 2)) km"
        }
        else
        {
            //tmproutedist = "\(distanceInMeters.rounded(toPlaces: 2)) MTR"
            return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
        }
        return "\(distanceInKM)"
        
        
    }
}

//MARK:- GSM Location Delegate
extension DriverLocationVC : CLLocationManagerDelegate
{
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last

        //let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 5.0)
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0, bearing: 270, viewingAngle: 45)
        self.mapView?.animate(to: camera)

        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()

    }
    
    func moveToLocation(toLocation: CLLocationCoordinate2D?)
    {
        
    }
}
//MARK:- Google Map Delegate
extension DriverLocationVC : GMSMapViewDelegate {
 /*
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //self.locationManager.startUpdatingLocation()
            
                if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .authorizedAlways) {
                   var currentLoc = locationManager.location
                    if currentLoc == nil
                    {
                        currentLoc = locationManager.location
                        
                    }
                    let camera = GMSCameraPosition.camera(withLatitude: (currentLoc?.coordinate.latitude)!,
                                                          longitude: (currentLoc?.coordinate.longitude)!,
                                                          zoom:  15.0,
                                        bearing: 0,
                                        viewingAngle:  0)
                    mapView.camera = camera
                    self.mapView?.animate(to: camera)
                }
               
                
    }*/
}
