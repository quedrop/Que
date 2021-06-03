//
//  RestaurantsVC.swift
//  QueDrop
//
//  Created by C100-104 on 03/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMaps
import GooglePlaces
import IHProgressHUD
import CoreLocation
class RestaurantsVC: BaseViewController {

	@IBOutlet var btnShowList: UIButton!
	@IBOutlet var btnShowMap: UIButton!
	@IBOutlet var txtSearch: UITextField!
	@IBOutlet var btnCancelSearch: UIButton!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var btnBack: UIButton!
	@IBOutlet var topSwitchView: UIView!
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var lblStoreNotAvailable: UILabel!
	@IBOutlet var lblTitle: UILabel!
	
    //ENUMs
    enum textType {
          case storeName
          case storeAddress
          case storeDistance
        case openStatus
      }
    
    //Variables
    var staticCount = 0
    var isStoreOutOfRange = false
	var stores : [Store] = []
	var searchedStores : [Store] = []
    var arrStoredistance = [Int : Int]()
	var titleString = ""
	var searchText = ""
	var index = 0
	var currentMarkerId = ""
    var distInKm : Double = 0
	var currentShopImage = UIImage()
	var tmproutetime = ""
	var tmproutedist = ""
	var activeView = 0		//	0 - Store List	/	1 - Store on Mep
	// Map Variables
	var locationManager = CLLocationManager()
	var bounds = GMSCoordinateBounds()
	var infoWindow : CustomInfoView? = nil
	var routeInfoWindow : CustomRouteInfoView? = nil
	var tmp = 0
	var serviceId = 0
	var oldPolyline = GMSPolyline()
	var oldMarker = GMSMarker()
	var olddetailMarker = GMSMarker()
	var detailMarker = GMSMarker()
    var freshProducedCategoryId : Int = 0
    
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		self.txtSearch.delegate = self
        staticCount = Int(tableView.bounds.height / 120)
        self.getStores(searchText, serviceId: serviceId, freshProducedId: freshProducedCategoryId)
		self.locationManager.delegate = self
		self.txtSearch.setLeftPadding(30)
		self.txtSearch.setRightPadding(30)
		self.lblTitle.text = titleString
		self.activeView = 0
		tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		self.topSwitchView.layer.borderWidth = 1
        self.topSwitchView.layer.borderColor = UIColor.white.cgColor
        // Do any additional setup after loading the view.
    }
	override func viewDidAppear(_ animated: Bool) {
		isTabbarHidden(true)
		self.mapView.delegate = self
		self.mapView.isMyLocationEnabled = true
	}
	
	//MARK:- Action Methods
	@IBAction func actionBack(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionShowList(_ sender: UIButton) {
		self.btnShowList.isSelected = true
		//self.btnShowList.backgroundColor = GreenColor
		self.btnShowMap.isSelected = false
		//self.btnShowMap.backgroundColor = .white
		self.tableView.isHidden = false
		self.activeView = 0
		self.mapView.isHidden = true
	}
	@IBAction func actionShowMap(_ sender: UIButton) {
        if stores.count == 0
        {
            return
        }
        sender.isUserInteractionEnabled = false
		self.btnShowList.isSelected = false
		//self.btnShowList.backgroundColor = .white
		self.btnShowMap.isSelected = true
		//self.btnShowMap.backgroundColor = GreenColor
		currentMarkerId = ""
		self.refreshMap()
		self.tableView.isHidden = true
		self.mapView.isHidden = false
		self.activeView = 1
	}
	@IBAction func actionCancelSearch(_ sender: UIButton) {
		if txtSearch.text != "" && searchText != ""
		{
			searchText = ""
			getStores(searchText, serviceId: serviceId, freshProducedId: freshProducedCategoryId)
		}
	}
	
    //MARK:- functions
	
	func setServiceId(serviceId: Int, titleString : String)
	{
		self.serviceId = serviceId
		self.titleString = titleString
	}
	func refreshMap()
	{
		
		self.index = 0
		self.mapView.clear()
        if stores.count > 0 {
            self.pinAddToMap()
        }
		let latitude = defaultAddress?.latitude ?? ""
		let longitude = defaultAddress?.longitude ?? ""
		let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
		let  detailMarker = GMSMarker(position: pos)
		detailMarker.icon = setImageTintColor(image: UIImage(named:  "mark_home"), color: THEME_COLOR)// #imageLiteral(resourceName: "mark_home")
		
		detailMarker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
		detailMarker.isTappable = false
		detailMarker.map = self.mapView
	}
	
	func pinAddToMap() {
		//self.mapView.clear()
        if index < self.stores.count {
            let store = stores[index]
            let latitude = store.latitude ?? ""
            let longitude = store.longitude ?? ""
            let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
            var marker = GMSMarker()
            if currentMarkerId == "\(store.storeId ?? 0)"
            {
                marker = self.getMarker(title: store.storeName ?? "" , desc: store.storeAddress ?? "", image: #imageLiteral(resourceName: "pin_icon_blue"), position: pos)
            }
            else
            {
                marker = self.getMarker(title: store.storeName ?? "" , desc: store.storeAddress ?? "", image: #imageLiteral(resourceName: "pin_icon"), position: pos)
            }
             
            bounds = bounds.includingCoordinate(marker.position)
            marker.accessibilityHint = "\(store.storeId ?? 0)"
            marker.map = self.mapView
            if currentMarkerId == ""
            {
                let update = GMSCameraUpdate.fit(bounds)
                self.mapView?.animate(with: update)
            }
            print("Index : \(index) with Store count : \(self.stores.count)")
            if index < self.stores.count - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.index += 1
                    self.arrStoredistance[store.storeId ?? 0] = 0
                    self.pinAddToMap()
                })
            }
            else
            {
                self.btnShowMap.isUserInteractionEnabled = true
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
		if currentMarkerId == ""
		{
			marker.appearAnimation = .pop
		}
		else
		{
			marker.appearAnimation = .none
		}
		//marker.
        return marker
    }
	
	
	
}
//MARK:- TextField Delegate Methods
extension RestaurantsVC : UITextFieldDelegate{
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField.text?.count == 1 && string == ""
		{
				searchText = ""
			getStores(searchText, serviceId: serviceId, freshProducedId: freshProducedCategoryId)
			return true
		}
		searchText = "\(textField.text ?? "")\(string)"
		//IHProgressHUD.set(defaultMaskType: .none)
		getStores(searchText, serviceId: serviceId, freshProducedId: freshProducedCategoryId)
		//IHProgressHUD.set(defaultMaskType: .clear)
		return true
	}
	
}
//MARK:- TableView Delegate Methods
extension RestaurantsVC : UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		
		return stores.count == 0 ? Int(staticCount) : stores.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if stores.count == 0
		{
			if let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListShimmerTVC", for: indexPath) as? RestaurantListTVC
			{
				cell.selectionStyle = .none
				return cell
			}
			
		}
		else
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListTVC", for: indexPath) as? RestaurantListTVC
			cell?.selectionStyle = .none
			let currStoreObj = self.stores[indexPath.row]
			let name =  currStoreObj.storeName ?? ""
			let address = currStoreObj.storeAddress ?? ""
			let dist = distance(lat1: Double(currStoreObj.latitude ?? "") ?? 0, lon1: Double(currStoreObj.longitude ?? "") ?? 0, lat2: Double(defaultAddress?.latitude ?? "") ?? 0, lon2: Double(defaultAddress?.longitude ?? "") ?? 0)
            var combination = NSMutableAttributedString()
            
            combination.append(getFormatedString(text: name, for: .storeName))
            combination.append(getFormatedString(text: address, for: .storeAddress))
            combination.append(getFormatedString(text: dist, for: .storeDistance))
            
            /////
           
            var isOpen = false
            let index = self.matchTiming(index: indexPath.row)
            isOpen = index > -1
           print("\(currStoreObj.storeName) is Closed : ",isOpen )
            ////
            if !isOpen{
                combination.append(getFormatedString(text: "Closed", for: .openStatus))
            }
            cell?.lblTitle.attributedText = combination
			let imageURL = self.stores[indexPath.row].storeLogo
			cell?.imageRestaurnt?.sd_setImage(with: URL(string: ("\(URL_STORE_LOGO_IMAGES)\(imageURL ?? "")")),placeholderImage: QUE_AVTAR/* #imageLiteral(resourceName: "order")*/, completed:{ (image, _, _, _) in
                if !isOpen
                {
                    cell?.addGrayLayer()
                }
            } )
			return cell ?? UITableViewCell()
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
        return UITableView.automaticDimension
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if stores.count != 0
		{
			let currStoreObj = self.stores[indexPath.row]
			if self.stores[indexPath.row].canProvideService ?? 0 == 0
			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
				nextViewController.setStoreId(storeId: currStoreObj.storeId ?? 0)
				self.navigationController?.pushViewController(nextViewController, animated: true)
			}
			else
			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
				nextViewController.setStoreId(storeId: currStoreObj.storeId ?? 0)
				self.navigationController?.pushViewController(nextViewController, animated: true)
			}
		}
	}
    func getFormatedString( text : String , for type : textType) -> NSMutableAttributedString
    {
        switch type{
        case .storeName :
            let attributedText = NSMutableAttributedString(string: "\(text)\n")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_BOLD, size: 16.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attributedText.length))
            return attributedText
        case .storeAddress:
            let attributedText = NSMutableAttributedString(string: "\(text)\n")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: 14.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, attributedText.length))
            return attributedText
        case .storeDistance:
            let attributedText = NSMutableAttributedString(string: "\(text)")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_LIGHT, size: 12.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attributedText.length))
            return attributedText
        case .openStatus:
            let attributedText = NSMutableAttributedString(string: " - \(text)")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: 12.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSMakeRange(0, attributedText.length))
            return attributedText
        }
    }

    func matchTiming(index : Int) -> Int
    {
        var dayOfWeek = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
                   if dayOfWeek == 1
                   {
                       dayOfWeek = 6
                   }
                   else
                   {
                       dayOfWeek = dayOfWeek - 2
                   }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"
        let dayInWeek = dateFormatter.string(from: now)
        var curr_index = -1
        for schedule in self.stores[index].schedule ?? []
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
        //let timing = self.stores[index].schedule?[dayOfWeek]
        //print( " \(timing?.openingTime?.dropLast(3) ?? "00:00") - \(timing?.closingTime?.dropLast(3) ?? "00:00")(today)")
        
        
        return -1
    }
}


//MARK:- GMS Location Delegate
extension RestaurantsVC : CLLocationManagerDelegate
{
	private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		//let location = locations.last
		let latitude = defaultAddress?.latitude ?? ""
		let longitude = defaultAddress?.longitude ?? ""
		let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!,
		longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!,
		zoom: 14.0) //Set default lat and long
		 
		self.mapView?.animate(to: camera)

		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()

	}
	
	func moveToLocation(toLocation: CLLocationCoordinate2D?)
	{
		
	}
	
}
//MARK:- Google Map Delegate
extension RestaurantsVC : GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
		if self.infoWindow !=  nil
		{
			self.infoWindow!.view.removeFromSuperview()
		}
		if self.routeInfoWindow != nil
		{
			self.routeInfoWindow?.view.removeFromSuperview()
			self.routeInfoWindow = nil
		}
		let currStoreObj = self.getTappedshopObj()
		_ = self.distance(lat1: Double(currStoreObj.latitude ?? "") ?? 0, lon1: Double(currStoreObj.longitude ?? "") ?? 0, lat2: Double(defaultAddress?.latitude ?? "") ?? 0, lon2: Double(defaultAddress?.longitude ?? "") ?? 0)
			
		self.oldPolyline.map = nil
		self.detailMarker.iconView = nil
		self.detailMarker.icon = UIImage()
		self.detailMarker.map = mapView
		self.olddetailMarker.map = nil
		
		self.infoWindow = CustomInfoView(nibName: "CustomInfoView", bundle: nil)
		self.infoWindow?.setDetail(name: marker.title ?? "", address: marker.snippet ?? "", distance: self.tmproutedist, shopId: marker.accessibilityHint ?? "", logoURL: currStoreObj.storeLogo ?? "", time: tmproutetime )
		
		self.currentMarkerId = ""
		return infoWindow?.view
	}
	func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
		print("tapped Store Id : ",marker.accessibilityHint)
		let shopObj = getTappedshopObj()
		if shopObj.canProvideService ?? 0 == 0
		{
			let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
			nextViewController.setStoreId(storeId: Int(marker.accessibilityHint ?? "0") ?? 0 )
			self.navigationController?.pushViewController(nextViewController, animated: true)
		}
		else
		{
			let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
			nextViewController.setStoreId(storeId: Int(marker.accessibilityHint ?? "0") ?? 0)
			self.navigationController?.pushViewController(nextViewController, animated: true)
		}
	}
	func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		if self.infoWindow !=  nil
		{
			self.infoWindow!.view.removeFromSuperview()
		}
		DispatchQueue.main.async {
			if self.routeInfoWindow != nil
			{
				self.routeInfoWindow?.view.removeFromSuperview()
				self.routeInfoWindow = nil
			}
			
		}
		if true //currentMarkerId != marker.accessibilityHint ?? ""
		{
			mapView.selectedMarker = nil
			currentMarkerId = marker.accessibilityHint ?? ""
			
				oldMarker.icon = #imageLiteral(resourceName: "pin_icon")
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
					self.oldMarker.map = mapView
						   })
            let currStoreObj = self.getTappedshopObj()
            _ = self.distance(lat1: Double(currStoreObj.latitude ?? "") ?? 0, lon1: Double(currStoreObj.longitude ?? "") ?? 0, lat2: Double(defaultAddress?.latitude ?? "") ?? 0, lon2: Double(defaultAddress?.longitude ?? "") ?? 0,isTest: true)
            
			marker.icon = #imageLiteral(resourceName: "pin_icon_blue")
			marker.map = mapView
			
			if distInKm > 20
            {
                ShowToast(message: "Store is out of range")
            }
            else
            {
                IHProgressHUD.show()
                fetchRoute(to_lat: marker.position.latitude.description, to_long: marker.position.longitude.description)
            }
			oldMarker = marker
			return false
		}
	}
	func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
		if oldMarker.userData != nil
		{
			if infoWindow !=  nil
			{
				let location = CLLocationCoordinate2D(latitude: oldMarker.position.latitude , longitude: oldMarker.position.longitude)
				infoWindow!.view.center = mapView.projection.point(for: location)
			}
		}
	}
	func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
			if self.infoWindow !=  nil
			{
				self.infoWindow!.view.removeFromSuperview()
				
			}
			self.oldMarker.icon = #imageLiteral(resourceName: "pin_icon")
			self.oldMarker.map = self.mapView
			self.currentMarkerId = ""
			
			mapView.selectedMarker = nil
		})
	}
	func fetchRoute(to_lat : String , to_long : String) {

		let session = URLSession.shared

		let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(defaultAddress?.latitude ?? ""),\(defaultAddress?.longitude ?? "")&destination=\(to_lat),\(to_long)&sensor=false&mode=driving&key=\(GoogleMapKey)")!

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
	
	//Draw line on map
	func drawPath(from polyStr: String){
		
		/*let centerPoint = (polyline.path?.coordinate(at: (polyline.path?.count() ?? 0) / 2))!   //block for small deails view in center of rout path
		//let sView = UIView()
		let currStoreObj = getTappedshopObj()
		_ = distance(lat1: Double(currStoreObj.latitude ?? "") ?? 0, lon1: Double(currStoreObj.longitude ?? "") ?? 0, lat2: Double(defaultAddress?.latitude ?? "") ?? 0, lon2: Double(defaultAddress?.longitude ?? "") ?? 0)
		DispatchQueue.main.async {
			if self.routeInfoWindow != nil
			{
					self.routeInfoWindow = nil
			}
			self.routeInfoWindow = CustomRouteInfoView(nibName: "CustomRouteInfoView", bundle: nil)
			
			
			self.routeInfoWindow?.setValues(distance: self.tmproutedist, time: self.tmproutetime)
			let  detailMarker = GMSMarker(position: centerPoint)
			detailMarker.iconView = self.routeInfoWindow?.view
			detailMarker.infoWindowAnchor = CGPoint(x: 1, y: 1)
			detailMarker.isTappable = false
			detailMarker.accessibilityHint = "Hint"
			self.mapView.selectedMarker = detailMarker
			detailMarker.map = self.mapView
		}
		
		*/
//		sView.frame = detailMarker.iconView!.frame
//		sView.backgroundColor = .black
//		mapView.addSubview(sView)
		//let frame = self.view.convert(detailMarker.iconView?.frame.origin ?? CGPoint(x: 0, y: 0), from: self.mapView)
		//olddetailMarker = detailMarker
		
		DispatchQueue.main.async
		{
            if self.tmp != 0
            {
                self.oldPolyline.map = nil
                self.olddetailMarker.map = nil
                self.detailMarker.iconView = nil
                self.detailMarker.icon = UIImage()
                self.detailMarker.map = self.mapView
                if self.routeInfoWindow != nil
                {
                    DispatchQueue.main.async {
                        self.routeInfoWindow?.view.removeFromSuperview()
                    }
                }
            }
            self.tmp = 1
            let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.map = self.mapView // Google MapView
            polyline.strokeColor = strokeColor
            IHProgressHUD.dismiss()
            self.oldPolyline = polyline
		 if self.mapView != nil
		 {
		  let bounds = GMSCoordinateBounds(path: path!)
		  self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
		 }
		}
	}
	func getTappedshopObj() -> Store{
		var tmpstore = stores[0]
		for store in self.stores
		{
			if store.storeId == Int(currentMarkerId) ?? 0
			{
				tmpstore = store
				return tmpstore
			}
		}
		return tmpstore
	}
	
	//Calculate Distance Between two location
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, isTest:Bool = false) -> String {
		
		let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
		let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
		
		let time = distanceInMeters / 400
		if isTest
        {
            
            let distanceInKM = distanceInMeters / 1000
            if distanceInMeters >= 1000
            {
                distInKm = distanceInKM.rounded(toPlaces: 2)
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
                
            }
            else
            {
                distInKm = 0
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
        }
        else
        {
            if time > 50 && time < 60
            {
                print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
            }
            else if time >= 60
            {
                print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
                tmproutetime = "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
            }
            else
            {
                print("Minit : ",time.rounded(toPlaces: 0))
                tmproutetime = "\(Int(time.rounded(toPlaces: 0))) min"
            }
            
            
            let distanceInKM = distanceInMeters / 1000
            if distanceInMeters >= 1000
            {
                tmproutedist = "\(distanceInKM.rounded(toPlaces: 2)) KM"
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
                
            }
            else
            {
                tmproutedist = "\(distanceInMeters.rounded(toPlaces: 2)) MTR"
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
            return "\(distanceInKM)"
        }
		return ""
    }
}

