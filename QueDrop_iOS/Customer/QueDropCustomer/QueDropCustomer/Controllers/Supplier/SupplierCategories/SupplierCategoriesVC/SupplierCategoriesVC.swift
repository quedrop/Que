//
//  CategoriesVC.swift
//  QueDrop
//
//  Created by C100-104 on 30/12/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit

class SupplierCategoriesVC: SupplierBaseViewController {
    
    let searchBarHeight: CGFloat = 50
    @IBOutlet weak var contraintSearchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSearchBarContainer: UIView!
    @IBOutlet weak var viewIconContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnAddCategory: UIButton!
    
    @IBOutlet weak var searchBar: SearchBarTheme!
    @IBOutlet weak var segmentCategory: UISegmentedControl!
    
    var tableViewAlert: TableViewAlert?
    
    var selectedCategoryType = 0
    var isFirstTimeLoadSegment = [false, true]
    var arrOfCategory: [FoodCategory] = []
    var arrOfSearchCategory: [FoodCategory] = []
    var arrOfFreshProduce: [FoodCategory] = []
    var arrOfSearchFreshProduce: [FoodCategory] = []
    var arrFreshProduceCategory: [FreshProduceCategories] = []
    var arrFilteredFresshCat : [FreshProduceCategories] = []
    var isLoadMore = true
    var isSearchBarVisible: Bool = false {
        didSet {
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.contraintSearchBarHeight.constant = self.isSearchBarVisible ? self.searchBarHeight : 0
                    self.view.layoutIfNeeded()
            },
                completion: { _ in
                    self.viewSearchBarContainer.isHidden = !self.isSearchBarVisible
                    if self.isSearchBarVisible {
                        self.searchBar.becomeFirstResponder()
                    } else {
                        self.searchBar.resignFirstResponder()
                    }
            })
            
        }
    }
    
    var addCategoryVC: AddSupplierCategoryAlertVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentCategory.showBorder(.white, 10, 0.5)
        segmentCategory.setupCustomSegment()
        isSearchBarVisible = false
        setupTableView(tableView: tableView)
//        switch APP_DELEGATE.socketIOHandler?.socket?.status{
//        case .connected?:
//            break
//        default:
//             APP_DELEGATE.socketIOHandler = SocketIOHandler()
//            print("Socket Not Connected")
//            break;
//        }
        setupSearchBar(searchBar: searchBar, delegate: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        getFreshProduced()
        if arrOfCategory.count == 0 {
            pullrefreshCallback()
        }
    }
    
    func getFreshProduced() {
        API_SupplierCategory.shared.getFreshProducedCategories(responseData: { (arrFreshCat, loadMore) in
            self.arrFreshProduceCategory = arrFreshCat
        }, errorData: { (isDone, message) in
            
        })
    }
    
    @IBAction func btnSearchClick(_ sender: Any) {
        searchBar.text = ""
        isSearchBarVisible = !isSearchBarVisible
        searchBar(text: "")
    }
    
    @IBAction func btnAddCategoryClick(_ sender: Any) {
        if (USER_OBJ?.storeId).asInt() == 0 {
            ShowToast(message: "There is no store assigned you yet. You can't create category now.");
            return
        } else {
            if selectedCategoryType == 0 {
                openAddSupplierCategoryAlertVC(isEdit: false)
            } else {
                let arrId = self.arrOfFreshProduce.filter{$0.freshProduceCategoryId != 0}.map{$0.freshProduceCategoryId}
                arrFilteredFresshCat = self.arrFreshProduceCategory.filter {!arrId.contains($0.freshCategoryId)}

                openFreshProduceCategoryAlert()
            }
        }
        
    }
    
    func openFreshProduceCategoryAlert() {
        var arr: [String] = []
        var selectedIndex = -1
        for index in 0..<arrFilteredFresshCat.count {
            let obj = arrFilteredFresshCat[index]
            arr.append(obj.freshProduceTitle.asString())
            
//            if obj.freshCategoryId == bankDetails.bank?.bankId {
//                selectedIndex = index
//            }
        }
        
        openSelectionAlert(
            index: 0,
            arr: arr,
            selectedIndex: selectedIndex,
            response: { value, index in
                
                //CALL ADD API
                API_SupplierCategory.shared.callAddFreshProducedCategory(categoryId: self.arrFilteredFresshCat[index].freshCategoryId!, responseData: { (arrCat, loadnore) in
                    self.arrOfFreshProduce = arrCat
                    self.arrOfSearchFreshProduce = self.arrOfFreshProduce
                    self.tableView.reloadData()
                }) { (isDone, message) in
                    if !isDone {
                       self.showAlert(title: "Alert", message: message)
                   }
                }
        })
    }
    
    func openSelectionAlert(
        index: Int,
        arr: [String],
        selectedIndex: Int,
        response: @escaping(_ value: String, _ index: Int) -> Void) {
        
        if self.tableViewAlert != nil {
            self.tableViewAlert?.view.removeFromSuperview()
            self.tableViewAlert = nil
        }
        
        let cellSize: CGFloat = 50
        
       // let indexPath = IndexPath(row: index, section: 0)
      //  let cell = tableView.cellForRow(at: indexPath) as! SupplierCategoryCell
        
        let rows = CGFloat(arr.count)
        var tblHeight = CGFloat(rows * cellSize)
        if rows > 5 {
            tblHeight = CGFloat(4 * cellSize)
        }
        let tblSize = CGSize(width: tableView.frame.width - 40 /*cell.viewContainer.frame.width*/, height: tblHeight)
        
      /*  var frame = tableView.getFrame(ofIndexPath: indexPath)
        var point = CGPoint.zero
        point = view.convert(frame.origin, to: view)
        point.y += cell.viewContainer.frame.height
        
        point.x = cell.viewContainer.frame.minX*/
        
        let point1 = CGPoint(x: tableView.frame.minX + 20, y: self.view.frame.size.height - btnAddCategory.frame.size.height - 40 - tblHeight)
        var frame = CGRect(origin: point1, size: tblSize)
        
        tableViewAlert = TableViewAlert()
        tableViewAlert?.cellSize = cellSize
        tableViewAlert?.showView(viewDisplay: view, frame: frame, data: arr, selectedIndex: selectedIndex)
        
        tableViewAlert?.callback = response
        
        tableViewAlert?.dismissCallback = {
            self.tableViewAlert = nil
        }
    }
    
    @IBAction func segmentCategoryValueChange(_ sender: UISegmentedControl) {
        searchBar.text = ""
        isSearchBarVisible = false
        searchBar(text: "")
        
        segmentCategory.updateCustomSegment()
        
        selectedCategoryType = sender.selectedSegmentIndex
        
        if isFirstTimeLoadSegment[selectedCategoryType] {
            pullrefreshCallback()
            isFirstTimeLoadSegment[selectedCategoryType] = false
        } else {
            tableView.reloadData()
        }
    }
    
    
    func setupTableView(tableView: UITableView) {
        
        setupPullRefresh(tblView: tableView, delegate: self)
        tableView.register("SupplierCategoryCell")
        
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
    
    func openAddSupplierCategoryAlertVC(isEdit: Bool, category: FoodCategory? = nil) {
        addCategoryVC = AddSupplierCategoryAlertVC(nibName: "AddSupplierCategoryAlertVC", bundle: nil)
        addCategoryVC?.parentVC = self
        
        addCategoryVC?.category = category
        addCategoryVC?.showView(viewDisplay: tabBarController?.view ?? view)
        
        addCategoryVC?.callbackForData = { details in
            API_SupplierCategory.shared.callAddEditCategoryApi(
                isAdd: !isEdit,
                categoeyId: (category?.storeCategoryId).asInt(),
                categoryDetails: details,
                responseData: { category in
                    
                    self.addCategoryVC?.hideDialog()
                    
                    if isEdit {
                        
                        for i in 0..<self.arrOfCategory.count {
                            let cat = self.arrOfCategory[i]
                            if cat.storeCategoryId == category.storeCategoryId {
                                self.arrOfCategory[i] = category
                                break
                            }
                        }
                        self.searchBar(text: self.searchBar.text.asString())
                    } else {
                        self.arrOfCategory.append(category)
                        self.arrOfSearchCategory.append(category)
                    }
                    
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    if !isDone {
                        self.showAlert(title: "Alert", message: message)
                    }
            })
        }
        
        addCategoryVC?.dismissCallback = {
            self.addCategoryVC = nil
        }
        
    }
    
}

extension SupplierCategoriesVC: PullToRefreshDelegate, SearchBarDelegate, EditDeleteDelegate {
    
    func editCallback(item: Any?) {
        if let category = item as? FoodCategory {
            openAddSupplierCategoryAlertVC(isEdit: true, category: category)
        }
    }
    
    func deleteCallbackForOpenDeleteAlert() {
        openDeleteConfirmationAlert(message: "Are you sure you want to delete this category?")
    }
    
    func deleteConfirmCallback(item: Any?) {
        if let category = item as? FoodCategory, let categoryId = category.storeCategoryId {
            
            API_SupplierCategory.shared.callDeleteCategoryApi(
                categoryId: categoryId,
                responseData: { isDone, message in
                    if isDone {
                        if self.selectedCategoryType == 0 {
                            self.arrOfCategory = self.arrOfCategory.filter { return !($0.storeCategoryId == categoryId) }
                            self.arrOfSearchCategory = self.arrOfSearchCategory.filter { return !($0.storeCategoryId == categoryId) }
                        } else {
                            self.arrOfFreshProduce = self.arrOfFreshProduce.filter { return !($0.storeCategoryId == categoryId) }
                            self.arrOfSearchFreshProduce = self.arrOfSearchFreshProduce.filter { return !($0.storeCategoryId == categoryId) }
                        }
                        
                        self.tableView.reloadData()
                    }
                    self.showAlert(title: isDone ? "" : "Alert", message: message)
            })
        }
    }
    
    func dismissCallback() {
        
    }
    
    func pullrefreshCallback() {
        if selectedCategoryType == 0 {
            arrOfSearchCategory.removeAll()
            arrOfCategory.removeAll()
            tableView.reloadData()
            
            API_SupplierCategory.shared.getSupplierCategories(
                responseData: { list, loadMore in
                    self.isLoadMore = loadMore
                    self.arrOfSearchCategory = list
                    self.arrOfCategory = self.arrOfSearchCategory
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    self.listMessage = message
                    self.tableView.reloadData()
            })
        } else{
            arrOfSearchFreshProduce.removeAll()
            arrOfFreshProduce.removeAll()
            tableView.reloadData()
            
            API_SupplierCategory.shared.getSupplierFreshProduceCategories(
                responseData: { list, loadMore in
                    self.isLoadMore = loadMore
                    self.arrOfSearchFreshProduce = list
                    self.arrOfFreshProduce = self.arrOfSearchFreshProduce
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    self.listMessage = message
                    self.tableView.reloadData()
            })
        }
        
    }
    
    func searchBar(text: String) {
        if text.trimmingCharacters(in: .whitespaces).isEmpty {
            if selectedCategoryType == 0 {
                arrOfSearchCategory = arrOfCategory
            } else {
                arrOfSearchFreshProduce = arrOfFreshProduce
            }
            
        } else {
            if selectedCategoryType == 0 {
                arrOfSearchCategory = arrOfCategory.filter { return $0.storeCategoryTitle.asString().lowercased().contains(text.lowercased()) }
            }else {
                arrOfSearchFreshProduce = arrOfFreshProduce.filter { return $0.storeCategoryTitle.asString().lowercased().contains(text.lowercased()) }
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierCategoriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.setRows(selectedCategoryType == 0 ? arrOfSearchCategory : arrOfSearchFreshProduce, noDataTitle: listMessage, message: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = selectedCategoryType == 0 ? arrOfSearchCategory[indexPath.row] : arrOfSearchFreshProduce[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierCategoryCell") as! SupplierCategoryCell
        cell.bindDetails(ofCategory: category)
        
        cell.callbackForBtnOptionClick = {
            if self.selectedCategoryType == 0 {
                self.openEditDeleteAlert(toView: cell.btnOption, item: category, delegate: self)
            }else {
                self.openDeletePopoverAlert(toView: cell.btnOption, item: category, delegate: self)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        let count = selectedCategoryType == 0 ? arrOfSearchCategory.count : arrOfSearchFreshProduce.count
        
        let isLastCell = count - currentRow == 1
        let minY = tableView.contentOffset.y
        
        if isLoadMore && isLastCell && minY > 0 {
            //getSupplierCategories(storeId: 0)
            isLoadMore = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = selectedCategoryType == 0 ? arrOfSearchCategory[indexPath.row] : arrOfSearchFreshProduce[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierProductsVC") as! SupplierProductsVC
        vc.category = category
        pushVC(vc)
        
    }
    
}
