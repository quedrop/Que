//
//  ExploreSearchVC.swift
//  QueDropCustomer
//
//  Created by C100-174 on 06/10/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import CoreLocation

class ExploreSearchVC: BaseViewController {
    //CONSTANTS
    enum SearchResult : Int {
        case Stores
        case Products
    }
    
    //VARIABLE
    var tableViewSections : [String] = ["Stores","Products"]
    var refreshControl = UIRefreshControl()
    var arrStores : [Store] = []
    var arrProducts : [Products] = []
    
    //IBOUTLETS
    @IBOutlet var btnCart: UIButton!
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var btnCloseSearch: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var btnBadge: UIButton!
    @IBOutlet var imgPlaceholder: UIImageView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    //MARK:- VC LIFE CUCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isTabbarHidden(false)
        let d = [ "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                  "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0] as [String : Any]
        APP_DELEGATE.socketIOHandler?.getCartCount(dic: d, completion: { (badgeCount) in
            self.btnBadge.isHidden = badgeCount == 0
            self.btnBadge.setTitle("\(badgeCount)", for: .normal)
        })
    }
    //MARK:- INITIALISATION AND SETUP
    func initialization() {
        tableView.delegate = self
        tableView.dataSource = self
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        btnCloseSearch.isHidden = true
        
    }
    
    @objc func refreshData(_ sender:AnyObject) {
        refreshControl.endRefreshing()
        self.tableView.reloadData()
        if txtSearch.text!.count > 0 {
            exploreSearch(strText: txtSearch.text!)
        }
       // self.getOffers()
    }
    
    //MARK:- BUTTONS CLICKS
    @IBAction func actionCancelSearch(_ sender: UIButton) {
        if txtSearch.text != "" {
            txtSearch.text = ""
             btnCloseSearch.isHidden = true
            exploreSearch(strText: txtSearch.text!)
        }
    }
    
    @IBAction func actionCart(_ sender: Any) {
       let nextViewController = CustomerCartStoryboard.instantiateViewController(withIdentifier: "CartViewVC") as! CartViewVC
        nextViewController.isFromExplore = true
       self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}

//MARK:- TEXTFIELD DELEGATE METHOD
extension ExploreSearchVC : UITextFieldDelegate{
    @objc func textFieldValueChange(_ txt: UITextField) {
        let txtValue = txt.text.asString()
        if txtValue.isEmpty{
            btnCloseSearch.isHidden = true
        }else{
            btnCloseSearch.isHidden = false
        }
        exploreSearch(strText: txtSearch.text!)
    }
}

//MARK:- UITABLEVIEW DELEGATE AND DATASOURCE METHOD
extension ExploreSearchVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SearchResult.Stores.rawValue:
            if arrStores.count > 0{
                return 1
            }else { return 0 }
        case SearchResult.Products.rawValue:
            if arrProducts.count > 0 {
                return  1
            }else{ return 0}
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SearchResult.Stores.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell") as! HomeComonTVCell
            cell.selectionStyle =  .none
            
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell.collectionView.reloadData()
            cell.btnSeeAll.isHidden = true
            cell.collectionView.tag = SearchResult.Stores.rawValue
            cell.lblHeader.text = tableViewSections[SearchResult.Stores.rawValue]
            //cell.constraintPageControlHeight.constant = 0
            if let layout = cell.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
            cell.layoutIfNeeded()
            return cell
        case SearchResult.Products.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell") as! HomeComonTVCell
            cell.selectionStyle =  .none
            cell.collectionView.isScrollEnabled = false
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell.collectionView.reloadData()
            cell.btnSeeAll.isHidden = true
            cell.collectionView.tag = SearchResult.Products.rawValue
            cell.lblHeader.text = tableViewSections[SearchResult.Products.rawValue]
            //cell.constraintPageControlHeight.constant = 0
            if let layout = cell.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
            }
            cell.layoutIfNeeded()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section
        {
        case SearchResult.Stores.rawValue:
            if arrStores.count > 0{
                return 200
            }else { return 0 }
        case SearchResult.Products.rawValue:
            if arrProducts.count > 0 {
                let height = (tableView.frame.size.width - 10.0)/2.5
                return CGFloat(ceil(Double(arrProducts.count)/3.0)) * height + 20.0
            }else{ return 0}
        default:
            return 0
        }
    }
}

//MARK:- UICOLLECTIONVIEW DELEGATE AND DATASOURCE METHOD
extension ExploreSearchVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size = 0
        switch collectionView.tag {
            case SearchResult.Stores.rawValue:
                 size = self.arrStores.count
                
            case SearchResult.Products.rawValue:
                size = self.arrProducts.count
            default:
                break
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case SearchResult.Stores.rawValue:
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreSlidingCell", for: indexPath) as? StoreSlidingCell {
                collectionView.isScrollEnabled = true
                let obj = arrStores[indexPath.row]
                let imgURL = "\(URL_STORE_LOGO_IMAGES)\(obj.storeLogo ?? "")"
                cell.imgStore.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
                cell.lblStoreName.text = obj.storeName ?? ""
                cell.lblLocation.text = obj.storeAddress ?? ""
                cell.lblKms.text = "\(distance(lat1: Double(obj.latitude ?? "") ?? 0, lon1: Double(obj.longitude ?? "") ?? 0, lat2: Double(defaultAddress?.latitude ?? "") ?? 0, lon2: Double(defaultAddress?.longitude ?? "") ?? 0, isTest: true))"
                
                return cell
            }
        
        case SearchResult.Products.rawValue:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCVC", for: indexPath) as? ProductCVC
                {
                    collectionView.isScrollEnabled = true
                    let obj = arrProducts[indexPath.row]
                    let imgURL = "\(URL_PRODUCT_IMAGES)\(obj.productImage ?? "")"
                    
                    cell.lblName.font = UIFont(name: fFONT_MEDIUM, size:12.0)
                    cell.lblPrice.font = UIFont(name: fFONT_MEDIUM, size:12.0)
                    cell.imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
                    cell.btnOption.isHidden = true
                    cell.lblName.text = obj.productName ?? ""
                    cell.lblPrice.text = "\(Currency) \(obj.productPrice ?? 0)"
                    cell.constraintBtnWidth.constant = 0
                    cell.layoutIfNeeded()
//                    cell.imgCategory.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
//                    cell.lblCategory.textAlignment = .left
//                    cell.lblCategory.attributedText = createProductNamePriceString(strProductName: obj.productName ?? "", strPrice: "\(obj.productPrice ?? 0)")
                    return cell
                }

        default:
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
       
        case SearchResult.Stores.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: collectionView.frame.width - 50.0, height:collectionView.frame.height - 20.0)
            return size
        case SearchResult.Products.rawValue:
//            var size = CGSize(width: 300, height: 100)
//            size = CGSize(width: (collectionView.bounds.width / 3) - 10 , height: ((collectionView.bounds.width / 2) ) )
//            return size
            let width: CGFloat = (collectionView.frame.width / 3) - 10
            let height: CGFloat = width * 1.2
            
            let size = CGSize(width: width, height: height)
            return size
        default:
            
            return CGSize(width: 300, height: 100)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        
           case SearchResult.Stores.rawValue:
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
                nextViewController.setStoreId(storeId: arrStores[indexPath.row].storeId ?? 0)
                self.navigationController?.pushViewController(nextViewController, animated: true)
            break
        case SearchResult.Products.rawValue:
            let id = arrProducts[indexPath.row].storeId ?? 0
            let freshProduce = arrProducts[indexPath.row].freshProduceCategoryId ?? 0
            let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "StoreItemsVC") as! StoreItemsVC
            nextViewController.setStoreId(storeId: id, isSearch: false, SelectedCatIndex: 0, isFreshProduce: freshProduce == 0 ? false : true )
            self.navigationController?.pushViewController(nextViewController, animated: true)
            break
        default:
            break
        }
    }
    
    
    func createProductNamePriceString(strProductName : String, strPrice : String) -> NSMutableAttributedString {
        
        let s1 = NSMutableAttributedString(string: "\(strProductName)\n")
        let s2 = NSMutableAttributedString(string: "\(Currency) \(strPrice)")
        
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size:12.0)!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s1.length))
                
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: 9.0)!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, s2.length))
        
        s1.append(s2)
        
        return s1
    }
    
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
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
                
            }
            else
            {
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
        }
        else
        {
            if time > 50 && time < 60{
                print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
            }
            else if time >= 60{
                print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
                
            }
            else{
                print("Minit : ",time.rounded(toPlaces: 0))
            }
            
            
            let distanceInKM = distanceInMeters / 1000
            if distanceInMeters >= 1000{
                return "\(distanceInKM.rounded(toPlaces: 2)) km"
            }
            else{
                return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
            }
            return "\(distanceInKM)"
        }
        return ""
    }
}

