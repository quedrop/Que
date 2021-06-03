//
//  FavouriteStoreVC.swift
//  QueDrop
//
//  Created by C205 on 15/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class FavouriteStoreVC: BaseViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblDataNotAvailable: UILabel!
    
    var stores : [Store] = []
    var isApiCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavouriteStore()
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension FavouriteStoreVC : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let staticCount = tableView.bounds.height / 100
        return !isApiCalled ? Int(staticCount) : stores.count
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
            cell?.lblTitle.text = currStoreObj.storeName
            cell?.lblAddress.text = currStoreObj.storeAddress
            let dist = distance(lat1: Double(currStoreObj.latitude ?? "") ?? 0, lon1: Double(currStoreObj.longitude ?? "") ?? 0, in_time: false)
            cell?.lblDistance.text = dist
            let imageURL = self.stores[indexPath.row].storeLogo
            cell?.imageRestaurnt?.sd_setImage(with: URL(string: ("\(URL_STORE_LOGO_IMAGES)\(imageURL ?? "")")),placeholderImage: QUE_AVTAR /*#imageLiteral(resourceName: "order")*/, completed: nil)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            cell?.imgHeart.isUserInteractionEnabled = true
            cell?.imgHeart.addGestureRecognizer(tapGestureRecognizer)
            cell?.imgHeart.tag = indexPath.row //currStoreObj.storeId ?? 0
            //cell?.imageView?.contentMode = .scaleAspectFill
            //cell?.imageView?.sd_setShowActivityIndicatorView(true)
            
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if stores.count != 0
        {
            let currStoreObj = self.stores[indexPath.row]
            if self.stores[indexPath.row].canProvideService ?? 0 == 0
            {
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "AddStoreOrderVC") as! AddStoreOrderVC
                nextViewController.setStoreId(storeId: currStoreObj.storeId ?? 0)
                 nextViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            else
            {
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
                nextViewController.setStoreId(storeId: currStoreObj.storeId ?? 0)
                nextViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let currStoreObj = self.stores[tappedImage.tag]
        markAsFavourite(favouriteStatus: 0, StoreId: currStoreObj.storeId ?? 0,index: tappedImage.tag)
        
    }
}
