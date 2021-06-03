//
//  CurrentOrderVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 28/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

@objc protocol CurrentOrderVCDelegate:NSObjectProtocol{
    func naviagteToDetail(currentOrder : OrderDetail)
}

class CurrentOrderVC: UIViewController {

    //CONSTANTS
    enum enumOrderCells : Int {
        case topStoreDetails = 0 // "topStoreDetails"
        case storeItem//= "storeItem"
        case storeDetails //= "storeDetails"
        case amountDetails //= "amountDetails"
    }
    
    //VARIABLES
    var delegate:CurrentOrderVCDelegate?
    var tableHeight = CGFloat(600.0)
    var arrCurrentOrder : [OrderDetail] = []
    var cellType = [Int : Int]() //row:Type
    var arrCellType : [ [Int : Int]] = []
    var storeIndex = [Int : Int]() //section:storesIndex
    var arrStoreIndexForProduct : [[Int : Int]] = []

    //var arrProductIndex = [Int : [Int : Int]]() //[StoreId:storesIndex]
    var arrStoreProductIndex : [[Int : [Int : Int]]] = []
    var rowsInSection : [Int] = [] //rowCount
    
    //IBOUTLETS
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblNoData: UILabel!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderDeliveredNotification(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_DELIVERED), object: nil)
        
        getCurrentOrder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_DELIVERED), object: nil)
    }
    
    @objc func orderDeliveredNotification(notification : Notification) {
        getCurrentOrder()
    }
    
    func setUpDetails()
        {
            tableView.isHidden = arrCurrentOrder.count == 0
           cellType.removeAll()
            rowsInSection.removeAll()
            arrStoreIndexForProduct.removeAll()
            arrStoreProductIndex.removeAll()
            storeIndex.removeAll()
            arrCellType.removeAll()
            var sCount = 0 // section
            for order in arrCurrentOrder
            {
                var rowcount = 0 //row
                var strIndex = 0
                 var storeIndexForProduct = [Int : Int]()
                var storeProductIndex = [Int : [Int : Int]]()
                for store in order.stores!
                {
                    storeIndex[rowcount] = strIndex
                    
                    if rowcount == 0
                    {
                        cellType[rowcount] = enumOrderCells.topStoreDetails.rawValue
                    }
                    else
                    {
                        cellType[rowcount] =  enumOrderCells.storeDetails.rawValue
                    }
                    rowcount += 1
                    var proIndex = 0
                    var productIndex = [Int : Int]()
                    for _ in store.products!
                    {
                        productIndex[rowcount] = proIndex
                        proIndex += 1
                        cellType[rowcount] = enumOrderCells.storeItem.rawValue
                        storeIndexForProduct[rowcount] = strIndex
                        rowcount += 1
                    }
                    storeProductIndex[store.storeId ?? 0] = productIndex
                    
                    strIndex += 1
                }
                cellType[rowcount] = enumOrderCells.amountDetails.rawValue
                rowcount += 1
                rowsInSection.append(rowcount)
                arrCellType.append(cellType)
                arrStoreProductIndex.append(storeProductIndex)
                arrStoreIndexForProduct.append(storeIndexForProduct)
                
                cellType.removeAll()
                
                sCount += 1
            }
            self.tableView.reloadData()
        }
    }

    extension CurrentOrderVC : UITableViewDelegate, UITableViewDataSource{
        func numberOfSections(in tableView: UITableView) -> Int {
            arrCurrentOrder.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return rowsInSection[section]
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch arrCellType[indexPath.section][indexPath.row] {
            case enumOrderCells.topStoreDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
                cell.outerView.clipsToBounds = true
                cell.outerView.layer.cornerRadius = 8
                cell.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                cell.innerView.clipsToBounds = true
                cell.innerView.layer.cornerRadius = 8
                cell.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                
                if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
                {
                    cell.lblStoreName.text = storeDetails.storeName ?? ""
                    cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
                    if let logoUrl = storeDetails.storeLogo
                    {
                        cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                    }
                    else
                    {
                        //cell.imageStoreLogo.image =
                        cell.imgStoreLogo.image = QUE_AVTAR
                        //cell.imgStoreLogo.tintColor = .gray
                    }
                }
                
                if arrCurrentOrder[indexPath.section].deliveryOption == DELIVERY_OPTION.Standard.rawValue {
                    cell.constraintExpressWidth.constant = 0
                } else {
                    cell.constraintExpressWidth.constant = 35
                }
                ////
                cell.layoutIfNeeded()
                cell.selectionStyle = .none
                return cell
            case enumOrderCells.storeDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
                if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[storeIndex[indexPath.row] ?? 0]
                {
                    cell.lblStoreName.text = storeDetails.storeName ?? ""
                    cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
                    if let logoUrl = storeDetails.storeLogo
                    {
                        cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                    }
                    else
                    {
                        //cell.imageStoreLogo.image =
                        cell.imgStoreLogo.image = QUE_AVTAR
                        //cell.imgStoreLogo.tintColor = .gray
                    }
                }
                cell.selectionStyle = .none
                return cell
            case enumOrderCells.storeItem.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderItemsTVCell", for: indexPath) as! CurrentOrderItemsTVCell
                if let storeDetails  = arrCurrentOrder[indexPath.section].stores?[arrStoreIndexForProduct[indexPath.section][indexPath.row] ?? 0]
                {
                    if let product  = storeDetails.products?[arrStoreProductIndex[indexPath.section][storeDetails.storeId ?? 0]?[indexPath.row] ?? 0]
                    {
                        cell.lblProductName.text = product.productName ?? ""
                        //cell.lblProductDetails.text = product.productName ?? ""
                        
                        if storeDetails.canProvideService ?? 0 == 0
                        {
                            //cell.lblProductDetails.text = "Total amount for producst will be updated after  order purchased."
                            cell.lblProductDetails.text = ""
                        }
                        else
                        {
                            if product.addons?.count ?? 0 > 0// || product.productOption.count ?? 0 > 1
                            {
                                var addon : [String] = []
                                if let addOns = product.addons
                                {
                                    for item in addOns
                                    {
                                        addon.append(item.addonName ?? "")
                                    }
                                }
                                /*if let options = product.productOption
                                {
                                    for option in options
                                    {
                                        if option.optionId == product.optionId ?? 0
                                        {
                                            if option.optionName?.lowercased() == "small"
                                            {
                                                addon.append("Small (Serves 1)")
                                            }
                                            else if option.optionName?.lowercased() == "medium"
                                            {
                                                addon.append("Medium (Serves 2)")
                                            }
                                            else if option.optionName?.lowercased() == "large"
                                            {
                                                addon.append("Large (Serves 4)")
                                            }
                                            else if option.optionName?.lowercased() == "default"
                                            {
                                            }
                                            else
                                            {
                                                addon.append(option.optionName ?? "")
                                            }
                                        }
                                    }
                                }*/
                                cell.lblProductDetails.text = addon.joined(separator: ", ")
                            }
                            else
                            {
                                cell.lblProductDetails.text = "Regular"
                            }
                        }
                    }
                }
                cell.imageTypeLogoWidth.constant = 0
                cell.bottomCountViewHeight.constant = 0
                cell.selectionStyle = .none
                return cell
            case enumOrderCells.amountDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderDetailsTVCell", for: indexPath) as! CurrentOrderDetailsTVCell
                cell.lblOrderAmount.text  = "\(Currency)\(arrCurrentOrder[indexPath.section].orderTotalAmount ?? 0)"
                cell.outerView.clipsToBounds = true
                cell.outerView.layer.cornerRadius = 8
                cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                cell.innerView.clipsToBounds = true
                cell.innerView.layer.cornerRadius = 8
                cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                let dateStr = arrCurrentOrder[indexPath.section].orderDate ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                var date = dateFormatter.date(from:dateStr)!
                date = date.UTCtoLocal().toDate()!
               // let date = dateFormatter.date(from:dateStr)!
                cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
                cell.selectionStyle = .none
                cell.btnStatus.setTitle("  \(arrCurrentOrder[indexPath.section].orderStatus ?? "")  ", for: .normal)
                return cell
            default:
                break
            }
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if (self.delegate?.responds(to: #selector(self.delegate?.naviagteToDetail(currentOrder:))))! {
                self.delegate?.naviagteToDetail(currentOrder: arrCurrentOrder[indexPath.section])
            }
        }
    }
