//
//  SupplierEarningsVC.swift
//  QueDrop
//
//  Created by C205 on 21/05/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierEarningsVC: SupplierBaseViewController {
    //CONSTANTS
       enum enumWeeklyEarningCell : Int {
        case OrderHeader = 0
        case OrderDetails
       }
    
    //VARIABLES
    var arrOrders : [SupplierOrder] = []
    var arrWeeklyData : [WeeklyData] = []
    var arrDates : [Date] = []
    var billingDetails : BillingSummary?
    
    //IBOUTLETS
    @IBOutlet weak var lblDate: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(paymentRecivedForWeek(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_WEEKLY_PAYMENT), object: nil)
    }
    

    func setUpUI() {
        tableView.register("SupplierOrderDetailTVC")
        tableView.register("SupplierOrderFooterTVC")
      
        tableView.keyboardDismissMode = .onDrag
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
        
        tableView.tableHeaderView = nil
        tableView.tableHeaderView = viewTableHeader
        setUpChart()
        
        btnDate.setTitleColor(.lightGray, for: .normal)
        btnDate.titleLabel?.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 12.0))
        
        lblTitleEarning.textColor = THEME_COLOR
        lblTitleEarning.text = "earnings".uppercased()
        lblTitleEarning.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 11.0))
        
        lblTotalEarning.textColor = THEME_COLOR
        lblTotalEarning.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 26.0))
        
       
       
       //tableView.contentInsetAdjustmentBehavior = .never
      /* tableView.setHeaderFootertView(headHeight: 20, footHeight: 20)*/
       
       
       tableView.backgroundColor = .tableViewBg
        
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
    
    func setUpDetails() {
        if arrOrders.count > 0 {
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
        if let calendarView = SupplierStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            calendarView.currDate = arrDates.first!
            calendarView.usedFor =  .multi
            calendarView.delegate = self
            self.present(calendarView, animated: false, completion: nil)
        }
    }
    
    @IBAction func actionShowCalendar(_ sender: UIButton) {
        if let calendarView = SupplierStoryboard.instantiateViewController(withIdentifier: "CalendarViewVC") as? CalendarViewVC
        {
            calendarView.currDate = Date()
            calendarView.usedFor =  sender.tag != 20 ? .multi : .single
            calendarView.delegate = self
            self.present(calendarView, animated: false, completion: nil)
        }
    }
}
extension SupplierEarningsVC : CalenderViewDelegate {
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

extension SupplierEarningsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrOrders.count + 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            if let products = arrOrders[section - 1].products, products.count > 0 {
                return products.count + 1
            }
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let isFirstCell = index == 0
        
        let order = arrOrders[indexPath.section - 1]
        guard let products = order.products, products.count > 0 else {
            return UITableViewCell()
        }
        
        if index == products.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderFooterTVC") as! SupplierOrderFooterTVC
            
            let dateStr = order.orderDate ?? ""
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           var date = dateFormatter.date(from:dateStr)!
           date = date.UTCtoLocal().toDate()!
            let name = "\(DateFormatter(format: "dd/MM/yyyy").string(from: date))"
            cell.viewDriver.lblDriverName.text = name
            cell.viewDriver.lblDriverName.textColor = .darkGray
           // cell.bindDetails(order: order)
            return cell
        }
        
        let product = products[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderDetailTVC") as! SupplierOrderDetailTVC
       // cell.bindDetails(ofProduct: product, order: order, isPastOrder: true)
        
        cell.viewProduct.lblQty.adjustsFontSizeToFitWidth = true
               
      
       let url = URL_PRODUCT_IMAGES + product.productImage.asString()
       
        cell.viewProduct.imgProduct.setWebImage(url, .noImagePlaceHolder)
       
        let qtyString = "Qty: " + product.quantity.asInt().description
   cell.viewProduct.lblQty.isHidden = false
        cell.viewProduct.lblQty.text = "\(Currency)\(order.orderAmount ?? 0)"
       cell.viewProduct.lblOrderPlacedDate.text = qtyString
       cell.viewProduct.lblProductName.text = product.productName
       cell.viewProduct.lblQty.textColor = THEME_COLOR
        cell.viewProduct.lblQty.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 15.0))
        
         var name = ((order.customerDetail?.firstName).asString() + " " /*+ (order.customerDetail?.lastName).asString()*/)
         if let lastName =  order.customerDetail?.lastName {
            if lastName.count > 0 {
                name += lastName.prefix(1) + "."
            }
        }
        
       cell.viewProduct.lblCustomerName.text = name.trimmingCharacters(in: .whitespaces)
        
        cell.viewProduct.setBorder(isCorner: isFirstCell)
        if !isFirstCell {
            cell.viewProduct.lblQty.isHidden = true
            cell.viewProduct.addDashedBorder()
        }
        
        return cell
    }
    
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           switch section {
           case 0:
            
                if arrOrders.count > 0 {
                    let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 80.0))
                     let viewSep = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
                     viewSep.backgroundColor = .groupTableViewBackground
                    returnedView.addSubview(viewSep)
                    let lbl = UILabel(frame: CGRect(x: 16, y: 20, width: returnedView.bounds.width - 32, height: returnedView.bounds.height-16))
                    lbl.text = "Weekly Order Summary"
                    lbl.textColor = .black
                    lbl.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 17.0))
                    returnedView.addSubview(lbl)
                    
                    return returnedView
                }
                let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20))
                returnedView.backgroundColor = .groupTableViewBackground
               
               return returnedView
           default:
               break
           }
           return UIView()
       }
       
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
             if arrOrders.count > 0 {
                return 80.0
            }
            return 20.0
        }
           return 0.0
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = arrOrders[indexPath.section - 1]
        openOrderDetailsVC(order: order)
    }
    
    func openOrderDetailsVC(order: SupplierOrder) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierOrderDetailsVC") as! SupplierOrderDetailsVC
        vc.order = order
        pushVC(vc)
        
    }
}
