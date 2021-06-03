//
//  SupplierBaseViewController.swift
//  QueDrop
//
//  Created by C100-105 on 31/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import IQKeyboardManager
import CoreLocation

class SupplierBaseViewController: BaseViewController {
    
    var locationManager = CLLocationManager()
    var locationDelegate: CurrentLocationDelegate? = nil
    var lastLocation: CLLocation? = nil
    
    var documentPickerDelegate: DocumentSelectedDelegate?
    var pullToRefreshDelegate: PullToRefreshDelegate?
    var searchBarDelegate: SearchBarDelegate?
    
    var refreshControl = UIRefreshControl()
    
    var imagePicker = UIImagePickerController()
    
    let arrProfileSelection = [
        "Select photo from gallery",
        "Capture photo from camera"
    ]
    
    var blackPopView = UIView()
    var deleteCustomView : DeleteCustomView?
    var editDeleteDelegate: EditDeleteDelegate?
    var editDeleteItem: Any?
    
    var isViewLoadFirstTime = true
    var listMessage = "Loading"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    func pushVC(_ vc: UIViewController, _ animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func popVC(_ animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func deviceHasNotch() -> Bool {
        var bottom: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            bottom = UIApplication.shared.keyWindow?.bounds.height ?? 0
        }
        return bottom > 0
    }
    
    func openUrl(url: String) {
        //print(url)
        let strURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).asString()
        if let url = URL(string: strURL), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: - Swipe gesture handle
    func setupPullRefresh(tblView: UITableView, delegate: PullToRefreshDelegate, isHideLoader: Bool = false) {
        pullToRefreshDelegate = delegate
        tblView.isUserInteractionEnabled = true
        refreshControl.addTarget(self, action: #selector(self.pullToRefreshHandler), for: .valueChanged)
        
        if isHideLoader {
            refreshControl.tintColor = .clear
            refreshControl.backgroundColor = .clear
            //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        }
        
        tblView.refreshControl = refreshControl
    }
    
    func setupPullRefresh(collView: UICollectionView, delegate: PullToRefreshDelegate, isHideLoader: Bool = false) {
        pullToRefreshDelegate = delegate
        collView.isUserInteractionEnabled = true
        refreshControl.addTarget(self, action: #selector(self.pullToRefreshHandler), for: .valueChanged)
        
        if isHideLoader {
            refreshControl.tintColor = .clear
            refreshControl.backgroundColor = .clear
        }
        
        collView.refreshControl = refreshControl
    }
    
    @objc private func pullToRefreshHandler() {
        refreshControl.endRefreshing()
        pullToRefreshDelegate?.pullrefreshCallback()
    }
    
    
}

extension SupplierBaseViewController: UISearchBarDelegate {
    
    func setupSearchBar(searchBar: SearchBarTheme, delegate: SearchBarDelegate) {
        searchBarDelegate = delegate
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        searchBar.text = ""
        searchBarDelegate?.searchBar(text: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarDelegate?.searchBar(text: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = !(searchBar.text ?? "").isEmpty
    }
    
}

extension SupplierBaseViewController: DeleteCustomViewDelegate, PopoverDelegate, UIPopoverPresentationControllerDelegate {
    
    func openEditDeleteAlert(toView: UIView, item: Any, delegate: EditDeleteDelegate) {
        self.editDeleteDelegate = delegate
        self.editDeleteItem = item
        
        blackPopView.frame = self.tabBarController?.view.frame ?? self.view.frame
        blackPopView.backgroundColor = UIColor.black
        blackPopView.alpha = 0.7
        
        (self.tabBarController?.view ?? self.view).addSubview(blackPopView)
        
        guard let popVC = CustomerStoryboard.instantiateViewController(withIdentifier: "PopOverVC") as? PopOverVC else { return }
        
        popVC.modalPresentationStyle = .popover
        popVC.popOverDelegate = self
        let popOverVC = popVC.popoverPresentationController
        
        popOverVC?.permittedArrowDirections = .right
        popOverVC?.containerView?.layer.cornerRadius = 0
        popOverVC?.delegate = self
        
        popOverVC?.sourceView = toView
        popOverVC?.sourceRect = CGRect(x: toView.bounds.midX, y: toView.bounds.minY + 25, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 120, height: 100)
        
        self.present(popVC, animated: true)
    }
    
    func openDeletePopoverAlert(toView: UIView, item: Any, delegate: EditDeleteDelegate) {
        self.editDeleteDelegate = delegate
        self.editDeleteItem = item
        
        blackPopView.frame = self.tabBarController?.view.frame ?? self.view.frame
        blackPopView.backgroundColor = UIColor.black
        blackPopView.alpha = 0.7
        
        (self.tabBarController?.view ?? self.view).addSubview(blackPopView)
        
        guard let popVC = CustomerStoryboard.instantiateViewController(withIdentifier: "PopOverVC") as? PopOverVC else { return }
        
        popVC.modalPresentationStyle = .popover
        popVC.popOverDelegate = self
        popVC.isOnlyDelete = true
        let popOverVC = popVC.popoverPresentationController
        
        popOverVC?.permittedArrowDirections = .right
        popOverVC?.containerView?.layer.cornerRadius = 0
        popOverVC?.delegate = self
        
        popOverVC?.sourceView = toView
        popOverVC?.sourceRect = CGRect(x: toView.bounds.midX, y: toView.bounds.minY + 25, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 120, height: 60)
        //popVC.btnEdit.isHidden = true
        self.present(popVC, animated: true)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.blackPopView.removeFromSuperview()
    }
    
    func dismissPopOver(_ type: String) {
        self.blackPopView.removeFromSuperview()
        
        if (type == "Edit") {
            editDeleteDelegate?.editCallback(item: editDeleteItem)
            
        } else if (type == "Delete") {
            editDeleteDelegate?.deleteCallbackForOpenDeleteAlert()
        }
        
    }
    
    func openDeleteConfirmationAlert(message: String) {
        if deleteCustomView != nil {
            deleteCustomView?.removeFromParent()
            deleteCustomView = nil
        }
        
        deleteCustomView = DeleteCustomView(nibName: "DeleteCustomView", bundle: nil)
        deleteCustomView?.delegate = self
        deleteCustomView?.strMessage = message
        deleteCustomView?.showDeleteView(viewDisplay: tabBarController?.view ?? view)
    }
    
    func dismissDialog() {
        self.blackPopView.removeFromSuperview()
        deleteCustomView?.hideView()
        deleteCustomView = nil
        editDeleteDelegate?.dismissCallback()
    }
    
    func deleteAddress() {
        self.blackPopView.removeFromSuperview()
        deleteCustomView?.hideView()
        deleteCustomView = nil
        editDeleteDelegate?.deleteConfirmCallback(item: editDeleteItem)
    }
}

