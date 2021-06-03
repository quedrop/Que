//
//  ViewController.swift
//  QueDrop
//
//  Created by C100-104 on 26/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit
import CoreLocation
import IHProgressHUD

class ViewController: BaseViewController , CLLocationManagerDelegate {

	@IBOutlet var btnOnGPS: UIButton!
	
	let locationManager = CLLocationManager()
	var locStatus = CLLocationManager.authorizationStatus()
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
        drawBorder(view: btnOnGPS, color: .white, width: 1.0, radius: 5.0)
		// Do any additional setup after loading the view.
	}
	override func viewWillAppear(_ animated: Bool) {
		locStatus = CLLocationManager.authorizationStatus()
	}
	@IBAction func actionTurnOnGPS(_ sender: UIButton) {
	//	print(LOCATION_AVAILABLE)
		switch locStatus {
		   case .notDetermined:
			  locationManager.requestWhenInUseAuthorization()
		   return
		   case .denied, .restricted:
			  /*let alert = UIAlertController(title: "Location Services are disabled", message: "We need your location to find near by stores for you. Please enable location services from settings.", preferredStyle: .alert)
			  let okAction = UIAlertAction(title: "Go to settings", style: .default, handler: {_ in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
              })
              let closeAction = UIAlertAction(title: "Close", style: .destructive, handler: nil)
			  alert.addAction(okAction)
              alert.addAction(closeAction)
			  present(alert, animated: true, completion: nil)*/
                self.navigateToHome()
		   return
		   case .authorizedAlways, .authorizedWhenInUse:
			            self.navigateToHome()

		   break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		print("Status ",status.rawValue)
		if status.rawValue == 4
		{
			/*if UserDefaults.standard.string(forKey: kUserType) != nil   // 0-Customer _ 1-Supplier
			{
				if UserDefaults.standard.string(forKey: kUserType) == "0"
				{
					let storyboard = UIStoryboard(name: "Customer", bundle: nil)
					if let AddressObj = UserDefaults.standard.getCustom(forKey: kDefaultLocation) as? Address
					{
						defaultAddress = AddressObj
						let nextViewController = storyboard.instantiateViewController(withIdentifier: "CustomerTabBarVC") as! CustomerTabBarVC
						self.navigationController?.pushViewController(nextViewController, animated: true)
					}
					else
					{
						let nextViewController = storyboard.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
						self.navigationController?.pushViewController(nextViewController, animated: true)
					}
				}
				else
				{
					UserDefaults.standard.set("\(UserType.rawValue)", forKey: kUserType)
					let storyboard = UIStoryboard(name: "Login", bundle: nil)
					let nextViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
					self.navigationController?.pushViewController(nextViewController, animated: true)
				}
			}
			else
			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
				self.navigationController?.pushViewController(nextViewController, animated: true)
			}*/
           // self.navigateToHome()
		}
         self.navigateToHome()
	}
	
}

