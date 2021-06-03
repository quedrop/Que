//
//  SupplierOfferVC.swift
//  QueDrop
//
//  Created by C100-105 on 30/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOfferVC: SupplierBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAddOffer: UIButton!
    
    var arrOfOffer: [SupplierOffer] = []
    var pageNumOffset = 1
    var isLoadMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(tableView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if arrOfOffer.count == 0 {
            pullrefreshCallback()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
        
    @IBAction func btnAddOfferClick(_ sender: Any) {
        if (USER_OBJ?.storeId).asInt() == 0 {
            ShowToast(message: "There is no store assigned you yet. You can't create offers now.");
            return
        }
        openOfferDetailsVC(type: .add, offer: nil)
    }
    
    func setupTableView(tableView: UITableView) {
        
        setupPullRefresh(tblView: tableView, delegate: self)
        tableView.register("SupllierOfferTVC")
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 5, footHeight: 60)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .tableViewBg
    }
    
    func openOfferDetailsVC(type: Enum_ItemEditingType, offer: SupplierOffer?) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierOfferDetailsVC") as! SupplierOfferDetailsVC
        vc.editingType = type
        vc.offer = offer
        
        vc.callbackForLatestDetails = { offer in
            switch type {
            case .add:
                self.arrOfOffer.append(offer)
                break
                
            case .edit, .show:
                for i in 0..<self.arrOfOffer.count {
                    let item = self.arrOfOffer[i]
                    if item.productOfferId == offer.productOfferId {
                        self.arrOfOffer[i] = offer
                        break
                    }
                }
                break
            }
            self.tableView.reloadData()
        }
        pushVC(vc)
    }
    
}

extension SupplierOfferVC: PullToRefreshDelegate, EditDeleteDelegate {
    
    func editCallback(item: Any?) {
        if let offer = item as? SupplierOffer {
            openOfferDetailsVC(type: .edit, offer: offer)
        }
    }
    
    func deleteCallbackForOpenDeleteAlert() {
        openDeleteConfirmationAlert(message: "Are you sure you want to delete this offer?")
    }
    
    func deleteConfirmCallback(item: Any?) {
        if let offer = item as? SupplierOffer, let productOfferId = offer.productOfferId {

            API_SupplierOffer.shared.callDeleteCategoryApi(
                productOfferId: productOfferId,
                responseData: { isDone, message in
                    if isDone {
                        self.arrOfOffer = self.arrOfOffer.filter { return !($0.productOfferId == productOfferId) }
                        self.tableView.reloadData()
                    }
                    self.showAlert(title: isDone ? "" : "Alert", message: message)
            })
        }
    }
    
    func dismissCallback() {
        
    }
    
    func pullrefreshCallback() {
        arrOfOffer.removeAll()
        tableView.reloadData()
        pageNumOffset = 1
        
        getOffer()
    }
    
    func getOffer() {
        API_SupplierOffer.shared.getSupplierOffers(
            responseData: { list, load_more in
                self.arrOfOffer = list
                self.tableView.reloadData()
        },
            errorData: { isDone, message in
                self.listMessage = message
                self.tableView.reloadData()
        })
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierOfferVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.setRows(arrOfOffer, noDataTitle: listMessage, message: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let offer = arrOfOffer[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupllierOfferTVC") as! SupllierOfferTVC
        cell.bindDetails(ofOffer: offer)
        
        cell.callbackForBtnOptionClick = {
            self.openEditDeleteAlert(toView: cell.btnOption, item: offer, delegate: self)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        let count = arrOfOffer.count
        
        let isLastCell = count - currentRow == 1
        let minY = tableView.contentOffset.y
        
        if isLoadMore && isLastCell && minY > 0 {
            //getOffer()
            isLoadMore = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let offer = arrOfOffer[indexPath.row]
        openOfferDetailsVC(type: .show, offer: offer)
    }
    
}
