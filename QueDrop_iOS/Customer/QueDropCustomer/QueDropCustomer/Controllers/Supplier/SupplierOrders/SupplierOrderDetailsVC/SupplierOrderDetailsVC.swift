//
//  SupplierOrderDetailsVC.swift
//  QueDrop
//
//  Created by C100-105 on 03/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderDetailsVC: SupplierBaseViewController {

    @IBOutlet weak var viewDriver: SupplierOrderDriverDetailView!
    
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var order = SupplierOrder(json: .null)
    var isNeedToGetOrderDetails = false
    
    enum Enum_OrderDetails: Int {
        case Images = 0
        case Details
        case OrderComplete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isNeedToGetOrderDetails {
            getOrderDetails()
        }
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @objc func tapBtnCall(_ sender: Any) {
        guard let driverDetail = order.driverDetail else {
            return
        }
        
        let phoneNumber = driverDetail.countryCode.asInt().description + driverDetail.phoneNumber.asString()
        let url = "tel://+\(phoneNumber)"
        self.openUrl(url: url)
    }
    
    func bindDetails() {
        viewDriver.btnCall.addTarget(self, action: #selector(tapBtnCall(_:)), for: .touchUpInside)
        
        guard let user = order.customerDetail else {
            return
        }
        
        //viewDriver.bindDetail(ofDriver: user)
        viewDriver.bindDetail(ofCustomer: user)
    }
    
    func setupUI() {
        bindDetails()
        
        view.backgroundColor = .white
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierOrderImageTVC",
            "SupplierOrderTextDetailTVC",
            "SupplierOrderCompleteTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 5, footHeight: 20)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    func getOrderDetails() {
        API_SupplierOrder.shared.getSingleSupplierOrder(
            orderId: (order.orderId).asInt(),
            responseData: { order in
                self.order = order
                self.setupUI()
                self.tableView.reloadData()
        },
            errorData: { isDone, message in
                if !isDone {
                    self.showAlert(title: "Alert", message: message)
                }
        })
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierOrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2//3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_OrderDetails(rawValue: section) else {
            return 0
        }
        switch row {
        case .Images:
            return (order.products?.count).asInt()
            
        case .Details:
            return 3
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_OrderDetails(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch row {
        case .Images:
            guard let products = order.products else {
                return UITableViewCell()
            }
            let product = products[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderImageTVC", for: indexPath) as! SupplierOrderImageTVC
            cell.imgBlackTransparent.isHidden = false
            cell.bindDetail(ofProduct: product)
            return cell
            
        case .OrderComplete:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderCompleteTVC", for: indexPath) as! SupplierOrderCompleteTVC
            cell.setupUI()
            return cell
            
        case .Details:
            return getTextDetailCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let products = order.products,
            let row = Enum_OrderDetails(rawValue: indexPath.section),
            row == .Images else {
                return
        }
        
        let product = products[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierOrderProductDetailVC") as! SupplierOrderProductDetailVC
        vc.product = product
        pushVC(vc)
    }
    
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderTextDetailTVC", for: indexPath) as! SupplierOrderTextDetailTVC
        cell.setupUI()
        
        cell.viewRight.isHidden = !(indexPath.row == 1)
        
        cell.lblRightTitle.text = ""
        cell.lblRightValue.text = ""
        
        var traillingSpace: CGFloat = 5
        
        var left: (String, String?) = ("", "")
        switch indexPath.row {
        case 0:
            left.0 = "Order ID"
            left.1 = "#" + (order.orderId.asInt()).description
            break
            
        case 1:
            traillingSpace = 50
            left.0 = "Order Date"
            left.1 = (order.createdAt?.toDate())?.toString(format: "dd-MM-yyyy")
            
            cell.lblRightTitle.text = "Order Time"
            cell.lblRightValue.text = (order.createdAt?.toDate())?.toString(format: "hh:mm a")
            break
            
        case 2:
            let name = ((order.driverDetail?.firstName).asString() + " " + (order.driverDetail?.lastName).asString())
            
            left.0 = "Driver Name"
            left.1 = name.trimmingCharacters(in: .whitespaces)
            break
            
        default:
            break
        }
        
        cell.lblLeftTitle.text = left.0
        cell.lblLeftValue.text = left.1
        
        cell.constraintLeftBorderTrailling.constant = traillingSpace
        cell.constraintRightBorderTrailling.constant = traillingSpace
        
        return cell
    }
    
}
