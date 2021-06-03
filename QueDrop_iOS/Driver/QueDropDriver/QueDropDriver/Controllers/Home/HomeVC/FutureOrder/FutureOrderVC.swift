//
//  FutureOrderVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 12/06/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class FutureOrderVC: UIViewController {
    
    //CONSTANTS
    enum enumFuturOrderCell : Int {
        case DateCell = 0
        case OrderDetails
    }
    
    enum enumOrderCells : Int {
        case topStoreDetails = 0 // "topStoreDetails"
        case storeItem//= "storeItem"
        case storeDetails //= "storeDetails"
        case amountDetails //= "amountDetails"
    }
    
    //VARIABLES
    var arrOrders : [FutureOrders] = []
    var selectedDate = Date()
    var arrFutureDates : [FutureOrderDates] = []
    var cellType = [Int : Int]() //row:Type
    var arrCellType : [ [Int : Int]] = []
    var storeIndex = [Int : Int]() //section:storesIndex
    var arrStoreIndexForProduct : [[Int : Int]] = []
    var arrStoreProductIndex : [[Int : [Int : Int]]] = []
    var rowsInSection : [Int] = [] //rowCount
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tblOrder: UITableView!
    @IBOutlet weak var viewBG: UIView!
    
    //MARK:- VC LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
    }
        
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
     }
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        tblOrder.delegate = self
        tblOrder.dataSource = self
        
        selectedDate = Date()
    }
     
    func setupGUI() {
        self.viewBG.backgroundColor = VIEW_BACKGROUND_COLOR
         updateViewConstraints()
         self.view.layoutIfNeeded()
                        
         lblTitle.text = "Future Order Requests"
         lblTitle.textColor = .black
         lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
         lblNoData.text = "There are no future orders for selected date"
         lblNoData.textColor = .gray
         lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))
         
        //GET DATES WHEN FUTURE ORDERS AVAILABLE FOR CALENDAR
         getFutureOrderDates()
         getFutureOrders(date: "\(DateFormatter(format: "yyyy-MM-dd").string(from: selectedDate))")
    }
    
    func setUpDetails()
    {
       // tblOrder.isHidden = arrOrders.count == 0
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
        self.tblOrder.reloadData()
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func btnBack(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func btnDateClicked(btn : UIButton) {
        if let calendarView = HomeStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            calendarView.currDate = selectedDate
            calendarView.usedFor =  .advanced
            calendarView.delegate = self
            calendarView.isForFutureOrder = true
            calendarView.arrFutureDates = arrFutureDates
            self.present(calendarView, animated: false, completion: nil)
        }
    }
    
    @objc func btnOpenMonthlyDateCalendar(btn : UIButton) {
        if let calendarView = HomeStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            var arrDts = [String]()
            if let recurredOn = arrOrders[btn.tag].recurredOn {
                arrDts = recurredOn.components(separatedBy: ",")
            }
           
            calendarView.currDate = selectedDate
            calendarView.usedFor =  .advanced
            //calendarView.delegate = self
            calendarView.isForMonthly = true
            calendarView.arrMonthlyDates = arrDts
            self.present(calendarView, animated: false, completion: nil)
        }
    }
    
    func createOrderIdMutableString(orderId : Int) -> NSMutableAttributedString {
        
        let s1 = NSMutableAttributedString(string: "Order ID: ")
        let s2 = NSMutableAttributedString(string: "#\(orderId)")
        
        s1.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))!, range: NSMakeRange(0, s1.length))
        s1.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, s1.length))
        
        s2.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 12.0))!, range: NSMakeRange(0, s2.length))
        s2.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, s2.length))
        
        s1.append(s2)
        
        return s1
    }
}

//MARK:- UITABLEVIEW DELEGATE DATASOURCE METHODS
extension FutureOrderVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + arrOrders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumFuturOrderCell.DateCell.rawValue:
            return 1
        case enumFuturOrderCell.OrderDetails.rawValue:
            return rowsInSection[section-1]
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case enumFuturOrderCell.DateCell.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSelectionCell") as! CalendarSelectionCell
                cell.btnDate.setTitle("\(DateFormatter(format: "dd MMMM yyyy").string(from: selectedDate))", for: .normal)
                cell.btnDate.addTarget(self, action: #selector(btnDateClicked(btn:))
                    , for: .touchUpInside)
                
                return cell
            case enumFuturOrderCell.OrderDetails.rawValue:
                switch arrCellType[indexPath.section - 1][indexPath.row] {
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
                    if let storeDetails  = arrOrders[indexPath.section - 1].stores?[storeIndex[indexPath.row] ?? 0]
                    {
                        cell.lblStoreName.text = storeDetails.storeName ?? ""
                        cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
                        if let logoUrl = storeDetails.storeLogo
                        {
                            cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                        }
                        else
                        {
                            cell.imgStoreLogo.image = QUE_AVTAR
                        }
                    }
                    
                    if let customerInfo = arrOrders[indexPath.section - 1].customerDetail {
                        if let imgUsr = customerInfo.userImage
                        {
                            cell.imgUser.sd_setImage(with: imgUsr.getUserImageURL(), placeholderImage: USER_AVTAR,completed : nil)
                        }
                        else
                        {
                            cell.imgUser.image = USER_AVTAR
                        }
                        var name = "\(customerInfo.firstName ?? "") \(customerInfo.lastName ?? "")"
                                           
                       if (customerInfo.firstName!.length) > 0
                       {
                           name = "\(customerInfo.firstName ?? "") \(customerInfo.lastName ?? "")"
                       } else {
                           name = "\(customerInfo.email?.components(separatedBy: "@")[0] ?? "")"
                       }
                        cell.lblCustomerName.text = name
                        cell.lblAddress.text = customerInfo.address
                        cell.viewRating.rating = Double(customerInfo.rating!)
                    }
                    cell.selectionStyle = .none
                    return cell
                case enumOrderCells.storeDetails.rawValue:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderCenterTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
                    if let storeDetails  = arrOrders[indexPath.section - 1].stores?[storeIndex[indexPath.row] ?? 0]
                    {
                        cell.lblStoreName.text = storeDetails.storeName ?? ""
                        cell.lblStoreAddress.text = storeDetails.storeAddress  ?? ""
                        if let logoUrl = storeDetails.storeLogo
                        {
                            cell.imgStoreLogo.sd_setImage(with: URL(string: "\(URL_STORE_LOGO_IMAGES)\(logoUrl)"), placeholderImage: QUE_AVTAR,completed : nil)
                        }
                        else
                        {
                            cell.imgStoreLogo.image = QUE_AVTAR
                        }
                    }
                    cell.selectionStyle = .none
                    return cell
                case enumOrderCells.storeItem.rawValue:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderItemsTVCell", for: indexPath) as! CurrentOrderItemsTVCell
                    if let storeDetails  = arrOrders[indexPath.section - 1].stores?[arrStoreIndexForProduct[indexPath.section - 1][indexPath.row] ?? 0]
                    {
                        if let product  = storeDetails.products?[arrStoreProductIndex[indexPath.section - 1][storeDetails.storeId ?? 0]?[indexPath.row] ?? 0]
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
                    cell.lblOrderAmount.text  = "\(Currency)\(arrOrders[indexPath.section - 1].orderTotalAmount ?? 0)"
                    cell.outerView.clipsToBounds = true
                    cell.outerView.layer.cornerRadius = 8
                    cell.outerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                    cell.innerView.clipsToBounds = true
                    cell.innerView.layer.cornerRadius = 8
                    cell.innerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                    
                    let dateStr = arrOrders[indexPath.section - 1].recurredOn ?? ""
                    let timeStr = arrOrders[indexPath.section - 1].recurringTime ?? ""
                    
                    let dateFormatter = DateFormatter()
                    
                    //date = date.UTCtoLocal().toDate()!
                    //let date = dateFormatter.date(from:dateStr)!
                    
                    let recurringType = arrOrders[indexPath.section - 1].recurringType ?? ""
                   
                    cell.selectionStyle = .none
                    
                    cell.lblOrderId.text = "Order Id: #\(arrOrders[indexPath.section - 1].recurringOrderId ?? 0)"
                    cell.lblOrderId.attributedText = createOrderIdMutableString(orderId : arrOrders[indexPath.section - 1].recurringOrderId ?? 0)
                    
                    if recurringType == "Monthly" {
                        cell.btnCalendar.tag = indexPath.section - 1
                        cell.btnCalendar.addTarget(self, action: #selector(btnOpenMonthlyDateCalendar(btn:)), for: .touchUpInside)
                        cell.btnCalendar.isHidden = false
                    } else {
                        cell.btnCalendar.isHidden = true
                    }
                    
                    let df = DateFormatter()
                    df.dateFormat = "HH:mm:ss"
                   let time = df.date(from: timeStr)
                    
                    if recurringType == "Once" {
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        var date = dateFormatter.date(from:dateStr)!
                        date = date.UTCtoLocal().toDate()!
                    
                        cell.lblOrderDateTime.text  = "\(DateFormatter(format: "dd MMMM yyyy").string(from: date)) at \(DateFormatter(format: "h:mm a").string(from: time!))"
                    } else if recurringType == "Weekly" {
                        let recurredOn = arrOrders[indexPath.section - 1].recurredOn ?? ""
                        cell.lblOrderDateTime.text  = "\(recurredOn) at \(DateFormatter(format: "h:mm a").string(from: time!))"
                    } else {
                        cell.lblOrderDateTime.text  = "\(recurringType) at \(DateFormatter(format: "h:mm a").string(from: time!))"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let vc = HomeStoryboard.instantiateViewController(withIdentifier: "FutureOrderDetailVC") as! FutureOrderDetailVC
            vc.orderId = arrOrders[indexPath.section - 1].recurringOrderId!
            vc.orderDetails = arrOrders[indexPath.section - 1]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

//MARK:- CALENDAR DELEGATE METHOD
extension FutureOrderVC : CalenderViewDelegate {
    func selectedWeekDates(dates: [Date]) {
        if dates.count != 0
        {
            let cell = tblOrder.cellForRow(at: IndexPath(row: 0, section: 0)) as! CalendarSelectionCell
            selectedDate = dates.first!
            cell.btnDate.setTitle("\(DateFormatter(format: "dd MMMM yyyy").string(from: selectedDate))", for: .normal)
            getFutureOrders(date: "\(DateFormatter(format: "yyyy-MM-dd").string(from: selectedDate))")
            //getEarningDataFromAPI(selectedDate: selectedDate)
        }
    }
    
    
}
