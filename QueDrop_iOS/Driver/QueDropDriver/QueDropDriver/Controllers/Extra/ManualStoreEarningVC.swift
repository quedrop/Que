//
//  ManualStoreEarningVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 21/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

@objc protocol ManualStoreEarningVCDelegate:NSObjectProtocol{
    func naviagteToDetail(objOrder : OrderDetail)
}

class ManualStoreEarningVC: UIViewController {
    
    //CONSTANTS
    enum enumWeeklyEarningCell : Int {
        case DateCell = 0
        case SummaryHeader
        case OrderDetails
    }
    
    enum enumOrderCells : Int {
        case topStoreDetails = 0 // "topStoreDetails"
        case storeItem//= "storeItem"
        case storeDetails //= "storeDetails"
        case amountDetails //= "amountDetails"
    }
    
    //VARIABLES
    var delegate:ManualStoreEarningVCDelegate?
    var tableHeight = CGFloat(600.0)
    var arrOrders : [OrderDetail] = []
    var cellType = [Int : Int]() //row:Type
    var arrCellType : [ [Int : Int]] = []
    var storeIndex = [Int : Int]() //section:storesIndex
    var arrStoreIndexForProduct : [[Int : Int]] = []
    var arrStoreProductIndex : [[Int : [Int : Int]]] = []
    var rowsInSection : [Int] = [] //rowCount
    var selectedDate = Date()
    
    //IBOUTLETS
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblNoData: UILabel!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        setUpDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentRecivedForManual(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_WEEKLY_PAYMENT), object: nil)
    }

    func setUpDetails()
    {
        selectedDate = Date()
        self.tableView.reloadData()
        
        lblNoData.text = "No Order found for seelcted date."
        lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))
        lblNoData.textColor = .gray
        lblNoData.isHidden = true
        
        getEarningDataFromAPI(selectedDate: selectedDate)
    }
    
    func getEarningDataFromAPI(selectedDate : Date) {
        getManualStoreEarning(selectedDate: "\(DateFormatter(format: "yyyy-MM-dd").string(from: selectedDate))")
    }
    
    func setUpTableDetails()
    {
        //tableView.isHidden = arrOrders.count == 0
        cellType.removeAll()
        rowsInSection.removeAll()
        arrStoreIndexForProduct.removeAll()
        arrStoreProductIndex.removeAll()
        storeIndex.removeAll()
        arrCellType.removeAll()
        
        var sCount = 0 // section
        for order in arrOrders
        {
            var rowcount = 0 //row
            var strIndex = 0
            var storeProductIndex = [Int : [Int : Int]]()
            var storeIndexForProduct = [Int : Int]() //section:storesIndex
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
            print("section : \(sCount) - RowCount : \(rowcount)")
            cellType.removeAll()
            sCount += 1
        }
        self.tableView.reloadData()
    }
    
    //MARK:- BUTTONS ACTIONS
    @objc func btnDateClicked(btn : UIButton) {
        if let calendarView = HomeStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            calendarView.currDate = selectedDate
            calendarView.usedFor =  .single
            calendarView.delegate = self
            self.present(calendarView, animated: false, completion: nil)
        }
    }
    
    @objc func paymentRecivedForManual(notification : Notification){
        let userInfo = notification.userInfo
        getEarningDataFromAPI(selectedDate: selectedDate)
    }
}

//MARK:- UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension ManualStoreEarningVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrOrders.count > 0 {
            return 2 + arrOrders.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumWeeklyEarningCell.DateCell.rawValue:
            return 1
        case enumWeeklyEarningCell.SummaryHeader.rawValue:
            return 0
        case enumWeeklyEarningCell.OrderDetails.rawValue:
            return rowsInSection[section-2]
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case enumWeeklyEarningCell.DateCell.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSelectionCell") as! CalendarSelectionCell
            cell.btnDate.setTitle("\(DateFormatter(format: "dd MMMM yyyy").string(from: selectedDate))", for: .normal)
            cell.btnDate.addTarget(self, action: #selector(btnDateClicked(btn:))
                , for: .touchUpInside)
            
            return cell
        case enumWeeklyEarningCell.OrderDetails.rawValue:
            switch arrCellType[indexPath.section - 2][indexPath.row] {
            case enumOrderCells.topStoreDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
                cell.isdrawBorder = false
                cell.outerView.clipsToBounds = true
                cell.outerView.layer.cornerRadius = 8
                cell.outerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                cell.innerView.clipsToBounds = true
                cell.innerView.layer.cornerRadius = 8
                cell.innerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                ////
                if let storeDetails  = arrOrders[indexPath.section - 2].stores?[storeIndex[indexPath.row] ?? 0]
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
                ////
                
                let dateStr = arrOrders[indexPath.section - 2].orderDate ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var date = dateFormatter.date(from:dateStr)!
                date = date.UTCtoLocal().toDate()!
               
                
                cell.btnRating.isHidden = false
                cell.btnRating.setTitle(" \(DateFormatter(format: "hh:mm a").string(from: date)) ", for: .normal)
                cell.selectionStyle = .none
                return cell
            case enumOrderCells.storeDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
                if let storeDetails  = arrOrders[indexPath.section - 2].stores?[storeIndex[indexPath.row] ?? 0]
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
                if let storeDetails  = arrOrders[indexPath.section - 2].stores?[arrStoreIndexForProduct[indexPath.section - 2][indexPath.row] ?? 0]
                {
                    if let product  = storeDetails.products?[arrStoreProductIndex[indexPath.section - 2][storeDetails.storeId ?? 0]?[indexPath.row] ?? 0]
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
                cell.lblOrderAmount.text  = "\(Currency)\(arrOrders[indexPath.section - 2].orderAmount ?? 0)"
                cell.outerView.clipsToBounds = true
                cell.outerView.layer.cornerRadius = 8
                cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                cell.innerView.clipsToBounds = true
                cell.innerView.layer.cornerRadius = 8
                cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                let dateStr = arrOrders[indexPath.section - 2].orderDate ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var date = dateFormatter.date(from:dateStr)!
                date = date.UTCtoLocal().toDate()!
                //let date = dateFormatter.date(from:dateStr)!
                cell.lblOrderDateTime.text  = "\(DateFormatter(format: "d MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: date))"
                cell.selectionStyle = .none
                
                if arrOrders[indexPath.section - 2].isPaymentDone == 1 {
                    cell.btnStatus.setTitle(" Payment Received ", for: .normal)
                    cell.btnStatus.setTitleColor(GREEN_COLOR, for: .normal)
                } else {
                    cell.btnStatus.setTitle(" Payment Pending ", for: .normal)
                    cell.btnStatus.setTitleColor(ORANGE_COLOR, for: .normal)
                }
                
                return cell
            default:
                break
            }
            return UITableViewCell()
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case enumWeeklyEarningCell.SummaryHeader.rawValue:
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
            returnedView.backgroundColor = .clear
            let lbl = UILabel(frame: CGRect(x: 20, y: 8, width: returnedView.bounds.width - 40, height: returnedView.bounds.height-16))
            lbl.text = "Summary"
            lbl.textColor = .darkGray
            lbl.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 15.0))
            returnedView.addSubview(lbl)
            return returnedView
        default:
            break
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case enumWeeklyEarningCell.SummaryHeader.rawValue:
            return 40.0
        default:
            break
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.delegate?.responds(to: #selector(self.delegate?.naviagteToDetail(objOrder:))))! {
            self.delegate?.naviagteToDetail(objOrder: arrOrders[indexPath.section - 2]) 
        }
    }
}

//MARK:- CALENDAR DELEGATE METHOD
extension ManualStoreEarningVC : CalenderViewDelegate {
    func selectedWeekDates(dates: [Date]) {
        if dates.count != 0
        {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CalendarSelectionCell
            selectedDate = dates.first!
            cell.btnDate.setTitle("\(DateFormatter(format: "dd MMMM yyyy").string(from: selectedDate))", for: .normal)
            getEarningDataFromAPI(selectedDate: selectedDate)
        }
        else
        {
            //self.lblDate.text = "Date not available !!!"
        }
    }
    
    
}
