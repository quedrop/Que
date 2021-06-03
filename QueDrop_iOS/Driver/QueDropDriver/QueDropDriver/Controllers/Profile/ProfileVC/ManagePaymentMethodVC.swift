//
//  ManagePaymentMethodVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 16/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class ManagePaymentMethodVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    var arrOfPaymentType: [BankDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isViewLoadFirstTime {
            pullrefreshCallback()
        }
        
        isViewLoadFirstTime = false
    }
    
    func setupUI() {
        view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Payment Methods"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierBankDetailTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BaseTableViewCell")
        setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 0, footHeight: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ManagePaymentMethodVC: PullToRefreshDelegate {
    
    func pullrefreshCallback() {
        getBankDetailsList()
    }
    
    func getBankDetailsList() {
        getBankDetails()
    }
}
// MARK: - UITABLEVIEW DATASOURCE AND DELEGATE
extension ManagePaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfPaymentType.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var index = indexPath.row
        
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            
            cell.imageView?.image = nil
            cell.textLabel?.text = nil
            
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "Add new bank account or import your details"
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font =  UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
            
            return cell
            
        } else if index == arrOfPaymentType.count + 1 {
            let image = UIImage(named: "add_circle")
            let title = "Add bank account".uppercased()
            let textColor: UIColor = #colorLiteral(red: 0, green: 0.5137254902, blue: 0.9764705882, alpha: 1)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            
            cell.imageView?.image = nil
            cell.textLabel?.text = nil
            
            cell.selectionStyle = .none
            
            cell.textLabel?.numberOfLines = 0
            cell.imageView?.image = image
            cell.textLabel?.text = title
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 18.0))//UIFont.systemFont(ofSize: 19, weight: .medium).getAppFont()
            
            return cell
            
        }else {
            index = indexPath.row - 1
            let bank = arrOfPaymentType[index]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierBankDetailTVC") as! SupplierBankDetailTVC
            cell.bindDetails(ofBank: bank)
            cell.callbackForIsPrimary = {
                tableView.reloadData()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let isAdd = index == arrOfPaymentType.count + 1
        
        if index > 0 {
            let vc = HomeStoryboard.instantiateViewController(withIdentifier: "AddPaymentMethodVC") as! AddPaymentMethodVC
            if !isAdd {
                let bank = arrOfPaymentType[index - 1]
                vc.bankObj = bank
            }
            vc.callbackForLatestDetails = { details in
                if details.isPrimary.asInt() == 1 {
                    for i in 0..<self.arrOfPaymentType.count {
                        self.arrOfPaymentType[i].isPrimary = 0
                    }
                }
                
                if isAdd {
                    self.arrOfPaymentType.append(details)
                } else {
                    for i in 0..<self.arrOfPaymentType.count {
                        let item = self.arrOfPaymentType[i]
                        if item.bankDetailId == details.bankDetailId {
                            self.arrOfPaymentType[i] = details
                            break
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == arrOfPaymentType.count + 1 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this deatil?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes, Delete", style: .destructive, handler: { (action) in
                let obj = self.arrOfPaymentType[indexPath.row - 1]
                self.deleteBankDetails(bankDetailId: obj.bankDetailId!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
    }
    
}
