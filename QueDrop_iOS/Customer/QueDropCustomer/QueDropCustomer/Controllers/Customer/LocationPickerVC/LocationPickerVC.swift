//
//  LocationPickerVC.swift
//  QueDrop
//
//  Created by C100-104 on 21/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IHProgressHUD

protocol locationPickerDelegate {
	func selectedLocationAddress(at storelocation : Address)
}


class LocationPickerVC: UIViewController {

	@IBOutlet var btnClose: UIButton!
	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var searchView: UIView!
	@IBOutlet var txtSearch: UITextField!
	@IBOutlet var btnCancelSearch: UIButton!
	@IBOutlet var btnDone: UIButton!
	//variables
	var isViewPresented = true
	var currentAddress = ""{
		didSet{
			self.txtSearch.text = currentAddress
		}
	}
	
	var currentAddressObj : Address = Address(object: (Any).self)
	// Map Variables
	var locationManager = CLLocationManager()
	var currentLocation: CLLocation?
	var placesClient: GMSPlacesClient!
	var zoomLevel: Float = 15.0
	var marker = GMSMarker()
	//Location
	let geocoder = CLGeocoder()
	var delegate : locationPickerDelegate?
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
			setMapView()
    }
	override func viewWillAppear(_ animated: Bool) {
		let origImage = UIImage(named: "close")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		btnClose.setImage(tintedImage, for: .normal)
		btnClose.tintColor = .black
	}
	
	@IBAction func btnCloseView(_ sender: Any) {
		if isViewPresented
		{
			self.dismiss(animated: true, completion: nil)
		}
	}
	@IBAction func actionCancelSearch(_ sender: Any) {
		print("Search Cancel")
	}
	@IBAction func textViewDidTapped(_ sender: Any) {
		print("Search Tapped")
	}
	@IBAction func textFieldTapped(_ sender: Any) {
	  txtSearch.resignFirstResponder()
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
		present(acController, animated: true, completion: nil)
	}
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        if ((delegate?.selectedLocationAddress(at: currentAddressObj)) != nil)
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
	//MARK:- Functions
	func setMapView()
	{
        btnDone.setImage(setImageTintColor(image: UIImage(named: "Checkbox_Checked"), color: .black), for: .normal)
		self.mapView.isMyLocationEnabled = true
		searchView.layer.masksToBounds = false
		searchView.layer.shadowColor = UIColor.gray.cgColor
		searchView.layer.shadowOffset = CGSize(width: 0, height: 3)
		searchView.layer.shadowRadius = 5
		searchView.layer.shadowOpacity = 0.7
		searchView.clipsToBounds = false
		placesClient = GMSPlacesClient.shared()
		self.locationManager.delegate = self
		
		let latitude = defaultAddress?.latitude ?? ""
		let longitude = defaultAddress?.longitude ?? ""
		let pos = CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: Double(latitude) ?? 0)!, longitude: CLLocationDegrees(exactly: Double(longitude) ?? 0)!)
		let camera = GMSCameraPosition.camera(withLatitude: pos.latitude,
							longitude: pos.longitude,
							zoom:  15.0)
		mapView.camera = camera
		marker.position = CLLocationCoordinate2D(latitude: pos.latitude, longitude: pos.longitude)
		marker.icon = #imageLiteral(resourceName: "store_location")
		marker.appearAnimation = .pop
		//marker.isDraggable = true
		mapView.delegate = self
		
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		//locationManager.requestWhenInUseAuthorization()
		//set Visible Details
		self.currentAddressObj.address = defaultAddress?.address ?? ""
		self.currentAddressObj.addressId = 0
		self.currentAddressObj.addressTitle = defaultAddress?.addressTitle ?? ""
		self.currentAddressObj.addressType = ""
		self.currentAddressObj.latitude = latitude
		self.currentAddressObj.longitude = longitude
		self.currentAddress = defaultAddress?.address ?? ""
		//GetCurrentLoaction()
	}
	
	func GetCurrentLoaction()
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
				return
			}
		}
		currentLocation = currentLoc
		//let camera = GMSCameraPosition.camera(withLatitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, zoom: 15.0)
		let camera = GMSCameraPosition.camera(withLatitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude, zoom: 15.0)
		mapView.camera = camera
		
		//marker.icon = #imageLiteral(resourceName: "location_indicator")
		marker.position = CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		getLocationDetails()
	}
	func getLocationDetails()
	{
		
		geocoder.cancelGeocode()
		geocoder.reverseGeocodeLocation(currentLocation!) { response, error in
			if let error = error as NSError?, error.code != 10 {
				// ignore cancelGeocode errors
				// show error and remove annotation
				let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
				self.present(alert, animated: true) {
					//self.mapView.removeAnnotation(annotation)
				}
			} else if let placemark = response?.first {
				
				let name = placemark.name
				print("Location name ::",name)
				print("Location Placemark ::",placemark)
				self.currentAddressObj.address = "\(placemark.address())\(placemark.postalCode ?? "")"
				self.currentAddressObj.addressId = 0
				self.currentAddressObj.addressTitle = name
				self.currentAddressObj.addressType = ""
				self.currentAddressObj.latitude = self.currentLocation?.coordinate.latitude.description ?? ""
				self.currentAddressObj.longitude = self.currentLocation?.coordinate.longitude.description ?? ""
				self.currentAddress = "\(placemark.address())\(placemark.postalCode ?? "")"
				
			}
		}
	}
}
//MARK:- Google Map Delegate
extension LocationPickerVC : GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
		print("marker dragged to location: ", marker.position.latitude, marker.position.longitude)
		
		//let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 15.0)
		let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 15.0)
		mapView.camera = camera
		marker.position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
		
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
		self.currentLocation = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
		self.getLocationDetails()
	}
	func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		if ((delegate?.selectedLocationAddress(at: currentAddressObj)) != nil)
		{
			self.dismiss(animated: true, completion: nil)
			return true
		}
		return false
	}
	func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
		print("Tapped Co-ordinate",coordinate)
	}
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        //print("Long pressed co-ordinates", coordinate)

        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        DispatchQueue.main.async
        {
            self.marker.map = self.mapView
        }
        self.currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.getLocationDetails()
    }
	
}


//MARK:- Google Places
extension LocationPickerVC: GMSAutocompleteViewControllerDelegate {
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: ",place.name)
	print("Place formated address: ",place.formattedAddress)
    print("Place ID: \(place.placeID)")
    print("Place attributions: \(place.attributions)")
	print("Place Coordinate: \(place.coordinate)")
	currentLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
	currentAddress = place.formattedAddress ?? ""
	self.currentAddressObj.address = place.formattedAddress ?? ""
	self.currentAddressObj.addressId = 0
	self.currentAddressObj.addressTitle = place.name ?? ""
	self.currentAddressObj.addressType = ""
	self.currentAddressObj.latitude = place.coordinate.latitude.description
	self.currentAddressObj.longitude = place.coordinate.longitude.description
	//let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
	
	viewController.dismiss(animated: true, completion: {
		let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15)
		self.mapView.camera = camera
		
		self.marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
		DispatchQueue.main.async
		{
			self.marker.map = self.mapView
		}
	})
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
	
	
}

//MARK:- GSM Location Delegate
extension LocationPickerVC : CLLocationManagerDelegate
{
	private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		let location = locations.last

		//let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 5.0)
		let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
		self.mapView?.animate(to: camera)

		//Finally stop updating location otherwise it will come again and again in this delegate
		self.locationManager.stopUpdatingLocation()

	}
}
