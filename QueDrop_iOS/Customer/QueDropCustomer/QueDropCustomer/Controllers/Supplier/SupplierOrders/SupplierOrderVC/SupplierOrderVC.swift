//
//  SupplierOrderVC.swift
//  QueDrop
//
//  Created by C100-105 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentOrder: UISegmentedControl!
    
    
    var selectedOrderType = 0
    var arrOfOrders: [[SupplierOrder]] = [[], []]
    var isLoadMore: [Bool] = [true, true]
    var pageNumOffset: [Int] = [1,1]
    
    var isFirstTimeLoadSegment = [false, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentOrder.showBorder(.white, 10, 0.5)
        segmentOrder.setupCustomSegment()
        setupTableView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pullrefreshCallback()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentOrder.addCustomSegmentBackground()
    }
    
    @IBAction func segmentOrderTypeValueChange(_ sender: UISegmentedControl) {
        segmentOrder.updateCustomSegment()
        
        selectedOrderType = sender.selectedSegmentIndex
        
        if isFirstTimeLoadSegment[selectedOrderType] {
            pullrefreshCallback()
            isFirstTimeLoadSegment[selectedOrderType] = false
        } else {
            tableView.reloadData()
        }
    }
    
    func setupTableView(tableView: UITableView) {
        
        setupPullRefresh(tblView: tableView, delegate: self)
        tableView.register("SupplierOrderDetailTVC")
        tableView.register("SupplierOrderFooterTVC")
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 20, footHeight: 20)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .tableViewBg
    }
    
}

extension SupplierOrderVC: PullToRefreshDelegate {
    
    func pullrefreshCallback() {
        pageNumOffset[selectedOrderType] = 1
        arrOfOrders[selectedOrderType].removeAll()
        tableView.reloadData()
        
        getOrders()
        
    }
    
    func getOrders() {
        guard let orderType = Enum_OrderType(rawValue: selectedOrderType+1) else {
            self.showAlert(title: "Error", message: "Something went wrong, Please try again later.")
            return
        }
        
        API_SupplierOrder.shared.getSupplierOrders(
            orderType: orderType,
            offset: pageNumOffset[selectedOrderType],
            responseData: { list, loadMore in
                
                self.isLoadMore[self.selectedOrderType] = loadMore
                self.arrOfOrders[self.selectedOrderType].append(contentsOf: list)
                
                if loadMore {
                    self.pageNumOffset[self.selectedOrderType] += 1
                }
                
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.3,
                    execute: {
                    self.tableView.reloadData()
                })
        },
            errorData: { isDone, message in
                self.listMessage = message
                self.tableView.reloadData()
        })
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierOrderVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.setRows(arrOfOrders[selectedOrderType], noDataTitle: listMessage, message: "")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let products = arrOfOrders[selectedOrderType][section].products, products.count > 0 {
            return products.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let isFirstCell = index == 0
        
        let order = arrOfOrders[selectedOrderType][indexPath.section]
        guard let products = order.products, products.count > 0 else {
            return UITableViewCell()
        }
        
        if index == products.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderFooterTVC") as! SupplierOrderFooterTVC
            cell.bindDetails(order: order)
            return cell
        }
        
        let product = products[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderDetailTVC") as! SupplierOrderDetailTVC
        cell.bindDetails(ofProduct: product, order: order, isPastOrder: selectedOrderType == 1)
        
        cell.viewProduct.setBorder(isCorner: isFirstCell)
        if !isFirstCell {
            cell.viewProduct.addDashedBorder()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        let count = arrOfOrders[selectedOrderType].count
        
        let isLastCell = count - currentRow == 1
        let minY = tableView.contentOffset.y
        
        if isLoadMore[selectedOrderType] && isLastCell && minY > 0 {
            isLoadMore[selectedOrderType] = false
            getOrders()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = arrOfOrders[selectedOrderType][indexPath.section]
        openOrderDetailsVC(order: order)
    }
    
    func openOrderDetailsVC(order: SupplierOrder) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierOrderDetailsVC") as! SupplierOrderDetailsVC
        vc.order = order
        pushVC(vc)
        
    }
    
}

