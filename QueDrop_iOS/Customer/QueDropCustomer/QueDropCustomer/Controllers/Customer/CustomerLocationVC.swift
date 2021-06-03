//
//  CustomerLocationVC.swift
//  QueDrop
//
//  Created by C100-104 on 01/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IHProgressHUD
import TTTAttributedLabel

//Delegate To Update Current Location
protocol CustomerLocationDelegate {
	func updateLocationValues()
}
class CustomerLocationVC: BaseViewController {
    @IBOutlet var imgNavigation: UIImageView!
	@IBOutlet var topview: UIView!
	@IBOutlet var btnBack: UIButton!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var bottomView: UIView!
	@IBOutlet var bottomVireTitle: UILabel!
	@IBOutlet var tableViewBottom: UITableView! // tag value - 0
	@IBOutlet var bottomButtonView: UIView!
	@IBOutlet var bottomButtom: UIButton!
	@IBOutlet var btnLeftImage: UIImageView!
	@IBOutlet var btnRightImage: UIImageView!
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var parentFillLayer: UIView!
	@IBOutlet var childFillLayer: UIView!
	@IBOutlet var viewNewAddress: UIView!
	@IBOutlet var tableViewNewAddress: UITableView! // tag value - 5
	@IBOutlet var viewSearch: UIView!
	@IBOutlet var textFieldLocationName: UITextField!
	@IBOutlet var btncancelSearch: UIButton!
	
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet var constraintBottomViewHeight: NSLayoutConstraint!
	@IBOutlet var lblButtonTitle: UILabel!
	@IBOutlet var btnSaveAddress: UIButton!
    @IBOutlet weak var lblSupplierLogin: TTTAttributedLabel!
    @IBOutlet weak var btnMyLocation: UIButton!
    @IBOutlet weak var btnSearchLocation: UIButton!
    @IBOutlet weak var lblSupplierLoginHeight: NSLayoutConstraint!
    //Location
	let geocoder = CLGeocoder()
	var delegate : CustomerLocationDelegate?
	//address
	var addressTitle = ""
	var address = ""
	var unitNumber = ""
	var addressType = 1
	var currentAddress = ""
	var currentAddressObj : Address = Address(object: (Any).self)
	var blackPopView = UIView()
	var selectIndex = 0
	var isSearchFromHome = false
    
	// Map Variables
	var locationManager = CLLocationManager()
	var currentLocation: CLLocation?
	var placesClient: GMSPlacesClient!
	var zoomLevel: Float = 18.0
	var marker = GMSMarker()
	
	var indexPaths : [IndexPath]? = []
	//Popover Var
	fileprivate var popover: Popover!
	fileprivate var text = ["Edit","Delete"]
	var selectedAddressId = 0
	var `isMapOpen` = false
	
	var isDeleteViewiWillOpen = false
	var deleteCustomView : DeleteCustomView?
	var isAddAddressOpen = false
	var isEditAddressOpen = false
	var currLocationType : String  = ""
	
    let optionalLatitude = -33.8642
   let optionalLongitude = 151.2166
	
	//Add address ENUM
	enum addAddress_tableField : Int{
		case placeAddress = 0
		case unitNumber
		case placeType
		case placeLabel
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        if !isGuest 
        {
            self.lblSupplierLoginHeight.constant = 0
        }
        else
        {
            self.lblSupplierLoginHeight.constant = 20
            let strAgreement = "Not a customer ? Login in as Supplier" as NSString
            lblSupplierLogin.text = strAgreement
            lblSupplierLogin.numberOfLines = 1;

            let fullAttributedString = NSAttributedString(string:strAgreement as String, attributes: [
              NSAttributedString.Key.foregroundColor: UIColor.lightGray,
              NSAttributedString.Key.font : UIFont.init(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0)) as Any
            ])
            lblSupplierLogin.textAlignment = .center
            lblSupplierLogin.attributedText = fullAttributedString;

            let rangeTC = strAgreement.range(of: "Login in as Supplier")


            let ppLinkAttributes: [String: Any] = [
              NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
              NSAttributedString.Key.underlineStyle.rawValue: false,
              NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_BOLD, size: calculateFontForWidth(size: 14.0)) as Any
            ]
            let ppActiveLinkAttributes: [String: Any] = [
              NSAttributedString.Key.foregroundColor.rawValue: LINK_COLOR.cgColor,
              NSAttributedString.Key.underlineStyle.rawValue: false,
              NSAttributedString.Key.font.rawValue : UIFont.init(name: fFONT_BOLD, size: calculateFontForWidth(size: 14.0)) as Any
            ]

            lblSupplierLogin.activeLinkAttributes = ppActiveLinkAttributes
            lblSupplierLogin.linkAttributes = ppLinkAttributes

            let urlTC = URL(string: "action://LI")!

            lblSupplierLogin.addLink(to: urlTC, with: rangeTC)


            lblSupplierLogin.textColor = UIColor.black
            lblSupplierLogin.delegate = self
        }
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		self.tableViewBottom.dataSource = self
		self.tableViewBottom.delegate = self
		self.tableViewNewAddress.dataSource = self
		self.tableViewNewAddress.delegate = self
		self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        
		viewSearch.layer.masksToBounds = false
		viewSearch.layer.shadowColor = UIColor.gray.cgColor
		viewSearch.layer.shadowOffset = CGSize(width: 0, height: 1)
		viewSearch.layer.shadowRadius = 3
		viewSearch.layer.shadowOpacity = 0.7
		viewSearch.clipsToBounds = false
		
		placesClient = GMSPlacesClient.shared()
		self.locationManager.delegate = self
		self.viewNewAddress.isHidden = true
		self.viewSearch.isHidden = true
        self.btnCurrentLocation.isHidden = true
		self.btnSaveAddress.isHidden = true
		if Addresses.count == 0
		{
			self.constraintBottomViewHeight.constant = 180
		}
		else
		{
			self.constraintBottomViewHeight.constant = (screenHeight > 680) ? 250 : 200
		}
        makeCircular(view: btnSearchLocation)
        btnSearchLocation.addShadow(location: .bottom, color: .gray, opacity: 0.7, radius: btnSearchLocation.frame.height/2.0)
        btnMyLocation.addShadow(location: .bottom, color: .gray, opacity: 0.7, radius: btnMyLocation.frame.height/2.0)
//		self.searchBar.searchTextField.textColor = .black
//		self.searchBar.tintColor = .white
//		self.searchBar.barTintColor = .white
//		self.searchBar.backgroundColor = .white
//		self.searchBar.setImage(UIImage(named: "search_blue"), for: .search, state: .normal)
//		self.parentFillLayer.backgroundColor = .clear
//		self.childFillLayer.backgroundColor = .clear
		setUpMap()
        
        //bottomButtom.gradientBackground(ColorSet: GRADIENT_ARRAY, direction: .topToBottom)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		//let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 15.0)
		saveUserTypeUserDefaults(type: .Customer)
		
	}

    @IBAction func actionCurrentLocation(_ sender: UIButton) {
        if LOCATION_AVAILABLE
        {
            actionGetCurrentLoaction(sender)
            self.textFieldLocationName.text = ""
            updateDetailsAsNewAddress(locationName: "", formattedAddress: "")
        }
        else
        {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                return
            case .denied, .restricted:
                let alert = UIAlertController(title: "Location Services are disabled", message: "We need your location to find near by stores for you. Please enable location services from settings.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Go to settings", style: .default, handler: {_ in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                let closeAction = UIAlertAction(title: "Close", style: .destructive, handler: nil)
                alert.addAction(okAction)
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }
    }
    @IBAction func actionMyLocationClicked(_ sender: UIButton) {
        if LOCATION_AVAILABLE
        {
            actionGetCurrentLoaction(sender)
            self.textFieldLocationName.text = ""
            updateDetailsAsNewAddress(locationName: "", formattedAddress: "")
        }
        else
        {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                return
            case .denied, .restricted:
                let alert = UIAlertController(title: "Location Services are disabled", message: "We need your location to find near by stores for you. Please enable location services from settings.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Go to settings", style: .default, handler: {_ in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                let closeAction = UIAlertAction(title: "Close", style: .destructive, handler: nil)
                alert.addAction(okAction)
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }
    }
    
    @IBAction func actionSearchLocationClicked(_ sender: UIButton) {
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
          // Specify the place data types to return.
          let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
              UInt(GMSPlaceField.placeID.rawValue) |
              UInt(GMSPlaceField.coordinate.rawValue) |
              UInt(GMSPlaceField.formattedAddress.rawValue) )!
          acController.placeFields = fields

          // Specify a filter.
          let filter = GMSAutocompleteFilter()
          filter.type = .address
          acController.autocompleteFilter = filter
        
        isSearchFromHome = true
          present(acController, animated: true, completion: nil)
    }
    @IBAction func actionBottomButton(_ sender: UIButton) {
		if Addresses.count == 4
		{
            ShowToast(message: "Your address limit exceeded.\n Please remove any address to add new one.")
			return
		}
		
		UIView.animate(withDuration: 1.0 , animations: {
			self.mapView.isUserInteractionEnabled = true
			self.isAddAddressOpen = true
			self.isDeleteViewiWillOpen = false
			self.viewNewAddress.isHidden = false
			self.viewSearch.isHidden = false
            self.btnCurrentLocation.isHidden = false
			self.lblTitle.text = "Add Address"
            self.topview.isHidden = false
            self.imgNavigation.isHidden = false
			self.btnSaveAddress.isHidden = false
            
            self.btnMyLocation.isHidden = true
            self.btnSearchLocation.isHidden = true
            ShowToast(message: "Hold the pin down to move it for location change")
		})
	}
	@IBAction func actionBack(_ sender: UIButton) {
		isMapOpen = false
        self.btnSaveAddress.setTitle("Save Address", for: .normal)
        if self.isAddAddressOpen || isEditAddressOpen
		{
			self.mapView.isUserInteractionEnabled = true//false
			self.isDeleteViewiWillOpen = true
			self.viewNewAddress.isHidden = true
			self.viewSearch.isHidden = true
            self.btnCurrentLocation.isHidden = true
			self.topview.isHidden = true
            self.imgNavigation.isHidden = true
			self.bottomView.isHidden = false
			self.btnSaveAddress.isHidden = true
			isAddAddressOpen = false
			isEditAddressOpen = false
            
            self.btnMyLocation.isHidden = false
            self.btnSearchLocation.isHidden = false
		}
	}
	
	@IBAction func actionSaveAddress(_ sender: UIButton) {
        self.btnMyLocation.isHidden = false
        self.btnSearchLocation.isHidden = false
		if isMapOpen
        {
                //self.isAddAddressOpen = true
            self.isMapOpen = false
            sender.setTitle("Save Address", for: .normal)
                self.isDeleteViewiWillOpen = false
                self.viewNewAddress.isHidden = false
                self.viewSearch.isHidden = false
            self.btnCurrentLocation.isHidden = false
                self.topview.isHidden = false
            self.imgNavigation.isHidden = false
                self.btnSaveAddress.isHidden = false
            
        }
        else if self.isEditAddressOpen
		{
			let cellAddressName = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeLabel.rawValue, section: 0)) as! NameTVCell
			addressTitle = cellAddressName.textField.text ?? ""
			
			let cellUnitNumber = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.unitNumber.rawValue, section: 0)) as! NameTVCell
			unitNumber = cellUnitNumber.textField.text ?? ""
			
			let cellAddressInfo = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeAddress .rawValue, section: 0)) as! InfoTVCell
			address = cellAddressInfo.textView.text ?? ""
			
			
			
			self.EditAddress(name: addressTitle,
							 unitNum: unitNumber,
							 lat: currentLocation?.coordinate.latitude.description ?? "",
							 lon: currentLocation?.coordinate.longitude.description ?? "",
							 info: "",
							 type: addressType,
							 address: address)
		}
		else
		{
			
			let cellAddressName = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeLabel.rawValue, section: 0)) as! NameTVCell
			addressTitle = cellAddressName.textField.text ?? ""
			
			let cellUnitNumber = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.unitNumber.rawValue, section: 0)) as! NameTVCell
			unitNumber = cellUnitNumber.textField.text ?? ""
			
			let cellAddressInfo = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeAddress .rawValue, section: 0)) as! InfoTVCell
			address = cellAddressInfo.textView.text ?? ""
			
			if addressTitle == "" || address == ""
			{
				ShowToast(message: "Please make sure you input a valid address without unit number")
				return
			}
			else
			{
				self.saveAddress(name: addressTitle,
								 unitNum: unitNumber,
								 lat: currentLocation?.coordinate.latitude.description ?? "",
								 lon: currentLocation?.coordinate.longitude.description ?? "",
								 info: "",
								 type: addressType,
								 address: address)
			}
		}
	}
	@IBAction func actionClearLocation(_ sender: UIButton) {
		actionGetCurrentLoaction(sender)
		self.textFieldLocationName.text = ""
		updateDetailsAsNewAddress(locationName: "", formattedAddress: "")
	}
	@IBAction func textFieldTapped(_ sender: Any) {
	  textFieldLocationName.resignFirstResponder()
	  let acController = GMSAutocompleteViewController()
	  acController.delegate = self
		// Specify the place data types to return.
		let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
			UInt(GMSPlaceField.placeID.rawValue) |
			UInt(GMSPlaceField.coordinate.rawValue) |
			UInt(GMSPlaceField.formattedAddress.rawValue) )!
		acController.placeFields = fields

		// Specify a filter.
		let filter = GMSAutocompleteFilter()
		filter.type = .address
		acController.autocompleteFilter = filter
        
        isSearchFromHome = false
		present(acController, animated: true, completion: nil)
	}
	
	//MARK:- Functions
	func setUpMap()
	{
       
		let camera = GMSCameraPosition.camera(withLatitude: optionalLatitude,
							longitude: optionalLongitude,
							zoom: zoomLevel)
		mapView.camera = camera
		marker.icon = #imageLiteral(resourceName: "store_location") //#imageLiteral(resourceName: "location_indicator")
		marker.position = CLLocationCoordinate2D(latitude: optionalLatitude, longitude: optionalLongitude)
		marker.isDraggable = true
		marker.infoWindowAnchor = CGPoint(x: 2, y: 2)
		mapView.delegate = self
        
		mapView.isUserInteractionEnabled = true
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		locationManager.requestWhenInUseAuthorization()
		IHProgressHUD.show()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
			self.checkRegistered()
		})
	}
	
	func checkRegistered()
	{
		actionGetCurrentLoaction(btnBack)
		
		
	}
	func getCurrentLocationDetails()
    {
        if currentLocation == nil || !LOCATION_AVAILABLE
        {
            let camera = GMSCameraPosition.camera(withLatitude: optionalLatitude, longitude: optionalLongitude, zoom: zoomLevel)
            mapView.camera = camera
            
            //marker.icon = #imageLiteral(resourceName: "location_indicator")
            marker.position = CLLocationCoordinate2D(latitude: optionalLatitude, longitude: optionalLongitude)
            self.marker.map = self.mapView
            marker.appearAnimation = .pop

            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                return
            case .denied, .restricted:
                let alert = UIAlertController(title: "Location Services are disabled", message: "We need your location to find near by stores for you. Please enable location services from settings.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Go to settings", style: .default, handler: {_ in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
                let closeAction = UIAlertAction(title: "Close", style: .destructive, handler: nil)
                alert.addAction(okAction)
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
            
            if USER_ID == 0
            {
                self.guestRegister()
            }
            else if Addresses.count == 0
            {
                self.getAddresses()
            }
            DispatchQueue.main.async {
                IHProgressHUD.dismiss()
                if Addresses.count == 0
                {
                    self.constraintBottomViewHeight.constant = 180
                }
                else
                {
                    self.constraintBottomViewHeight.constant = (screenHeight > 680) ? 300 : 250
                }
                self.tableViewBottom.reloadData()
            }
            
            
        }else{
            geocoder.cancelGeocode()
            geocoder.reverseGeocodeLocation(currentLocation!) { response, error in
                if let error = error as NSError?, error.code != 10 {
                    // ignore cancelGeocode errors
                    // show error and remove annotation
//                    let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true) {
                        //self.mapView.removeAnnotation(annotation)
                    
                    //}
                    ShowToast(message: "Something Went Wrong with the network. Please check your internet connectivity")
                     IHProgressHUD.dismiss()
                    
                } else if let placemark = response?.first {
                    
                    let name = placemark.name
                    print("Location name ::",name)
                    print("Location Placemark ::",placemark)
                    self.currentAddressObj.address = placemark.address()
                    self.currentAddressObj.addressId = 0
                    self.currentAddressObj.addressTitle = name
                    self.currentAddressObj.addressType = "Home"
                    self.currentAddressObj.latitude = self.currentLocation?.coordinate.latitude.description ?? ""
                    self.currentAddressObj.longitude = self.currentLocation?.coordinate.longitude.description ?? ""
                    self.address = "\(placemark.address())\(placemark.postalCode ?? "")"
                    if self.isAddAddressOpen || self.isEditAddressOpen
                    {
                        let formattedAddress = "\(placemark.address())\(placemark.postalCode ?? "")"
                        if self.isEditAddressOpen
                        {
                            self.updateDetailsAsEditAddress(name: name ?? "", address: formattedAddress)
                            //NewAddress(locationName: name ?? "", formattedAddress: formattedAddress)
                        }
                        else
                        {
                            self.updateDetailsAsNewAddress(locationName: name ?? "", formattedAddress: formattedAddress)
                        }
                    }
                    else
                    {
                        defaultAddress = self.currentAddressObj
                        self.updateDetailsAsCurrent(placemark: placemark)
                        self.updateDetailsAsNewAddress(locationName: name ?? "", formattedAddress: placemark.address())
                    }
                    
                    if USER_ID == 0
                    {
                        self.guestRegister()
                    }
                    else if Addresses.count == 0
                    {
                        self.getAddresses()
                    }
                    DispatchQueue.main.async {
                        IHProgressHUD.dismiss()
                        if Addresses.count == 0
                        {
                            self.constraintBottomViewHeight.constant = 180
                        }
                        else
                        {
                            self.constraintBottomViewHeight.constant = (screenHeight > 680) ? 300 : 250
                        }
                        self.tableViewBottom.reloadData()
                    }
                    //self.location = Location(name: name, location: location, placemark: placemark)
                }
            }
        }
//        else
//        {
//            
//        }
        
    }
	func updateDetailsAsCurrent(placemark : CLPlacemark)
	{
		if let cellCurrentLocation = self.tableViewBottom.cellForRow(at: IndexPath(row: 0, section: 0)) as? LocationTVCell
		{
			cellCurrentLocation.lblContent.text = "\(placemark.name ?? ""), \(placemark.address())\(placemark.postalCode ?? "")"
		}
		//currentAddress = "\(placemark.name ?? ""), \(placemark.address()), \(placemark.postalCode ?? "")"
        currentAddress = "\(placemark.address()), \(placemark.postalCode ?? "")"
		//self.textFieldLocationName.text = locationName
//		self.isAddAddressOpen = true
//		self.isDeleteViewiWillOpen = false
//		self.viewNewAddress.isHidden = false
//		self.viewSearch.isHidden = false
//		self.topview.isHidden = false
//		self.btnSaveAddress.isHidden = false
	}
	var currAddressType = ""
	func updateDetailsAsEditAddress(name : String , address : String)
	{
		self.mapView.isUserInteractionEnabled = true
        if !isMapOpen
        {
            self.isEditAddressOpen = true
            self.isDeleteViewiWillOpen = false
            self.viewNewAddress.isHidden = false
            self.viewSearch.isHidden = false
            self.btnCurrentLocation.isHidden = false
            self.lblTitle.text = "Edit Address"
            self.topview.isHidden = false
            self.imgNavigation.isHidden = false
            self.btnSaveAddress.isHidden = false
        }
		var locationName = ""
		var formattedAddress = ""
		var addressType = ""
		var unitNumber = ""
		if name != ""
		{
			locationName = name
            var add = "\(locationName),\(address)"
            var arAddr = add.split(separator: ",")
            arAddr = arAddr.removingDuplicates()
            add = arAddr.joined(separator: ",")
			formattedAddress = add
			unitNumber = self.unitNumber
            addressType = currAddressType
		}
		else
		{
			for address in Addresses
			{
				if selectedAddressId == address.addressId ?? 0
				{
					locationName = address.addressTitle ?? ""
					formattedAddress = "\(locationName) \(address.address ?? "")"
					unitNumber = address.unitNumber ?? ""
					addressType = address.addressType ?? ""
                    currAddressType = addressType
				}
			}
		}
		let cellAddressName = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeLabel.rawValue, section: 0)) as! NameTVCell
		cellAddressName.textField.text = locationName
        cellAddressName.btnClearText.isHidden =  locationName.isEmpty
		let cellUnitNumber = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.unitNumber.rawValue, section: 0)) as! NameTVCell
		cellUnitNumber.textField.text = unitNumber
		cellUnitNumber.btnClearText.isHidden =  locationName.isEmpty
		let cellAddressIcon = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeType.rawValue, section: 0)) as! AddressIconTVCell
		if addressType.lowercased() ==  "home"
		{
			cellAddressIcon.btnHome.isSelected = true
            cellAddressIcon.btnOffice.isSelected = false
            cellAddressIcon.btnBeach.isSelected = false
            cellAddressIcon.btnLocation.isSelected = false
		}
		else if addressType.lowercased() ==  "work"
		{
			cellAddressIcon.btnHome.isSelected = false
            cellAddressIcon.btnOffice.isSelected = true
            cellAddressIcon.btnBeach.isSelected = false
            cellAddressIcon.btnLocation.isSelected = false
		}
		else if addressType.lowercased() ==  "hotel"
		{
			cellAddressIcon.btnHome.isSelected = false
            cellAddressIcon.btnOffice.isSelected = false
            cellAddressIcon.btnBeach.isSelected = true
            cellAddressIcon.btnLocation.isSelected = false
		}
		else
		{
			cellAddressIcon.btnHome.isSelected = false
            cellAddressIcon.btnOffice.isSelected = false
            cellAddressIcon.btnBeach.isSelected = false
            cellAddressIcon.btnLocation.isSelected = true
		}
		let cellAddressInfo = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeAddress.rawValue, section: 0)) as! InfoTVCell
		cellAddressInfo.textView.text = formattedAddress
        cellAddressInfo.btnClear.isHidden = formattedAddress.isEmpty
               
		self.textFieldLocationName.text = locationName
		if !isMapOpen && isAddAddressOpen
		{
			//self.isAddAddressOpen = true
			self.isDeleteViewiWillOpen = false
			self.viewNewAddress.isHidden = false
			self.viewSearch.isHidden = false
            self.btnCurrentLocation.isHidden = false
			self.topview.isHidden = false
            self.imgNavigation.isHidden = false
			self.btnSaveAddress.isHidden = false
		}
	}
	
}
extension CustomerLocationVC : TTTAttributedLabelDelegate{
    
    //MARK: - TTTAttributedLabel DELEGATE METHOD
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //let vc = CommonWebViewVC.init(nibName: "CommonWebViewVC", bundle: nil)
        if url.absoluteString == "action://LI" {
            //vc.isForTerms = true
            print("Show Login")
            saveUserTypeUserDefaults(type: .Supplier)
            if isGuest
            {
                
                if isMapPresented {
                    self.dismiss(animated: true, completion: {
                        isMapPresented = false
                        self.delegate?.updateLocationValues()
                        APP_DELEGATE.navigateToSupplierLogin = true
                    })
                } else {
                    if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        LoginView.setupForGuest()
                        let transition:CATransition = CATransition()
                        transition.duration = 0.5
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.push
                        transition.subtype = CATransitionSubtype.fromTop
                        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
                        self.navigationController?.pushViewController(LoginView, animated: false)
                        //self.navigationController?.pushViewController(LoginView, animated: true)
                    }
                }
            }
            else
            {
                self.navigateToHome(from: .login)
            }
        }
        
    }
}
//MARK:- Google Map Delegate
extension CustomerLocationVC : GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
		print("marker dragged to location: ", marker.position.latitude, marker.position.longitude)
		
		//let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 15.0)
		let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: zoomLevel)
		//mapView.camera = camera
		marker.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		self.currentLocation = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
		self.getCurrentLocationDetails()
	}
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if self.isAddAddressOpen || isEditAddressOpen
        {
            self.isMapOpen = true
            self.isDeleteViewiWillOpen = false
            self.bottomView.isHidden = true
            self.btnSaveAddress.setTitle("Confirm", for: .normal)
            self.viewNewAddress.isHidden = true
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
         if self.isAddAddressOpen || isEditAddressOpen
               {
                   self.isMapOpen = true
                   self.isDeleteViewiWillOpen = false
                   self.bottomView.isHidden = true
                   self.btnSaveAddress.setTitle("Confirm", for: .normal)
                   self.viewNewAddress.isHidden = true
               }
    }
	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		if self.isAddAddressOpen || isEditAddressOpen
		{
            self.isMapOpen = true
			self.isDeleteViewiWillOpen = false
			self.bottomView.isHidden = true
            self.btnSaveAddress.setTitle("Confirm", for: .normal)
			self.viewNewAddress.isHidden = true
		}
	}
	
}


//MARK:- Google Places
extension CustomerLocationVC: GMSAutocompleteViewControllerDelegate {
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
   /* print("Place name: ",place.name)
	print("Place formated address: ",place.formattedAddress)
    print("Place ID: \(place.placeID)")
    print("Place attributions: \(place.attributions)")
	print("Place Coordinate: \(place.coordinate)")*/
	
    
	//let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
	let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: zoomLevel)
	mapView.camera = camera
	viewController.dismiss(animated: true, completion: nil)
	marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
	self.currentLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    DispatchQueue.main.async
	{
		self.marker.map = self.mapView
	}
	updateDetailsAsNewAddress(locationName: place.name ?? "", formattedAddress: place.formattedAddress ?? "")
    if isSearchFromHome {
        self.getCurrentLocationDetails()
    }
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
	
	//MARK:- Update Details as New Address
	
	func updateDetailsAsNewAddress(locationName : String , formattedAddress : String)
	{
		let cellAddressName = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeLabel.rawValue, section: 0)) as! NameTVCell
		cellAddressName.textField.text = locationName
		cellAddressName.btnClearText.isHidden =  locationName.isEmpty
		let cellAddressInfo = self.tableViewNewAddress.cellForRow(at: IndexPath(row: addAddress_tableField.placeAddress.rawValue, section: 0)) as! InfoTVCell
        
       //var address =  "\(locationName),\(formattedAddress)"
        var address =  "\(formattedAddress)"
        address = address.replacingOccurrences(of: ", ", with: ",")
        var arAddr = address.split(separator: ",")
        arAddr = arAddr.removingDuplicates()
        address = arAddr.joined(separator: ",")
		cellAddressInfo.textView.text = address
        cellAddressInfo.btnClear.isHidden = formattedAddress.isEmpty
		self.textFieldLocationName.text = locationName
		if !isMapOpen && isAddAddressOpen
		{
			//self.isAddAddressOpen = true
			self.isDeleteViewiWillOpen = false
			self.viewNewAddress.isHidden = false
			self.viewSearch.isHidden = false
            self.btnCurrentLocation.isHidden = false
			self.topview.isHidden = false
            self.imgNavigation.isHidden = false
			self.btnSaveAddress.isHidden = false
		}
		
	}
}

//MARK:- GSM Location Delegate
extension CustomerLocationVC : CLLocationManagerDelegate
{
	private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		let location = locations.last

		//let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 5.0)
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: zoomLevel)
		self.mapView?.animate(to: camera)

		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()

	}
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Status ",status.rawValue)
        if status.rawValue == 4
        {
        
        }
        
    }
	func moveToLocation(toLocation: CLLocationCoordinate2D?)
	{
		
	}
}
//MARK:- TableView Methods
extension CustomerLocationVC : UITableViewDelegate,UITableViewDataSource, UIPopoverPresentationControllerDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == 150
        {
            return 40
        }
		return UITableView.automaticDimension
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag == 150
		{
			return 2
		}
		else if tableView.tag == 5 // Add New Address
		{
				return 4
		}
		return (Addresses.count + 1)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == 150
		{
				let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
				cell.selectionStyle = .none
				cell.textLabel?.text = self.text[indexPath.row]
				cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 19)
				
				cell.backgroundColor = UIColor.clear
			
				return cell
		}
		else if tableView.tag == 5 // Add New Address
		{
			switch indexPath.row {
				case addAddress_tableField.placeAddress.rawValue:
					let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTVCell", for: indexPath) as! InfoTVCell
					//cell.lblTitle.text  = "Address"
                    cell.btnClear.tag = indexPath.row
                    cell.textView.delegate = self
                    cell.textView.setLeftRightPadding(5, 40)
                    cell.btnClear.addTarget(self, action: #selector(clearTextView(_ :)), for: .touchUpInside)
					cell.selectionStyle = .none
					return cell
				case addAddress_tableField.unitNumber.rawValue:
					let cell = tableView.dequeueReusableCell(withIdentifier: "NameTVCell", for: indexPath) as! NameTVCell
					cell.lblTitle.text = "Unit Number"
					cell.textField.placeholder = "(Optional)"
                    cell.textField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
                    cell.btnClearText.tag = indexPath.row
                    cell.textField.tag = indexPath.row
                    cell.btnClearText.addTarget(self, action: #selector(clearText(_ :)), for: .touchUpInside)
					cell.selectionStyle = .none
					return cell
				case addAddress_tableField.placeType.rawValue:
					let cell = tableView.dequeueReusableCell(withIdentifier: "AddressIconTVCell", for: indexPath) as! AddressIconTVCell
					cell.btnHome.addTarget(self, action: #selector(selectLocationType(_ :)), for: .touchUpInside)
					cell.btnBeach.addTarget(self, action: #selector(selectLocationType(_ :)), for: .touchUpInside)
					cell.btnOffice.addTarget(self, action: #selector(selectLocationType(_ :)), for: .touchUpInside)
					cell.btnLocation.addTarget(self, action: #selector(selectLocationType(_ :)), for: .touchUpInside)
					cell.selectionStyle = .none
					return cell
				
				case addAddress_tableField.placeLabel.rawValue:
					let cell = tableView.dequeueReusableCell(withIdentifier: "NameTVCell", for: indexPath) as! NameTVCell
					cell.lblTitle.text = "Label"
					cell.textField.placeholder = ""
                    cell.textField.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
                    cell.btnClearText.tag = indexPath.row
                    cell.textField.tag = indexPath.row
                    cell.btnClearText.addTarget(self, action: #selector(clearText(_ :)), for: .touchUpInside)
					cell.selectionStyle = .none
					return cell
				
			default:
				return UITableViewCell()
			}
		}
		else
		{
			if indexPath.row == 0
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTVCell", for: indexPath) as! LocationTVCell
				cell.btnRight.tag = indexPath.row
				cell.btnRight.addTarget(self, action: #selector(actionGetCurrentLoaction(_ :)), for: .touchUpInside)
				cell.btnRight.setImage(#imageLiteral(resourceName: "reload"), for: .normal)
				cell.lblHeader.text = "Current Location"
				cell.lblContent.text = currentAddress
				cell.imageViewLeft.image = #imageLiteral(resourceName: "curr_location_green")
				
				//indexPaths![indexPath.row] = indexPath
				return cell
			}
			else
			{
				let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTVCell", for: indexPath) as! LocationTVCell
				let currIndex = indexPath.row - 1
				let addressType = Addresses[currIndex].addressType ?? ""
				let addressTitle = Addresses[currIndex].addressTitle ?? ""
				//let addressId = Addresses[currIndex].addressId ?? 0
				var unit = ""
				if Addresses[currIndex].unitNumber ?? "" != ""
				{
					unit = "\(Addresses[currIndex].unitNumber ?? ""), "
				}
				let address = "\(unit)\(Addresses[currIndex].address ?? "")"
				//var addressTypeImageName = ""
				if addressType.lowercased() ==  "home"
				{
					//addressTypeImageName = "\(addressType)_round"
					cell.imageViewLeft.image = #imageLiteral(resourceName: "home_round")
				}
				else if addressType.lowercased() ==  "work"
				{
					cell.imageViewLeft.image = #imageLiteral(resourceName: "briefcase_round")
				}
				else if addressType.lowercased() ==  "hotel"
				{
					cell.imageViewLeft.image = #imageLiteral(resourceName: "sun_umbrella_round")
				}
				else
				{
					cell.imageViewLeft.image = #imageLiteral(resourceName: "location_round")
				}
				//cell.imageViewLeft.image = UIImage(named: addressTypeImageName)
				cell.btnRight.tag = indexPath.row
				cell.btnRight.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
				let image = UIImage(named: "ellipsis")?.withRenderingMode(.alwaysTemplate)
				cell.btnRight.setImage(image, for: .normal)
				cell.btnRight.tintColor = .black
				cell.lblHeader.text = addressTitle
				//indexPaths![indexPath.row] = indexPath
				cell.lblContent.text = address
				return cell
				
			}
		}
		
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.tag == 150 // click for popover options (edit & delete)
		{
			//self.popover.dismiss()
			if indexPath.row == 0 // edit
			{
				updateDetailsAsEditAddress(name: "", address: "")
			}
			else
			{
				self.isDeleteViewiWillOpen = true
				if deleteCustomView == nil
				{
					deleteCustomView = DeleteCustomView(nibName: "DeleteCustomView", bundle: nil)
					deleteCustomView?.delegate = self
					deleteCustomView?.showDeleteView(viewDisplay: self.view)
				}
				else
				{
					deleteCustomView?.hideView()
					deleteCustomView = nil
				}
			}
		}
		else if tableView.tag == 0
		{
			let currIndex = indexPath.row - 1
			if indexPath.row == 0 // Current Location
			{
				//actionGetCurrentLoaction(btnBack)
				if !LOCATION_AVAILABLE
                {
                    return
                }
                defaultAddress = currentAddressObj
			}
			else
			{
				defaultAddress = Addresses[currIndex]
			}
            if defaultAddress?.latitude != nil && defaultAddress?.longitude != nil {
			if !isMapPresented
			{
				let navVc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerTabBarNavigation") as! UINavigationController
							navVc.navigationBar.isHidden = true
				APP_DELEGATE.window?.rootViewController = navVc
				/*let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerTabBarVC") as! CustomerTabBarVC
				if #available(iOS 13.0, *) {
					APP_DELEGATE.window?.rootViewController = nextViewController
					//UIApplication.shared.windows.first?.rootViewController = initialViewController
					APP_DELEGATE.window?.makeKeyAndVisible()
				} else {
					//APP_DELEGATE.window!.rootViewController = initialViewController
					UIApplication.shared.windows.first?.rootViewController = nextViewController
					UIApplication.shared.windows.first?.makeKeyAndVisible()
				}
				self.navigationController?.popToRootViewController(animated: true)*/
				//self.navigationController?.pushViewController(nextViewController, animated: true)
			}
			else
			{
				self.dismiss(animated: true, completion: {
					isMapPresented = false
					self.delegate?.updateLocationValues()
				})
			}
            } else {
                self.showOkAlert(message: "Please select your current location. If you've disable location service then please turn on the location service from your device setting.")
            }
		}
	}
    @objc func clearTextView(_ sender : UIButton)
       {
           if let cell = tableViewNewAddress.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? InfoTVCell
           {
               cell.btnClear.isHidden = true
               cell.textView.text = ""
           }
           
       }
    @objc func clearText(_ sender : UIButton)
    {
        if let cell = tableViewNewAddress.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? NameTVCell
        {
            cell.btnClearText.isHidden = true
            cell.textField.text = ""
        }
        
    }
	@objc func actionGetCurrentLoaction(_ sender : UIButton)
	{
		
		var currentLoc: CLLocation!
		if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
		CLLocationManager.authorizationStatus() == .authorizedAlways) {
		   currentLoc = locationManager.location
			if currentLoc == nil
			{
				currentLoc = locationManager.location
				
			}
//		   print("Location  latitude ::",currentLoc.coordinate.latitude)
//		   print("Loaction longitude ::",currentLoc.coordinate.longitude)
		}
		if currentLoc == nil
		{
			print("Location Not Found")
			currentLoc = locationManager.location
			if currentLoc == nil
			{
				print("Location Missing")
                IHProgressHUD.dismiss()
                getCurrentLocationDetails()
				return
			}
		}
		currentLocation = currentLoc
		//let camera = GMSCameraPosition.camera(withLatitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, zoom: 15.0)
		let camera = GMSCameraPosition.camera(withLatitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, zoom: zoomLevel)
		mapView.camera = camera
		
		//marker.icon = #imageLiteral(resourceName: "location_indicator")
		marker.position = CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		getCurrentLocationDetails()
	}
	
	
	@objc func selectLocationType(_ sender : UIButton)
	{
		addressType = sender.tag
        
		if sender.tag == 1
		{
			currAddressType = "Home"
		}
		else if sender.tag == 2
		{
			currAddressType = "work"
		}
		else if sender.tag == 3
		{
			currAddressType = "hotel"
		}
		else
		{
			currAddressType = ""
		}
	}
	
	@objc func rightButtonAction(_ sender : UIButton)
	{
		let tag = sender.tag
		if tag == 0
		{
			actionGetCurrentLoaction(sender)
			
		}
		else
		{
			blackPopView.frame = self.view.frame
			blackPopView.backgroundColor = UIColor.black
			blackPopView.alpha = 0.8
			selectIndex = tag - 1
			selectedAddressId = Addresses[selectIndex].addressId ?? 0
			self.view.addSubview(blackPopView)
			// selectAddressId = addressList[sender.tag].id
			if  let cell = self.tableViewBottom.cellForRow(at: IndexPath(row: tag, section: 0)) as? LocationTVCell
			{
				guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopOverVC") as? PopOverVC else { return }
				
				popVC.modalPresentationStyle = .popover
				popVC.popOverDelegate = self
				let popOverVC = popVC.popoverPresentationController
				//   APP_DELEGATE.delegate = self
				
				popOverVC?.permittedArrowDirections = .up
				popOverVC?.containerView?.layer.cornerRadius = 0
				popOverVC?.delegate = self
				
				popOverVC?.sourceView = cell.btnRight
				popOverVC?.sourceRect = CGRect(x: cell.btnRight.bounds.midX, y: cell.btnRight.bounds.minY + 25, width: 0, height: 0)
				popVC.preferredContentSize = CGSize(width: 120, height: 100)
				
				self.present(popVC, animated: true)
			}
		}
		/*
		selectedAddressId = tag
		print("Selected Address ID : \(tag)")
//		if tag == 0
//		{
//
//
//			//self.locationManager.startUpdatingLocation()
//		}
//		else
//		{
			
			let width = 120
			let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: width, height: (40 * text.count)))
			tableView.tag = 150
			tableView.delegate = self
			tableView.dataSource = self
			tableView.isScrollEnabled = false
			tableView.backgroundColor = UIColor.clear
			//tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			tableView.separatorColor = UIColor.clear
			//tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
			
			let options = [
				.type(.down),
				.cornerRadius(10),
				.animationIn(0.1),
				.animationOut(0.1),
				.blackOverlayColor(UIColor.black.withAlphaComponent(0.7))
			] as [PopoverOption]
			popover = Popover(options: options,
							  showHandler: nil,
							  dismissHandler: {
//								self.childFillLayer.isHidden = true
//								if self.isDeleteViewiWillOpen
//								{
//									self.parentFillLayer.isHidden = false
//									//self.view.bringSubviewToFront(self.parentFillLayer)
//									self.parentFillLayer.bringSubviewToFront(self.parentFillLayer)
//								}
//								else
//								{
//									self.parentFillLayer.isHidden = true
//								}
			}
			)
			popover.popOverDelegate = self
			//let frame = self.view.convert(sender.frame, from:self.tableViewBottom)
			let frame = tableViewBottom.getFrame(ofIndexPath: IndexPath(item: sender.tag, section: 0))
			//popover.show(tableView, point: frame.origin)
		
				 self.parentFillLayer.isHidden = false
				 self.childFillLayer.isHidden = false
//				 self.parentFillLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//				 self.childFillLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
			
			popover.show(tableView, point: CGPoint(x: tableViewBottom.frame.maxX * 2, y: frame.minY - frame.height), inView: tableViewBottom)
	//	}*/
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.blackPopView.removeFromSuperview()
    }
}
//MARK:- TextView, TextField Delegate
extension CustomerLocationVC : UITextFieldDelegate,UITextViewDelegate{
    @objc func textFieldValueChange(_ txt: UITextField) {
        let txtValue = txt.text.asString()
        if txtValue.isEmpty
        {
            if let cell = tableViewNewAddress.cellForRow(at: IndexPath(row: txt.tag, section: 0)) as? NameTVCell
            {
                cell.btnClearText.isHidden = true
            }
        }
        else
        {
            if let cell = tableViewNewAddress.cellForRow(at: IndexPath(row: txt.tag, section: 0)) as? NameTVCell
            {
                cell.btnClearText.isHidden = false
            }
            
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        if let cell = tableViewNewAddress.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as? InfoTVCell
        {
            cell.btnClear.isHidden = text?.isEmpty ?? true
        }
       
    }
}

//MARK:- PopOver Delegate
extension CustomerLocationVC : DeleteCustomViewDelegate, PopoverDelegate
{
	func dismissPopOver(_ type: String) {
		self.blackPopView.removeFromSuperview()
		print("dismiss : ", type)
		if (type == "Edit")
		{
            self.btnMyLocation.isHidden = true
            self.btnSearchLocation.isHidden = true
			updateDetailsAsEditAddress(name: "", address: "")
		}
		else if (type == "Delete")
		{
			self.isDeleteViewiWillOpen = true
			if deleteCustomView == nil
			{
				deleteCustomView = DeleteCustomView(nibName: "DeleteCustomView", bundle: nil)
				deleteCustomView?.delegate = self
				deleteCustomView?.showDeleteView(viewDisplay: self.view)
			}
			else
			{
				deleteCustomView?.hideView()
				deleteCustomView = nil
			}
		}
	}
	
	func dismissDialog() {
		deleteCustomView?.hideView()
		deleteCustomView = nil
		self.parentFillLayer.isHidden = true
	}
	
	func deleteAddress() {
		
		deleteCustomView?.hideView()
		deleteCustomView = nil
		self.parentFillLayer.isHidden = true
		deleteSelectedAddress()
	}
	
	
}
//MARK:- PopOver Delegate
extension CustomerLocationVC : PopOverDelegate
{
	func PopOverdismiss() {
		self.childFillLayer.isHidden = true
		self.parentFillLayer.isHidden = true
		
	}
}
