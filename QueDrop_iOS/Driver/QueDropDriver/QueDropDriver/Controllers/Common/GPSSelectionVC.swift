//
//  GPSSelectionVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 29/02/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import CoreLocation
import IHProgressHUD

class GPSSelectionVC: BaseViewController, CLLocationManagerDelegate {
    //MARK:- CONSTANTS
    
    //MARK:- VARIABLES
    let locationManager = CLLocationManager()
    let locStatus = CLLocationManager.authorizationStatus()
    
    //MARKS:- IBOUTLETS
    @IBOutlet var btnOnGPS: UIButton!
    
    //MARKS:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK:- SETUP AND INITIALISATION
    func setUpUI()  {
        locationManager.delegate = self
        
        drawBorder(view: btnOnGPS, color: .white, width: 1.0, radius: 5.0)
        btnOnGPS.backgroundColor = .clear
        btnOnGPS.setTitleColor(.white, for: .normal)
        btnOnGPS.titleLabel?.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 20.0))
        btnOnGPS.setTitle("Turn On GPS", for: .normal)
    }
    
    //MARK:- BUTTONS CLICKS
    @IBAction func btnGPSOnClicked(_ sender: UIButton) {
        switch locStatus {
           case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
           return
           case .denied, .restricted:
              let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
              alert.addAction(okAction)
              present(alert, animated: true, completion: nil)
           return
           case .authorizedAlways, .authorizedWhenInUse:
                IS_GPS_ON = true
                APP_DELEGATE?.startUpdatingLocation()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(nextViewController, animated: true)
           break
        @unknown default:
            break
        }
    }
    
    //MARK:- CLLOCATION MANAGER DELEGATE METHOD
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Status ",status.rawValue)
        if status.rawValue == 4
        {
            IS_GPS_ON = true
            APP_DELEGATE?.startUpdatingLocation()
            decideNavigation()
        }
    }
    
    func decideNavigation() {
        if(!getIsUserLoggedIn()){
            let vc = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if (USER_OBJ?.isPhoneVerified == 0) {
               let vc = LoginStoryboard.instantiateViewController(withIdentifier: "MobileVerificationVC") as! MobileVerificationVC
                vc.isFromLaunch = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if (USER_OBJ?.isIdentityDetailUploaded ?? 0 == 0) {
                let vc = LoginStoryboard.instantiateViewController(withIdentifier: "UpdateDriverIdentityDetailVC") as!  UpdateDriverIdentityDetailVC
                vc.isFromLaunch = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                navigateToHome()
            }
        }
    }
}
