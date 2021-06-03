//
//  BaseViewController.swift
//  Dentist
//
//  Created by C100-105 on 16/07/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import UIKit
import CoreLocation

public typealias Callback = (()->())

protocol CurrentLocationDelegate {
    func updatedCurrentLocation(location: CLLocation)
}

protocol DocumentSelectedDelegate {
    func selectedDocuments(urls: [URL])
}

protocol PullToRefreshDelegate {
    func pullrefreshCallback()
}

protocol SearchBarDelegate {
    func searchBar(text: String)
}

protocol EditDeleteDelegate {
    func editCallback(item: Any?)
    func deleteCallbackForOpenDeleteAlert()
    func deleteConfirmCallback(item: Any?)
    func dismissCallback()
}
