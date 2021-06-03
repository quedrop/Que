//
//  SupplierManagePaymentMethodVC.swift
//  QueDrop
//
//  Created by C100-105 on 14/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierManagePaymentMethodVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    var arrOfPaymentType: [SupplierBankDetails] = []
    
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
        view.backgroundColor = VIEW_BG_COLOR //.white
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierBankDetailTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "BaseTableViewCell")
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
        popVC()
    }
    
}

extension SupplierManagePaymentMethodVC: PullToRefreshDelegate {
    
    func pullrefreshCallback() {
        getBankDetailsList()
    }
    
    func getBankDetailsList() {
        API_SupplierProfile.shared.getSupplierPayments(
            responseData: { list, _ in
                self.arrOfPaymentType = list
                self.tableView.reloadData()
        },
            errorData: { isDone, message in
                self.listMessage = message
                self.tableView.reloadData()
        })
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierManagePaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfPaymentType.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var index = indexPath.row
        
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as! BaseTableViewCell
            cell.setupUI()
            
            cell.textLabel?.text = "Add new bank account or import your details"
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 19).getAppFont()
            
            return cell
            
        } else if index == arrOfPaymentType.count + 1 {
            let image = #imageLiteral(resourceName: "supplier_add_circle")
            let title = "Add bank account".uppercased()
            let textColor: UIColor = #colorLiteral(red: 0, green: 0.5137254902, blue: 0.9764705882, alpha: 1)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath) as! BaseTableViewCell
            cell.setupUI()
            
            cell.textLabel?.numberOfLines = 0
            cell.imageView?.image = image
            cell.textLabel?.text = title
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 19, weight: .medium).getAppFont()
            
            return cell
            
        }
//        else if index == arrOfBanks.count + 2 {
//            let image = #imageLiteral(resourceName: "supplier_add_circle")
//            let title = "Add bank account".uppercased()
//            let textColor: UIColor = #colorLiteral(red: 0, green: 0.5137254902, blue: 0.9764705882, alpha: 1)
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierBankDetailTVC", for: indexPath) as! SupplierBankDetailTVC
//            cell.setupUI()
//
//            cell.imgIcon.showBorder(.clear, 0)
//            cell.imgIcon.contentMode = .scaleAspectFit
//            cell.imgIcon.image = image
//            cell.lblTitle.textColor = textColor
//            cell.lblTitle.text = title
//            cell.btnIsPrimary.isHidden = true
//            cell.lblCardNo.isHidden = true
//
//            return cell
//        }
        
        index = indexPath.row - 1
        let bank = arrOfPaymentType[index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierBankDetailTVC", for: indexPath) as! SupplierBankDetailTVC
        cell.bindDetails(ofBank: bank)
        cell.callbackForIsPrimary = {
            tableView.reloadData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let isAdd = index == arrOfPaymentType.count + 1
        
        if index > 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierAddPaymentMethodVC") as! SupplierAddPaymentMethodVC
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
            pushVC(vc)
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
          self.deleteBankDetails(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
      }
    }
    func deleteBankDetails(indexPath: IndexPath) {
        let obj = self.arrOfPaymentType[indexPath.row - 1]
        API_SupplierProfile.shared.callDeletePaymentApi(
            paymentId: obj.bankDetailId.asInt(),
            responseData: { isDone, message in
                if isDone {
                    //done
                    self.tableView.beginUpdates()
                    self.arrOfPaymentType.remove(at: indexPath.row - 1)
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                } else {
                    self.showOkAlert(message)
                }
        })
    }
}
