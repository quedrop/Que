//
//  CustomerHomeVC.swift
//  GoferDeliveryCustomer
//
//  Created by C100-104 on 01/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CustomerHomeVC: BaseViewController {
    
    @IBOutlet var btnCart: UIButton!
    @IBOutlet var labelAddress: UILabel!
    @IBOutlet var btnChangeAddress: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var btnBadge: UIButton!
    @IBOutlet weak var btnNotification: UIButton!
    
    //ENUM
    enum cardsType : Int {
        case TodaysDeal = -1
        case PaymentOffers
        case ProductOffers
        case RestaurantOffers
        case FreshProduces
        case Categoyries
    }
    //var tableViewSections : [String] = ["Today Deals", "Payment Offers/Coupons","Product Offers","Restaurant Offers","Categories"]
    var tableViewSections : [String] = ["Payment Offers/Coupon","Product Offers","Restaurant Offers","Fresh Produce","Categories"]
    //Variables
    var refreshControl = UIRefreshControl()
    var dataLoaded = false
    var Categories : [ServiceCategories] = []
    var productOffers : [ProductOffer] = []
    var storeOffers : [StoreOffer] = []
    var orderOffers : [OrderOffer] = []
    var arrFreshProduces : [FreshProduceCategories] = []
    var currentPageIndexForOffer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNotification.setImage(setImageTintColor(image: UIImage(named: "notification"), color: .white), for: .normal)
        btnNotification.isHidden = isGuest
        btnBadge.isEnabled = false
      
        getTermAndCondition()
        if isLoginOrVerifyForOrder
        {
            actionCart(btnCart!)
        }
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        tableView.delegate = self
        dataLoaded = false
        tableView.dataSource = self
        self.labelAddress.text = defaultAddress?.addressTitle ?? ""
        self.getOffers()
//        switch APP_DELEGATE.socketIOHandler?.socket?.status{
//        case .connected?:
//            break
//        default:
//              APP_DELEGATE.socketIOHandler = SocketIOHandler()
//              print("Socket Not Connected")
//            break;
//        }
//
        // Do any additional setup after loading the view.
    }
    
    
    @objc func refreshData(_ sender:AnyObject) {
        refreshControl.endRefreshing()
        dataLoaded = false
        self.tableView.reloadData()
        self.getOffers()
    }
    override func viewWillAppear(_ animated: Bool) {
        isTabbarHidden(false)
        btnNotification.isHidden = isGuest
        let d = [ "user_id" : isGuest ? 0 : USER_OBJ?.userId ?? 0,
                  "guest_user_id" : !isGuest ? 0 : USER_OBJ?.guestUserId ?? 0] as [String : Any]
        APP_DELEGATE.socketIOHandler?.getCartCount(dic: d, completion: { (badgeCount) in
            self.btnBadge.isHidden = badgeCount == 0
            self.btnBadge.setTitle("\(badgeCount)", for: .normal)
        })
        //APP_DELEGATE.socketIOHandler?.getCartCount(dic: d)
        
        self.labelAddress.text = defaultAddress?.addressTitle ?? ""
        self.navigationController?.popToRootViewController(animated: false)
        
        if APP_DELEGATE.navigateToSupplierLogin {
            APP_DELEGATE.navigateToSupplierLogin = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                }
            }
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        btnBadge.isHidden = BADGE_COUNT == 0
        btnBadge.setTitle("\(BADGE_COUNT)", for: .normal)
    }
    @IBAction func actionCart(_ sender: Any) {
        print("Location :",LOCATION_AVAILABLE)
        let nextViewController = CustomerCartStoryboard.instantiateViewController(withIdentifier: "CartViewVC") as! CartViewVC
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBAction func actionChangeAddress(_ sender: Any) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomerLocationVC") as! CustomerLocationVC
        //self.navigationController?.pushViewController(nextViewController, animated: true)
        isMapPresented = true
        nextViewController.delegate = self
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func btnNotificationClicked(_ sender: Any) {
        let vc = CustomerStoryboard.instantiateViewController(withIdentifier: "CustomerNotificationVC") as! CustomerNotificationVC
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK:- Customer Location Delegate
extension CustomerHomeVC : CustomerLocationDelegate{
    func updateLocationValues()
    {
        self.labelAddress.text = defaultAddress?.addressTitle ?? ""
    }
}

//MARK:- Tableview Delegate + Data Source
extension CustomerHomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5//4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case cardsType.TodaysDeal.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell", for: indexPath) as? HomeComonTVCell
            
            cell?.selectionStyle =  .none
            
            cell?.collectionView.delegate = self
            cell?.collectionView.dataSource = self
            cell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell?.collectionView.reloadData()
            cell?.btnSeeAll.isHidden = true
            cell?.collectionView.tag = cardsType.TodaysDeal.rawValue
            cell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.TodaysDeal.rawValue] : ""
            cell?.constraintPageControlHeight.constant = 0
            cell?.layoutIfNeeded()
            return cell ?? UITableViewCell()
        case cardsType.PaymentOffers.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell", for: indexPath) as? HomeComonTVCell
            
            cell?.selectionStyle =  .none
            
            cell?.collectionView.delegate = self
            cell?.collectionView.dataSource = self
            cell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell?.collectionView.reloadData()
            cell?.btnSeeAll.isHidden = true
            cell?.collectionView.tag = cardsType.PaymentOffers.rawValue
            cell?.collectionView.isPagingEnabled = true
            cell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.PaymentOffers.rawValue] : ""
            cell?.constraintPageControlHeight.constant = 30
            cell?.layoutIfNeeded()
            cell?.pageControl.numberOfPages = dataLoaded ? self.orderOffers.count : 0
            cell?.pageControl.currentPage = currentPageIndexForOffer
            
            return cell ?? UITableViewCell()
        case cardsType.ProductOffers.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell", for: indexPath) as? HomeComonTVCell
            
            cell?.selectionStyle =  .none
            
            cell?.collectionView.delegate = self
            cell?.collectionView.dataSource = self
            cell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell?.collectionView.reloadData()
            cell?.btnSeeAll.isHidden = true
            cell?.collectionView.tag = cardsType.ProductOffers.rawValue
            cell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.ProductOffers.rawValue] : ""
            cell?.constraintPageControlHeight.constant = 0
            cell?.layoutIfNeeded()
            return cell ?? UITableViewCell()
        case cardsType.RestaurantOffers.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell", for: indexPath) as? HomeComonTVCell
            
            cell?.selectionStyle =  .none
            
            cell?.collectionView.delegate = self
            cell?.collectionView.dataSource = self
            cell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell?.collectionView.reloadData()
            cell?.btnSeeAll.isHidden = true
            cell?.collectionView.tag = cardsType.RestaurantOffers.rawValue
            cell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.RestaurantOffers.rawValue] : ""
            cell?.constraintPageControlHeight.constant = 0
            cell?.layoutIfNeeded()
            return cell ?? UITableViewCell()
            
        case cardsType.Categoyries.rawValue:
            
            let myCell = tableView.dequeueReusableCell(withIdentifier: "HomeCategoriesTVC", for: indexPath) as? HomeCategoriesTVC
            myCell?.selectionStyle =  .none
            myCell?.collectionView.delegate = self
            myCell?.collectionView.dataSource = self
            myCell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            myCell?.collectionView.reloadData()
            myCell?.collectionView.tag = cardsType.Categoyries.rawValue
            myCell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.Categoyries.rawValue] : ""
            
            return myCell ?? UITableViewCell()
        
        case cardsType.FreshProduces.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeComonTVCell", for: indexPath) as? HomeComonTVCell
            
            cell?.selectionStyle =  .none
            
            cell?.collectionView.delegate = self
            cell?.collectionView.dataSource = self
            cell?.collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            cell?.collectionView.reloadData()
            cell?.btnSeeAll.isHidden = true
            cell?.collectionView.tag = cardsType.FreshProduces.rawValue
            cell?.lblHeader.text = dataLoaded ? tableViewSections[cardsType.FreshProduces.rawValue] : ""
            cell?.constraintPageControlHeight.constant = 0
            cell?.layoutIfNeeded()
            return cell ?? UITableViewCell()
        default:
            let cell = UITableViewCell()
            
            return cell
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row
        {
            case cardsType.TodaysDeal.rawValue:
                return 250
            case cardsType.PaymentOffers.rawValue:
                /*if !dataLoaded
                {
                    return 200
                }*/
                return orderOffers.count == 0 ? 0 : 255
            case cardsType.ProductOffers.rawValue:
                if !dataLoaded
                {
                    return 200
                }
                return productOffers.count == 0 ? 0 : 200
            case cardsType.RestaurantOffers.rawValue:
                if !dataLoaded
                {
                    return 200
                }
                return storeOffers.count == 0 ? 0 : 200
            case cardsType.FreshProduces.rawValue:
                if !dataLoaded
                {
                    return 200
                }
            return arrFreshProduces.count == 0 ? 0 : 200
            case cardsType.Categoyries.rawValue:
                return CGFloat(ceil(Double(Double(Categories.count + 1)/2.0)) * Double(tableView.bounds.width / 3.0)) + 50.0 //350
            default:
                return 0
        }
        
    }
}

//MARK:-CollectionView Delegate + DataSource
extension CustomerHomeVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size = 0
        switch collectionView.tag {
        case cardsType.TodaysDeal.rawValue:
            size = 5
            //return size
        case cardsType.PaymentOffers.rawValue:
            if dataLoaded {
                size = self.orderOffers.count
            }
           /* else {
                size = 2
            }*/
            //return size
        case cardsType.ProductOffers.rawValue:
            if dataLoaded {
                size = self.productOffers.count
            }
            else {
                size = 2
            }
            //return size
        case cardsType.RestaurantOffers.rawValue:
            if dataLoaded {
                size = self.storeOffers.count
            } else {
                size = 2
            }
            //return size
            
        case cardsType.Categoyries.rawValue:
            if dataLoaded {
                size = Categories.count // + 1
            } else {
                size = 4
            }
            //return size
        case cardsType.FreshProduces.rawValue:
            if dataLoaded {
                size = self.arrFreshProduces.count
            } else {
                size = 3
            }
        default:
            break
        }
        print("Size : ",size)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Collection Tag :",collectionView.tag)
        
        switch collectionView.tag {
        case cardsType.TodaysDeal.rawValue:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayDealCVCell", for: indexPath) as? TodayDealCVCell
            {
                return cell
            }
        case cardsType.PaymentOffers.rawValue:
          /*  if !dataLoaded
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantOfferShimmerCVC", for: indexPath) as? RestaurantOfferShimmerCVC {
                    return cell
                }
            }
            else {*/
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentOfferCVCell", for: indexPath) as? PaymentOfferCVCell
                {
//                    if indexPath.row % 2 == 0 {
//                        cell.imgOfferBG.image = setImageViewTintColor(img: cell.imgOfferBG, color: UIColor(red: 169.0/255.0, green: 179.0/255.0, blue: 250.0/255.0, alpha: 1.0).withAlphaComponent(0.4))
//                        cell.btnCouponCode3.backgroundColor = UIColor(red: 169.0/255.0, green: 179.0/255.0, blue: 250.0/255.0, alpha: 1.0)
//                    } else {
//                        //cell.imgOfferBG.image = setImageViewTintColor(img: cell.imgOfferBG, color: THEME_COLOR.withAlphaComponent(0.2))
//                        cell.imgOfferBG.image = setImageViewTintColor(img: cell.imgOfferBG, color: UIColor(red: 255.0/255.0, green: 151.0/255.0, blue: 166.0/255.0, alpha: 1.0).withAlphaComponent(0.4))
//                        cell.btnCouponCode3.backgroundColor = UIColor(red: 255.0/255.0, green: 151.0/255.0, blue: 166.0/255.0, alpha: 1.0)
//                    }
                    
                
                let obj = orderOffers[indexPath.row]
                    cell.lblTitle2.text = obj.offerDescription
                    
                    if obj.discountPercentage! > 0 {
                        cell.constraintViewPercentageWidth.constant = 68
                        cell.lblPercentageOff.attributedText = createPercentageMutableString(strPecentage: "\(obj.discountPercentage!)")
                    } else {
                       cell.constraintViewPercentageWidth.constant = 0
                    }
                    cell.layoutIfNeeded()
                    
                    if obj.couponCode!.count > 0 {
                        cell.btnCouponCode3.isHidden = false
                        cell.btnCouponCode3.setTitle("    " + obj.couponCode! + "    ", for: .normal)
                        cell.lblPromocode.isHidden = false
                        DispatchQueue.main.async {
                            addDashedBorder(withColor: .white, view: cell.btnCouponCode3)
                        }
                    }else {
                        cell.btnCouponCode3.isHidden = true
                        cell.lblPromocode.isHidden = true
                    }
                    
                    if obj.offerRange! > 0 {
                        cell.lblTitle1.text = "All items on"
                        cell.lblTitle2.text = "Order above \(Currency)\(obj.offerRange!)"
                    }
                   
                    if obj.offerType == "FreeDelivery" || obj.offerType == "FreeServiceCharge" {
                        if obj.offerRange! > 0 {
                            cell.lblTitle1.text = obj.offerType == "FreeDelivery" ? "Free Delivery on" : "Free Service Charge on"
                            cell.lblTitle2.text = "Order above \(Currency)\(obj.offerRange!)"
                        } else {
                           cell.lblTitle1.text = "All items on"
                           cell.lblTitle2.text = obj.offerType == "FreeDelivery" ? "Free Delivery on" : "Free Service Charge on"
                        }
                        
                    } else if obj.offerType == "Delivery" || obj.offerType == "ServiceCharge"{
                        if obj.offerRange! > 0 {
                            cell.lblTitle1.text = obj.offerType == "Delivery" ? "Delivery discount on" : "Service charge discount on"
                            cell.lblTitle2.text = "Order above \(Currency)\(obj.offerRange!)"
                        } else {
                           cell.lblTitle1.text = "All items on"
                           cell.lblTitle2.text = obj.offerType == "Delivery" ? "Delivery Discount" : "Service charge discount"
                        }
                    }
                    return cell
                }
          //  }
            
        case cardsType.ProductOffers.rawValue:
            if !dataLoaded
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantOfferShimmerCVC", for: indexPath) as? RestaurantOfferShimmerCVC {
                    return cell
                }
            }
            else
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantOfferCVC", for: indexPath) as? RestaurantOfferCVC {
                    collectionView.isScrollEnabled = true
                    let obj = productOffers[indexPath.row]
                    let imgURL = "\(URL_PRODUCT_IMAGES)\(obj.productImage ?? "")"
                    cell.imageLogo.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
                    cell.lblTitle.text = obj.productName ?? ""
                    cell.lblTypes.text = obj.storeCategoryTitle ?? ""
                    
                    if obj.offerCode?.count == 0 {
                        cell.lblOfferText.text =  "\(obj.offerPercentage ?? 0)% off"
                    } else {
                        cell.lblOfferText.text =  "\(obj.offerPercentage ?? 0)% off | Use Coupon \(obj.offerCode ?? "")"
                    }
                    
                    cell.lblOtherInfo.text = "\(obj.additionalInfo ?? "")"
                    return cell
                }
            }
        case cardsType.RestaurantOffers.rawValue:
            if !dataLoaded {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantOfferShimmerCVC", for: indexPath) as? RestaurantOfferShimmerCVC {
                    return cell
                }
            }
            else
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantOfferCVC", for: indexPath) as? RestaurantOfferCVC
                {
                    collectionView.isScrollEnabled = true
                    let obj = storeOffers[indexPath.row]
                    let imgURL = "\(URL_STORE_LOGO_IMAGES)\(obj.storeLogo ?? "")"
                    let mins = "25 min"
                    cell.imageLogo.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
                    cell.lblTitle.text = obj.storeName ?? ""
                    cell.lblTypes.text = obj.offerType ?? ""
                    
                    if obj.couponCode?.count == 0 {
                       cell.lblOfferText.text =  "\(obj.discountPercentage ?? 0)% off"
                   } else {
                       cell.lblOfferText.text =  "\(obj.discountPercentage ?? 0)% off | Use Coupon \(obj.couponCode ?? "")"
                   }
                    
                    cell.lblOtherInfo.text = "\(obj.storeRating ?? 0.0) • \(mins) • \(obj.offerDescription ?? "")"
                    
                    return cell
                }
            }
        case cardsType.Categoyries.rawValue:
            if !dataLoaded
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesShimmerCVCell", for: indexPath) as? CategoriesShimmerCVCell
                {
                    return cell
                }
            }
            else
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCVCell", for: indexPath) as? CategoriesCVCell
                {
                    collectionView.isScrollEnabled = false
                    /*if indexPath.row == Categories.count {
                        cell.imageCategories.image = #imageLiteral(resourceName: "add_store")
                    } else {*/
                        let url = "\(URL_CATEGORY_IMAGES)\(Categories[indexPath.row].serviceCategoryImage ?? "")"
                        cell.imageCategories.sd_setImage(with: URL(string: url), placeholderImage: BANNER_AVTAR/* #imageLiteral(resourceName: "restaurants")*/,completed: nil)
                    //}
                    /*if Categories.count != 0 && Categories.count > indexPath.row
                    {
                        if Categories[indexPath.row].serviceCategoryName == "Restaurants"
                        {
                            let url = "\(URL_CATEGORY_IMAGES)\(Categories[indexPath.row].serviceCategoryImage ?? "")"
                            cell.imageCategories.sd_setImage(with: URL(string: url), placeholderImage: BANNER_AVTAR/* #imageLiteral(resourceName: "restaurants")*/,completed: nil)
                            //cell.imageCategories.image = #imageLiteral(resourceName: "restaurants")
                        }
                        else if Categories[indexPath.row].serviceCategoryName == "Groceries"
                        {
                            let url = "\(URL_CATEGORY_IMAGES)\(Categories[indexPath.row].serviceCategoryImage ?? "")"
                            cell.imageCategories.sd_setImage(with: URL(string: url), placeholderImage: BANNER_AVTAR /*#imageLiteral(resourceName: "groceries")*/,completed: nil)
                            //cell.imageCategories.image = #imageLiteral(resourceName: "groceries")
                        }
                        else
                        {
                            let url = "\(URL_CATEGORY_IMAGES)\(Categories[indexPath.row].serviceCategoryImage ?? "")"
                            cell.imageCategories.sd_setImage(with: URL(string: url), placeholderImage: BANNER_AVTAR/* #imageLiteral(resourceName: "coffee")*/,completed: nil)
                            //cell.imageCategories.image = #imageLiteral(resourceName: "coffee")
                        }
                    }
                    else
                    {
                        cell.imageCategories.image = #imageLiteral(resourceName: "add_store")
                    }*/
                    return cell
                }
            }
            
        case cardsType.FreshProduces.rawValue:
            if !dataLoaded {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesShimmerCVCell", for: indexPath) as? CategoriesShimmerCVCell {
                    return cell
                }
            }
            else
            {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FreshProduceCell", for: indexPath) as? FreshProduceCell
                {
                    collectionView.isScrollEnabled = true
                    let obj = arrFreshProduces[indexPath.row]
                    let imgURL = "\(URL_STORE_CATEGORY_IMAGES)\(obj.freshProduceImage ?? "")"
                    
                    cell.imgCategory.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR,completed: nil)
                    cell.lblCategory.text = obj.freshProduceTitle ?? ""
                    scaleFont(byWidth: cell.lblCategory)
                    return cell
                }
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
        case cardsType.TodaysDeal.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: (screenWidth / 2.2) - 20 , height: 200.0)
            return size
        case cardsType.PaymentOffers.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: collectionView.bounds.width - 10 , height: collectionView.bounds.height - 10)
            return size
        case cardsType.ProductOffers.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: screenWidth - 20 , height: collectionView.bounds.height - 10)
            return size
        case cardsType.RestaurantOffers.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: screenWidth - 20 , height: collectionView.bounds.height - 10)
            return size
        case cardsType.Categoyries.rawValue:
            var size = CGSize(width: 300, height: 100)
            size = CGSize(width: (collectionView.bounds.width / 2) - 10 , height: (collectionView.bounds.width / 3) )
            return size
        case cardsType.FreshProduces.rawValue:
           var size = CGSize(width: 300, height: 100)
           size = CGSize(width: (collectionView.bounds.width / 2) - 40 , height: collectionView.bounds.height)
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
        case cardsType.Categoyries.rawValue:
            if indexPath.row < Categories.count
            {
                CurrentServiceCategoryId = Categories[indexPath.row].serviceCategoryId ?? 0
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "RestaurantsVC") as! RestaurantsVC
                nextViewController.setServiceId(serviceId: CurrentServiceCategoryId, titleString: Categories[indexPath.row].serviceCategoryName ?? "")
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            else
            {
//                if isGuest
//                {
//                        if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
//                        {
//                            LoginView.setupForGuest()
//                            let transition:CATransition = CATransition()
//                                transition.duration = 0.5
//                                transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//                                transition.type = CATransitionType.push
//                                transition.subtype = CATransitionSubtype.fromTop
//                                self.navigationController?.view.layer.add(transition, forKey: kCATransition)
//                            self.navigationController?.pushViewController(LoginView, animated: false)
//                            //self.navigationController?.pushViewController(LoginView, animated: true)
//                        }
//                }
//                else
//                {
                    let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "AddNewStoreVC") as! AddNewStoreVC
                    self.navigationController?.pushViewController(nextViewController, animated: true)
//                }
            }
            break
            
            case cardsType.FreshProduces.rawValue:
                
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "RestaurantsVC") as! RestaurantsVC
                nextViewController.freshProducedCategoryId = arrFreshProduces[indexPath.row].freshCategoryId ?? 0
                nextViewController.setServiceId(serviceId: 0, titleString: arrFreshProduces[indexPath.row].freshProduceTitle ?? "")
                self.navigationController?.pushViewController(nextViewController, animated: true)
            break
           case cardsType.RestaurantOffers.rawValue:
                let nextViewController = CustomerProductsStoryboard.instantiateViewController(withIdentifier: "StoreDetailsVC") as! StoreDetailsVC
                nextViewController.setStoreId(storeId: storeOffers[indexPath.row].storeId ?? 0)
                self.navigationController?.pushViewController(nextViewController, animated: true)
            break
        default:
            break
        }
    }
    
    
    func createPercentageMutableString(strPecentage : String) -> NSMutableAttributedString {
        
        let s1 = NSMutableAttributedString(string: "Flat\n")
        let s2 = NSMutableAttributedString(string: "\(strPecentage)%\n")
        let s3 = NSMutableAttributedString(string: "off")
        
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, s1.length))
        
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_EXTRABOLD, size: calculateFontForWidth(size: 20.0))!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, s2.length))
        
        s3.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))!, range: NSMakeRange(0, s3.length))
        s3.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: NSMakeRange(0, s3.length))
        
        s1.append(s2)
        s1.append(s3)
        
        return s1
    }
}

//MARK:- SCROLLVIEW DELEGATE METHOD
extension CustomerHomeVC : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let tableCell = tableView.cellForRow(at: IndexPath(row: cardsType.PaymentOffers.rawValue, section: 0)) as? HomeComonTVCell {

            if scrollView == tableCell.collectionView {
                let offSet = scrollView.contentOffset.x
                let width = scrollView.frame.width
                let horizontalCenter = width / 2
                currentPageIndexForOffer = Int(offSet + horizontalCenter) / Int(width)
                tableCell.pageControl.currentPage = currentPageIndexForOffer
            }
        
        }
    }
}
