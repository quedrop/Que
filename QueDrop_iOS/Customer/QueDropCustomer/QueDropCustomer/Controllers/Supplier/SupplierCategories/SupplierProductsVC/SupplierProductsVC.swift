//
//  SupplierProductsVC.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductsVC: SupplierBaseViewController {
    
    let searchBarHeight: CGFloat = 50
    @IBOutlet weak var contraintSearchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSearchBarContainer: UIView!
    @IBOutlet weak var viewIconContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var searchBar: SearchBarTheme!
    
    var callbackForLatestDetails: ((ProductInfo)->())?
    var category: FoodCategory?
    var arrOfProducts: [ProductInfo] = []
    
    var lastSearch = ""
    var isLoadMore = true
    var pageNumOffset = 1
    
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
        
        lblCategoryName.text = category?.storeCategoryTitle
        
        isSearchBarVisible = false
        setupCollectionView(collectionView: collectionView)
        setupSearchBar(searchBar: searchBar, delegate: self)
        pullrefreshCallback()
        
    }
    
    
    @IBAction func btnSearchClick(_ sender: Any) {
        searchBar.text = ""
        isSearchBarVisible = !isSearchBarVisible
        searchBar(text: "")
    }
    
    @IBAction func btnAddClick(_ sender: Any) {
        openSupplierProductDetailsVC(type: .add, product: nil)
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    func setupCollectionView(collectionView: UICollectionView) {
        
        setupPullRefresh(collView: collectionView, delegate: self)
        collectionView.register("ProductCVC")
        
        collectionView.keyboardDismissMode = .onDrag
        collectionView.isScrollEnabled = true
        collectionView.bounces = true
        collectionView.allowsSelection = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .tableViewBg
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }
    
    func openSupplierProductDetailsVC(type: Enum_ItemEditingType, product: ProductInfo?) {
        if product?.storeCategoryId == nil {
            product?.storeCategoryId = category?.storeCategoryId
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierProductDetailsVC") as! SupplierProductDetailsVC
        vc.editingType = type
        vc.product = product
        vc.category = category
        
        vc.callbackForLatestDetails = { product in
            switch type {
            case .add:
                self.arrOfProducts.append(product)
                break
                
            case .edit, .show:
                for i in 0..<self.arrOfProducts.count {
                    let item = self.arrOfProducts[i]
                    if item.productId == product.productId {
                        self.arrOfProducts[i] = product
                        break
                    }
                }
                break
            }
            self.collectionView.reloadData()
        }
        pushVC(vc)
    }
    
}


extension SupplierProductsVC: PullToRefreshDelegate, SearchBarDelegate, EditDeleteDelegate {
    
    func editCallback(item: Any?) {
        if let product = item as? ProductInfo {
            openSupplierProductDetailsVC(type: .edit, product: product)
        }
    }
    
    func deleteCallbackForOpenDeleteAlert() {
        openDeleteConfirmationAlert(message: "Are you sure? you want to delete this product")
    }
    
    func deleteConfirmCallback(item: Any?) {
        if let products = item as? ProductInfo, let productId = products.productId {
            API_SupplierProduct.shared.callDeleteProductApi(
                productId: productId,
                responseData: { isDone, message in
                    if isDone {
                        self.arrOfProducts = self.arrOfProducts.filter { return !($0.productId.asInt() == productId) }
                        self.collectionView.reloadData()
                    }
                    self.showAlert(title: isDone ? "" : "Alert", message: message)
            })
        }
    }
    
    func dismissCallback() {
        
    }
    
    func pullrefreshCallback() {
        searchBar(text: lastSearch)
    }
    
    func searchBar(text: String) {
        if arrOfProducts.count == 0 || !lastSearch.lowercased().elementsEqual(text.lowercased().trimmingCharacters(in: .whitespaces)) {
            arrOfProducts.removeAll()
            collectionView.reloadData()
            pageNumOffset = 1
            lastSearch = text.trimmingCharacters(in: .whitespaces)
            getProducts()
        }
    }
    
    func getProducts() {
        API_SupplierProduct.shared.getSupplierProducts(
            storeCategoryId: (category?.storeCategoryId).asInt(),
            search: lastSearch,
            offset: pageNumOffset,
            responseData: { list, loadMore in
                self.isLoadMore = loadMore
                
                if self.pageNumOffset == 1 {
                    self.arrOfProducts.removeAll()
                }
                self.arrOfProducts.append(contentsOf: list)
                
                if loadMore {
                    self.pageNumOffset += 1
                }
                self.collectionView.reloadData()
        },
            errorData: { isDone, message in
                self.listMessage = message
                self.collectionView.reloadData()
        })
    }
}

//MARK: - UICollectionView Delegate Methods
extension SupplierProductsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let currentRow = indexPath.row
        let count = arrOfProducts.count
        
        let isLastCell = count - currentRow == 1
        let minY = collectionView.contentOffset.y
        
        if isLoadMore && isLastCell && minY > 0 {
            isLoadMore = false
            getProducts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (collectionView.frame.width / 2) - 23
        let height: CGFloat = width * 1.2
        
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.setRows(arrOfProducts, noDataTitle: listMessage, message: "")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let product = arrOfProducts[index]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCVC", for: indexPath) as! ProductCVC
        cell.bindDetails(ofProduct: product)
        
        cell.callbackForBtnOptionClick = {
            self.openEditDeleteAlert(toView: cell.btnOption, item: product, delegate: self)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let product = arrOfProducts[index]
        openSupplierProductDetailsVC(type: .show, product: product)
    }
}
