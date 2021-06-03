//
//  ReviewAndRatingVC.swift
//  QueDrop
//
//  Created by C205 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ReviewAndRatingVC: SupplierBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    //var
    var arrReview : [Reviews] = []
    var isDataAvailable = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.getRatingsAndReview(USER_ID)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.popVC(true)
    }
    
    func setUpDetails()
    {
        isDataAvailable = arrReview.count > 0
        self.tableView.reloadData()
    }
}

extension ReviewAndRatingVC : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.setRows(arrReview, noDataTitle: listMessage, message: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "ReviewAndRatingTVCell", for: indexPath) as? ReviewAndRatingTVCell
        {
            cell.selectionStyle = .none
            cell.bindDetails(image: arrReview[indexPath.row].userImage ?? "",
                 userName: "\(arrReview[indexPath.row].firstName ?? "") \(arrReview[indexPath.row].lastName ?? "")",
                rating: arrReview[indexPath.row].rating ?? 0,
                review: arrReview[indexPath.row].review ?? "", dateTime: arrReview[indexPath.row].createdAt ?? "")
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = arrReview[indexPath.row].orderId ?? 0
        let orderVC = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
       orderVC.setOrderId(id)
       pushVC(orderVC)
    }
}
