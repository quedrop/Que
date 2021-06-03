//
//  CustomerSupportVC.swift
//  QueDrop
//
//  Created by C205 on 08/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class CustomerSupportVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    enum enumCustomerSuppport : Int {
        case orderId = 0
        case orderDetails
        case problem
    }
    enum textType {
        case storeName
        case productName
        case productAddOns
    }
    //var
    var orderId = 0
    var orderDetails : OrderDetails? = nil
    var combination = NSMutableAttributedString()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate =   self
        tableView.dataSource = self
        getOrderDetails(of: orderId)
    }
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionSubmitQuery(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: enumCustomerSuppport.problem.rawValue, section: 0)) as! InfoTVCell
        let problemText = cell.textView.text
        if problemText!.isEmpty || problemText?.length ?? 0 < 5
        {
            ShowToast(message: "Problem sentence is Too short.")
        }
        else
        {
            submitQuery(Customer: problemText ?? "")
        }
        
    }
    func setOrderId(orderId : Int){
        self.orderId = orderId
    }
    func setUpDetails()
    {
        combination = NSMutableAttributedString()
                  
                  
        
        if let details = orderDetails
        {
            
            for store in details.stores!
            {
                combination.append(getFormatedString(text: store.storeName ?? "", for: .storeName))
                for product in store.products!
                {
                    combination.append(getFormatedString(text: product.productName ?? "" , for: .productName))
                    if product.addons?.count ?? 0 > 0 || product.productOption?.count ?? 1 > 1
                    {
                        var addon : [String] = []
                        if let addOns = product.addons
                        {
                            for item in addOns
                            {
                                addon.append(item.addonName ?? "")
                            }
                        }
                        if let options = product.productOption
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
                        }
                        if addon.count == 0
                        {
                             combination.append(getFormatedString(text: "Regular", for: .productAddOns))
                        }
                        else
                        {
                            combination.append(getFormatedString(text: addon.joined(separator: ", "), for: .productAddOns))
                        }
                    }
                    else
                    {
                       combination.append(getFormatedString(text: "Regular", for: .productAddOns))
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    func getFormatedString( text : String , for type : textType) -> NSMutableAttributedString
    {
        switch type{
        case .storeName :
            let attributedText = NSMutableAttributedString(string: "\(text)\n")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_BOLD, size: 18.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attributedText.length))
            return attributedText
        case .productName:
            let attributedText = NSMutableAttributedString(string: "\(text)\n")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_MEDIUM, size: 16.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: NSMakeRange(0, attributedText.length))
            return attributedText
        case .productAddOns:
            let attributedText = NSMutableAttributedString(string: "\(text)\n")
            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fFONT_REGULAR, size: 14.0)!, range: NSMakeRange(0, attributedText.length))
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, attributedText.length))
            return attributedText
        }
    }

}
extension CustomerSupportVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails != nil ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row
        {
        case enumCustomerSuppport.orderId.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NameTVCell", for: indexPath) as! NameTVCell
            cell.textField.text = "#\(orderDetails?.orderId ?? 0)"
            cell.textField.setLeftRightPadding(15.0)
            cell.textField.isUserInteractionEnabled = false
            cell.selectionStyle = .none
            return cell
            
        case enumCustomerSuppport.orderDetails.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSupportOrderDetailsTVCell", for: indexPath) as! CustomerSupportOrderDetailsTVCell
            cell.lblOrderDetails.attributedText = combination
            
            cell.selectionStyle = .none
            return cell
        case enumCustomerSuppport.problem.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTVCell", for: indexPath) as! InfoTVCell
            //cell.textView.text = ""
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}


