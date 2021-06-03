//
//  Ext+BaseVC+TomTom.swift
//  Tournament
//
//  Created by C100-105 on 12/02/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import CoreLocation

extension SupplierBaseViewController: CLLocationManagerDelegate {
    
    //delegate callback gives latest device location
    func startUpdatingCurrentLocation(delegate: CurrentLocationDelegate) {
        locationDelegate = delegate
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lastLocation = location
        locationDelegate?.updatedCurrentLocation(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
}
