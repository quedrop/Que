//
//  SupplierOrderProductDetailVC.swift
//  QueDrop
//
//  Created by C100-105 on 04/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOrderProductDetailVC: SupplierBaseViewController {
    
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var product = SupplierProducts(json: .null)
    var arrOfData: [[String?]] = []
    
    enum Enum_ProductDetails: Int {
        case Images = 0
        case Details
        case AdOns
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    func bindDetails() {
        arrOfData.removeAll()
        
        arrOfData = [[], []]
        
        let option = product.getPurchasedOption()
        
        let titles = [
            "Product Name",
            "Quantity",
            "Price",
            "Serves"
        ]
        
        let values = [
            product.productName,
            product.quantity.asInt().description,
            Currency + " " + option.price.asFloat().description,
            option.optionName.asString(),
        ]
        
        for i in 0..<titles.count {
            arrOfData[0].append(titles[i])
            arrOfData[1].append(values[i])
        }
        
    }
    
    func setupUI() {
        bindDetails()
        
        view.backgroundColor =  .white
        setupTableView(tableView: tableView)
        
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierOrderImageTVC",
            "SupplierOrderTextDetailTVC",
            "SupplierOrderProductAddOnTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 0, footHeight: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierOrderProductDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_ProductDetails(rawValue: section) else {
            return 0
        }
        switch row {
        case .Images:
            return 1
            
        case .Details:
            return arrOfData[0].count
            
        case .AdOns:
            return (product.addons?.count).asInt()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_ProductDetails(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch row {
        case .Images:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderImageTVC", for: indexPath) as! SupplierOrderImageTVC
            cell.bindDetail(ofProduct: product)
            
            cell.lblName.isHidden = true
            cell.lblQty.isHidden = true
            
            return cell
            
        case .Details:
            return getTextDetailCell(indexPath: indexPath)
            
        case .AdOns:
            guard let addons = product.addons else {
                return UITableViewCell()
            }
            let index = indexPath.row
            
            let addOnCount = addons.count
            let isFirst = index == 0
            let isLast = index == (addOnCount-1)
            
            let addon = addons[index]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderProductAddOnTVC", for: indexPath) as! SupplierOrderProductAddOnTVC
            cell.bindDetail(ofAddOn: addon)
            
            cell.lblAddOn.isHidden = !isFirst
            cell.lblLine.isHidden = !isLast
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getTextDetailCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierOrderTextDetailTVC", for: indexPath) as! SupplierOrderTextDetailTVC
        cell.setupUI()
        
        let left: (String?, String?) = (arrOfData[0][indexPath.row], arrOfData[1][indexPath.row])
        cell.lblLeftTitle.text = left.0
        cell.lblLeftValue.text = left.1
        
        let traillingSpace: CGFloat = 5
        cell.constraintLeftBorderTrailling.constant = traillingSpace
        cell.constraintRightBorderTrailling.constant = traillingSpace
        
        return cell
    }
    
}
