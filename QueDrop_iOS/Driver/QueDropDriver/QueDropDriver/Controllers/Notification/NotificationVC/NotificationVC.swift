//
//  NotificationVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 20/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

enum Enum_NotificationType: Int {
    case Order_Request = 1
    case Order_Accept
    case Order_Reject
    case Order_Request_Timeout
    case Recurring_Order_Placed
    case Rating
    case Near_By_Place
    case Driver_verification
    case Order_receipt
    case order_dispatch
    case order_delivered
    case order_cancelled
    case chat
    case driverWeeklyPayment
    case supplierWeeklyPayment
    case manualStorePayment
    case unKnownType = 0
}

class NotificationVC: BaseViewController {
    //CONSTANTS
          
       //VARIABLES
      var arrOfNotification: [SupplierNotifications] = []
      var pageNumOffset = 1
      var isLoadMore = true
       
       //IBOUTLETS
       @IBOutlet weak var lblTitle: UILabel!
       @IBOutlet weak var tableView: UITableView!
        
       //MARK:- VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = "Notifications"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_BOLD, size: 20.0)
        setupTableView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            pullrefreshCallback()
        }
        
        func setupTableView(tableView: UITableView) {
            
            setupPullRefresh(tblView: tableView, delegate: self)
            tableView.register("NotificationViewCell")
            
            tableView.keyboardDismissMode = .onDrag
            
            tableView.isScrollEnabled = true
            tableView.bounces = true
            tableView.separatorStyle = .none
            tableView.allowsSelection = true
            
            //tableView.contentInsetAdjustmentBehavior = .never
            tableView.setHeaderFootertView(headHeight: 15, footHeight: 15)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = VIEW_BACKGROUND_COLOR
        }
        
    }

    extension NotificationVC: PullToRefreshDelegate {
        
        func pullrefreshCallback() {
            arrOfNotification.removeAll()
            tableView.reloadData()
            pageNumOffset = 1
            
            getNotification()
        }
        
        func getNotification() {
            getNotificationList()
        }
        
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return tableView.setRows(arrOfNotification, noDataTitle: "", message: "")
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let notification = arrOfNotification[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationViewCell") as! NotificationViewCell
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
                
            case .Order_Request,
                .Order_Request_Timeout:
                let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderRequestDetailVC") as! OrderRequestDetailVC
                orderVC.orderId = id
                orderVC.isFromNotification = true
                navigationController?.pushViewController(orderVC, animated: true)
                break
                
            case .Order_Reject,
                 .Order_receipt,
                 .order_dispatch,
                 //.Order_Accept,
                 .Recurring_Order_Placed:
                let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
                   orderVC.orderId = id
                   navigationController?.pushViewController(orderVC, animated: true)
                   break
    
            case .order_delivered,
                 .order_cancelled:
                
                let orderVC = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
                orderVC.orderId = id
                orderVC.isFromPast = true
                navigationController?.pushViewController(orderVC, animated: true)
                break
                
            case .unKnownType:
                break
                
            case .Order_Accept,
                 .chat:
                break
            case .driverWeeklyPayment:
                navigationController?.tabBarController?.selectedIndex = tTAB_EARNING
                APP_DELEGATE?.FromHomeEarning = true
                break
            case .supplierWeeklyPayment:
                break
            case .manualStorePayment:
                navigationController?.tabBarController?.selectedIndex = tTAB_EARNING
                APP_DELEGATE?.FromHomeEarning = false
                break
            }
        }
        
    }
