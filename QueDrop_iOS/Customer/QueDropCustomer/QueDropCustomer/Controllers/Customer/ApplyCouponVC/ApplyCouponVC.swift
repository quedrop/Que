//
//  ApplyCouponVC.swift
//  QueDrop
//
//  Created by C100-104 on 26/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ApplyCouponVC: UIViewController {

	
	@IBOutlet var textCouponCode: UITextField!
	@IBOutlet var btnApply: UIButton!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewBottom: UIView!
	@IBOutlet var lblAmmount: UILabel!
	@IBOutlet var btnApplyOffer: UIButton!
	@IBOutlet var bottomViewHeight: NSLayoutConstraint! // 0-75
    @IBOutlet weak var lblNotAvailable: UILabel!
    
	var delegate : AddonsUpdateDelegate?
	
	var count = 0
	var selectedIndex = -1
	var coupensAry : [Coupons] = []
    var TotalAmt : Float = 0
    var selectedDeliveryOption = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
        // Do any additional setup after loading the view.
		getDiscountCoupons()
    }
	
	//MARK:- Action Methods
	@IBAction func actionBack(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	@IBAction func actionApplyCoupon(_ sender: Any) {
		if !(textCouponCode.text?.isEmpty ?? true)
		{
			applyCoupon(TotalAmt, code: textCouponCode.text ?? "")
		}
		else
		{
			ShowToast(message: "Please Add Coupon Code.")
		}
	}
	
	@IBAction func valueChanged(_ sender: UITextField) {
		if sender.text?.count ?? 0 > 2
		{
			UIView.animate(withDuration: 0.5, animations: {
				self.bottomViewHeight.constant = 75
				self.view.layoutIfNeeded()
			}	)
		}
		else
		{
			UIView.animate(withDuration: 0.5, animations: {
				self.bottomViewHeight.constant = 0
				self.view.layoutIfNeeded()
			}	)
		}
		selectedIndex = -1
		 self.lblAmmount.text = ""
		for index in 0..<count
		{
			
			if tableView.indexPathsForVisibleRows?.contains( IndexPath(row: index, section: 0)) ?? false
			{
				if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CoupenCodeTVC
				{
					cell.btnCheck.isSelected = false
					cell.btnCheck.backgroundColor = .clear
				}
			}
			
		}
	}
	
	func setTotalAmount(amount : Float){
		self.TotalAmt = amount
	}
	
}

//MARK:- TableView DELEGATE
extension ApplyCouponVC : UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CoupenCodeTVC", for: indexPath) as! CoupenCodeTVC
		cell.selectionStyle = .none
		//	cell.textCoupenCode.text = "  SWIGGYIT50 "
		let coupon = coupensAry[indexPath.row]
		cell.textCoupenCode.text = coupon.couponCode ?? ""
		cell.lblCouponTitle.text = "Get \(coupon.discountPercentage ?? 0)% off on minimum Purchese of \(Currency)\(coupon.offerRange ?? 0)"
		let expDate =  DateFormatter().date(from: coupon.expirationDate ?? "") ?? Date()
		let text = "Expris on \(DateFormatter(format: "dd").string(from: expDate)) \(expDate.daySuffix()) \(DateFormatter(format: "MMMM yyyy").string(from: expDate))"
		cell.lblCouponDiscription.text = "\(coupon.offerDescription ?? "")\n\(text)"
		cell.btnCheck.tag = indexPath.row
		if indexPath.row == selectedIndex
		{
			cell.btnCheck.isSelected = true
			cell.btnCheck.backgroundColor = THEME_COLOR
		}
		else
		{
			cell.btnCheck.isSelected = false
			cell.btnCheck.backgroundColor = .clear
		}
		
		cell.btnCheck.addTarget(self, action: #selector(actionChecked(_ :)), for: .touchUpInside)
		cell.textCoupenCode.setNeedsLayout()
	   cell.textCoupenCode.layoutIfNeeded()
	   cell.layoutIfNeeded()
		cell.textCoupenCode.layer.addSublayer(cell.textCoupenCode.AddDashedborderTov())
		return cell
	}/*
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? CoupenCodeTVC
		{
			cell.textCoupenCode.layer.addSublayer(cell.textCoupenCode.AddDashedborderTov())
		}
	}*/
	@objc func actionChecked(_ sender : UIButton)
	{
		let currIndex = sender.tag
		selectedIndex = currIndex
		
			
		
		
        for index in 0..<coupensAry.count
		{
			if index != currIndex
			{
				if tableView.indexPathsForVisibleRows?.contains( IndexPath(row: index, section: 0)) ?? false
				{
					if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CoupenCodeTVC
					{
						cell.btnCheck.isSelected = false
						cell.btnCheck.backgroundColor = .clear
					}
				}
			}
		}
        
        if coupensAry[currIndex].discountPercentage ?? 0 > 0
        {
            let cell = tableView.cellForRow(at: IndexPath(row: currIndex, section: 0)) as? CoupenCodeTVC
            
            if (cell?.btnCheck.isSelected)! {
                let discountAmt = (TotalAmt * (coupensAry[currIndex].discountPercentage ?? 0)) / 100
                self.lblAmmount.text = "Maximum Saving : \n\(Currency)\(discountAmt)"
            } else {
                self.lblAmmount.text = ""
            }
        }else{
            self.lblAmmount.text = ""
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: currIndex, section: 0)) as? CoupenCodeTVC
        {
            if (cell.btnCheck.isSelected) {
                self.textCouponCode.text =  cell.textCoupenCode.text
             }else {
                self.textCouponCode.text =  ""
            }
        }
        
		if textCouponCode.text?.count ?? 0 > 2
		{
			UIView.animate(withDuration: 0.5, animations: {
				self.bottomViewHeight.constant = 75
				self.view.layoutIfNeeded()
                
			}	)
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }    )
        }
	}
}
