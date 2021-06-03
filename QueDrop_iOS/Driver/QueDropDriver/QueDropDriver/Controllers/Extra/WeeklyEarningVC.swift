//
//  WeeklyEarningVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 21/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

@objc protocol WeeklyEarningVCDelegate:NSObjectProtocol{
    func naviagteToDetail(obj : OrderDetail)
}

class WeeklyEarningVC: UIViewController {
    
    //CONSTANTS
    enum enumWeeklyEarningCell : Int {
        case BillDetail = 0
        case OrderHeader
        case OrderDetails
    }
    enum enumOrderCells : Int {
        case topStoreDetails = 0 // "topStoreDetails"
        case storeItem//= "storeItem"
        case storeDetails //= "storeDetails"
        case amountDetails //= "amountDetails"
    }
    
    //VARIABLES
    var delegate:WeeklyEarningVCDelegate?
    var tableHeight = CGFloat(600.0)
    var arrOrders : [OrderDetail] = []
    var cellType = [Int : Int]() //row:Type
    var arrCellType : [ [Int : Int]] = []
    var storeIndex = [Int : Int]() //section:storesIndex
    var arrStoreIndexForProduct : [[Int : Int]] = []
    var arrStoreProductIndex : [[Int : [Int : Int]]] = []
    var rowsInSection : [Int] = [] //rowCount
    var arrDates : [Date] = []
    var billingDetails : BillingSummary?
    var arrWeeklyData : [WeeklyData] = []
    
    //IBOUTLETS
    @IBOutlet var viewTableHeader: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblTotalEarning: UILabel!
    @IBOutlet weak var lblTitleEarning: UILabel!
    @IBOutlet weak var imgPaymentDone: UIImageView!
    @IBOutlet weak var viewChart: BarChartView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        setUpUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentRecivedForWeek(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_WEEKLY_PAYMENT), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func setUpUI() {
        tableView.tableHeaderView = nil
        tableView.tableHeaderView = viewTableHeader
        setUpChart()
        self.tableView.register("EarningBillDetailCell")
        self.tableView.reloadData()
        
        btnDate.setTitleColor(.lightGray, for: .normal)
        btnDate.titleLabel?.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 12.0))
        
        lblTitleEarning.textColor = THEME_COLOR
        lblTitleEarning.text = "earnings".uppercased()
        lblTitleEarning.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))
        
        lblTotalEarning.textColor = THEME_COLOR
        lblTotalEarning.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 26.0))
        
        arrDates = getWeekDates(from: Date())
        if arrDates.count > 0 {
            getEarningDataFromAPI(startDate: arrDates.first!, endDate: arrDates.last!)
            btnDate.setTitle("\(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.first!)) - \(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.last!))", for: .normal)
        }
    }
        
    func setUpChart() {
        // cell.viewChart.delegate = self
        
        viewChart.drawBarShadowEnabled = false
        viewChart.drawValueAboveBarEnabled = false
        viewChart.fitBars = true
        viewChart.doubleTapToZoomEnabled = false
        viewChart.maxVisibleCount = 7
        viewChart.drawGridBackgroundEnabled = false
        viewChart.gridBackgroundColor = .clear
        
        let xAxis = viewChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 10.0))!
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: viewChart)
        xAxis.drawGridLinesEnabled = false
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = "$"
        leftAxisFormatter.positiveSuffix = "$"
        
        let leftAxis = viewChart.leftAxis
        leftAxis.labelFont = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 10.0))!
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        leftAxis.drawGridLinesEnabled = false
        
        let rightAxis = viewChart.rightAxis
        rightAxis.enabled = false
        
        
        let l = viewChart.legend
        l.enabled = false
        
        let marker = XYMarkerView(color: THEME_COLOR.withAlphaComponent(0.2),
                                  font: UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 14.0))!,
                                  textColor: THEME_COLOR,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: viewChart.xAxis.valueFormatter!)
        marker.chartView = viewChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        viewChart.marker = marker
        
       // setDataCount(6, range: 45)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let start = 1
        
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            if arc4random_uniform(100) < 25 {
                return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
            } else {
                return BarChartDataEntry(x: Double(i), y: val)
            }
        }
        
        var set1: BarChartDataSet! = nil
        if let set = viewChart.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.replaceEntries(yVals)
            viewChart.data?.notifyDataChanged()
            viewChart.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: yVals, label: "Weekly Earning")
            set1.colors = [ChartColorTemplates.colorFromString("#006b74")]
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.7
            viewChart.data = data
        }
        
    }
    
    func setUpTableDetails()
    {
        //tableView.isHidden =
        //arrOrders.count == 0
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
        
        if arrWeeklyData.count > 0 {
            lblTotalEarning.text = "\(Currency)\(billingDetails?.totalAmount ?? 0)"
            if billingDetails?.isPaymentDone == 1 {
                imgPaymentDone.isHidden = false
            } else { imgPaymentDone.isHidden = true }
            setChartData()
        } else {
            lblTotalEarning.text = "\(Currency)0"
            imgPaymentDone.isHidden = true
            
           viewChart.data = nil
            //return
        }
        self.tableView.reloadData()
    }
    
    func setChartData() {
        
        var arr = [BarChartDataEntry]()
        
        for i in 0..<arrWeeklyData.count {
            let obj = arrWeeklyData[i]
            arr.append(BarChartDataEntry(x: Double(i+1), y: Double(obj.totalAmount!)))
        }
        
        var set1: BarChartDataSet! = nil
        if let set = viewChart.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.replaceEntries(arr)
            viewChart.data?.notifyDataChanged()
            viewChart.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: arr, label: "Weekly Earning")
            set1.colors = [ChartColorTemplates.colorFromString("#006b74")]
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.7
            viewChart.data = data
        }
    }
    func getEarningDataFromAPI(startDate : Date, endDate : Date) {
        getWeeklyEarning(strStartDate: "\(DateFormatter(format: "yyyy-MM-dd").string(from: startDate))", strEndDate: "\(DateFormatter(format: "yyyy-MM-dd").string(from: endDate))")
    }
    
    @objc func paymentRecivedForWeek(notification : Notification){
        let userInfo = notification.userInfo
        getWeeklyEarning(strStartDate: userInfo!["week_start_date"] as! String, strEndDate: userInfo!["week_end_date"] as! String)
    }
    
    //MARK:- BUTTONS ACTIONS
    @IBAction func btnPrevClicked(_ sender: Any) {
        arrDates = getWeekDates(from:  Calendar.current.date(byAdding: .day, value: -1, to: arrDates.first!)!)
        if arrDates.count > 0 {
            getEarningDataFromAPI(startDate: arrDates.first!, endDate: arrDates.last!)
            btnDate.setTitle("\(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.first!)) - \(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.last!))", for: .normal)
        }
    }
    @IBAction func btnNextClicked(_ sender: Any) {
        arrDates = getWeekDates(from:  Calendar.current.date(byAdding: .day, value: 1, to: arrDates.last!)!)
        if arrDates.count > 0 {
            getEarningDataFromAPI(startDate: arrDates.first!, endDate: arrDates.last!)
            btnDate.setTitle("\(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.first!)) - \(DateFormatter(format: "dd MMM yyyy").string(from: arrDates.last!))", for: .normal)
        }
       
    }
    @IBAction func btnDateClicked(_ sender: Any) {
        if let calendarView = HomeStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            calendarView.currDate = arrDates.first!
            calendarView.usedFor =  .multi
            calendarView.delegate = self
            self.present(calendarView, animated: false, completion: nil)
        }
    }
}

//MARK:- UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension WeeklyEarningVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrWeeklyData.count > 0 {
            return 2 + arrOrders.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumWeeklyEarningCell.BillDetail.rawValue:
            return 1
        case enumWeeklyEarningCell.OrderHeader.rawValue:
            return 0
        default:
             return rowsInSection[section-2]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case enumWeeklyEarningCell.BillDetail.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EarningBillDetailCell") as! EarningBillDetailCell
            cell.lblDeliveryTotal.text = "\(Currency)\(billingDetails?.totalDeliveryEarning ?? 0)"
            cell.lblShoppingTotal.text = "\(Currency)\(billingDetails?.totalShoppingEarning ?? 0)"
            cell.lblTipTotal.text = "\(Currency)\(billingDetails?.totalTipEarning ?? 0)"
            cell.lblGrandTotal.text = "\(Currency)\(billingDetails?.totalAmount ?? 0)"
            if billingDetails!.totalReferralEarning! > Float(0.0) {
                cell.viewReferralEarning.isHidden = false
                cell.lblRefferalEarningTotal.text = "\(Currency)\(billingDetails?.totalReferralEarning ?? 0)"
            } else {
                cell.viewReferralEarning.isHidden = true
            }
            return cell
        case enumWeeklyEarningCell.OrderHeader.rawValue:
            return UITableViewCell()
        //case enumWeeklyEarningCell.OrderDetails.rawValue:
        default:
            switch arrCellType[indexPath.section - 2][indexPath.row] {
            case enumOrderCells.topStoreDetails.rawValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentOrderHeaderTVCell", for: indexPath) as! CurrentOrderHeaderTVCell
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
                cell.btnRating.setTitle("  \(DateFormatter(format: "dd/MM/yyyy").string(from: date))  ", for: .normal)
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
                cell.lblOrderAmount.text  = "\(Currency)\(arrOrders[indexPath.section - 2].orderTotalAmount ?? 0)"
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
                cell.btnStatus.setTitle("  \(arrOrders[indexPath.section - 2].orderStatus ?? "")  ", for: .normal)
                return cell
            default:
                break
            }
            return UITableViewCell()
        /*default:
            break*/
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case enumWeeklyEarningCell.BillDetail.rawValue:
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 8))
            returnedView.backgroundColor = .groupTableViewBackground
            return returnedView
        case enumWeeklyEarningCell.OrderHeader.rawValue:
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
            //returnedView.backgroundColor = .groupTableViewBackground
            let lbl = UILabel(frame: CGRect(x: 16, y: 8, width: returnedView.bounds.width - 32, height: returnedView.bounds.height-16))
            lbl.text = "Weekly Order Summary"
            lbl.textColor = .black
            lbl.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 17.0))
            returnedView.addSubview(lbl)
            return returnedView
        default:
            break
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case enumWeeklyEarningCell.BillDetail.rawValue:
            return 8.0
        case enumWeeklyEarningCell.OrderHeader.rawValue:
            return 50.0
        default:
            break
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case enumWeeklyEarningCell.BillDetail.rawValue:
            break
        case enumWeeklyEarningCell.OrderHeader.rawValue:
            break
        default:
             if (self.delegate?.responds(to: #selector(self.delegate?.naviagteToDetail(obj:))))! {
                 self.delegate?.naviagteToDetail(obj: arrOrders[indexPath.section - 2])
             }
        }
        
    }
    
}

//MARK: CHART DELEGATE METHODS
extension WeeklyEarningVC : ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}

//MARK:- CALENDAR DELEGATE METHOD
extension WeeklyEarningVC : CalenderViewDelegate {
    func selectedWeekDates(dates: [Date]) {
        if dates.count != 0
        {
            arrDates = dates
            btnDate.setTitle("\(DateFormatter(format: "dd MMM yyyy").string(from: dates.first!)) - \(DateFormatter(format: "dd MMM yyyy").string(from: dates.last!))", for: .normal)
            getEarningDataFromAPI(startDate: dates.first!, endDate: dates.last!)
        }
        else
        {
            //self.lblDate.text = "Date not available !!!"
        }
    }
    
    
}

