//
//  ReviewRatingListVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 14/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class ReviewRatingListVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    var arrReview : [Reviews] = []
    var isDataAvailable = false
    
    //IBOUTLETS
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoData: UILabel!
    
     //MARK:- VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        allNotificationCenterObservers()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        
    }
    
    func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Reviews & Ratings"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
        lblNoData.text = "You haven't received any review and rating yet."
        lblNoData.textColor = .gray
        lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 15.0))
        
        self.tblView.delegate = self
        self.tblView.delegate = self
        self.tblView.isHidden = true
        self.lblNoData.isHidden = true
        getRatingsAndReview(USER_OBJ!.userId ?? 0)
    }
    
    func allNotificationCenterObservers() {
        
        
    }
    
    //MARK: - BUTTON ACTION
    @IBAction func btnBackClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

//MARK:- UITABLEVIEW DELEGATE AND DATASOURCE
extension ReviewRatingListVC : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrReview.count
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
        let obj = arrReview[indexPath.row]
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderId = obj.orderId!
        vc.isFromPast = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
