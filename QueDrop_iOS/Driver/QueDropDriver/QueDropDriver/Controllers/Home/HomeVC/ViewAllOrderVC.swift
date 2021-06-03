//
//  ViewAllOrderVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 22/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewAllOrderVC: UIViewController {
    //CONSTANTS
       
    //VARIABLES
    var arrOrders : [OrderDetail] = []
    
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
        
   }
    
   func setupGUI() {
    self.viewBG.backgroundColor = VIEW_BACKGROUND_COLOR
        updateViewConstraints()
        self.view.layoutIfNeeded()
                       
        lblTitle.text = "Today's Order"
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
       
        lblNoData.text = "There are no order for today"
        lblNoData.textColor = .gray
        lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14.0))
    
        loadData()
   }
    

    func loadData() {
        tblOrder.delegate = self
        tblOrder.dataSource = self
        tblOrder.reloadData()
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func btnBack(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK:- UITABLEVIEW DELEGATE DATASOURCE METHODS
extension ViewAllOrderVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAllOrderCell") as! ViewAllOrderCell
        let obj = arrOrders[indexPath.row]
        cell.lblOrderId.text = "Order #\(obj.orderId!)"
        cell.lblOrderAmount.text = "Order Amount: \(Currency)\(obj.orderTotalAmount!)"
        let objCustomer = obj.customerDetail
        if (objCustomer?.firstName!.length)! > 0
        {
            cell.lblCustomerName.text = "From: \(objCustomer?.firstName ?? "") \(objCustomer?.lastName ?? "")"
        } else {
            cell.lblCustomerName.text = "From: \(objCustomer?.email?.components(separatedBy: "@")[0] ?? "")"
        }
        
        let dateStr = obj.orderDate ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var date = dateFormatter.date(from:dateStr)!
        date = date.UTCtoLocal().toDate()!
        cell.lblOrderTime.text = "\(DateFormatter(format: "hh:mm a").string(from: date))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.isFromPast = true
        vc.orderId = arrOrders[indexPath.row].orderId!
        navigationController?.pushViewController(vc, animated: true)
    }
}
