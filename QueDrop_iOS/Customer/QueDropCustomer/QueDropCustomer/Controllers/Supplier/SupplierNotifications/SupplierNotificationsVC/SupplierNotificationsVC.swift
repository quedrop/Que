//
//  SupplierNotificationsVC.swift
//  QueDrop
//
//  Created by C100-105 on 07/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierNotificationsVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var arrOfNotification: [SupplierNotifications] = []
    var pageNumOffset = 1
    var isLoadMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pullrefreshCallback()
    }
    
    func setupTableView(tableView: UITableView) {
        
        setupPullRefresh(tblView: tableView, delegate: self)
        tableView.register("SupplierNotificationViewCell")
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 15, footHeight: 15)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .tableViewBg
    }
    
}

extension SupplierNotificationsVC: PullToRefreshDelegate {
    
    func pullrefreshCallback() {
        arrOfNotification.removeAll()
        tableView.reloadData()
        pageNumOffset = 1
        
        getNotification()
    }
    
    func getNotification() {
        API_SupplierNotification.shared.getSupplierNotifications(
            responseData: { list, loadMore in
                self.isLoadMore = loadMore
                
                if self.pageNumOffset == 1 {
                    self.arrOfNotification.removeAll()
                }
                self.arrOfNotification.append(contentsOf: list)
                
                if loadMore {
                    self.pageNumOffset += 1
                }
                
                self.tableView.reloadData()
                
        },
            errorData: { isDone, message in
                self.listMessage = message
                self.tableView.reloadData()
        })
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierNotificationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.setRows(arrOfNotification, noDataTitle: listMessage, message: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = arrOfNotification[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierNotificationViewCell") as! SupplierNotificationViewCell
        cell.bindDetails(ofNotification: notification)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        let count = arrOfNotification.count
        
        let isLastCell = count - currentRow == 1
        let minY = tableView.contentOffset.y
        
        if isLoadMore && isLastCell && minY > 0 {
            getNotification()
            isLoadMore = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = arrOfNotification[indexPath.row]
        openNotificationDetailsVC(notification: notification)
    }
    
    func openNotificationDetailsVC(notification: SupplierNotifications) {
        guard let id = notification.dataId else {
            return
        }
        
        switch notification.notificationEnumType {
        case .Driver_verification:
            break
            
        case .Rating:
            break
            
        case .Near_By_Place:
            break
            
        case .Order_Accept,
             .Recurring_Order_Placed:
            let orderVC = SupplierStoryboard.instantiateViewController(withIdentifier: "SupplierOrderDetailsVC") as! SupplierOrderDetailsVC
            
            orderVC.isNeedToGetOrderDetails = true
            
            let order = SupplierOrder(json: .null)
            order.orderId = id
            orderVC.order = order
            
            pushVC(orderVC)
            break
            
        case .Order_Request,
             .Order_Reject,
             .Order_Request_Timeout,
             .Order_receipt,
             .order_dispatch,
             .order_delivered,
             .order_cancelled:
            break
        case .chat,
           .driverWeeklyPayment,
            .manualStorePayment:
                break
        case .supplierWeeklyPayment:
                navigationController?.tabBarController?.selectedIndex = 3
                break
                
        case .unKnownType:
            break
        
        default:
            break
        }
    }
    
}
