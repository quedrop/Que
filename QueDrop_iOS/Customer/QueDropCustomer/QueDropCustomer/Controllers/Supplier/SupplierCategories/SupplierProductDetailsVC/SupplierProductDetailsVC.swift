//
//  SupplierProductDetailsVC.swift
//  QueDrop
//
//  Created by C100-105 on 01/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierProductDetailsVC: SupplierBaseViewController {

    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var callbackForLatestDetails: ((ProductInfo)->())?
    var editingType = Enum_ItemEditingType.show
    
    var productDetails = Struct_ProductDetails()
    var product: ProductInfo?
    var category: FoodCategory?
    
    enum Enum_ProductDetails_Section: Int {
        case Images = 0
        case InputDetails
        case PriceOptions
        case AddOns
        case ExtraFreeTag
        case ActiveStatus
    }
    
    let txtArr: [String] = ["Product Name", "Additional Info"]
    
    
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
    
    @IBAction func btnEditClick(_ sender: Any) {
        switch editingType {
        case .add, .edit:
            API_SupplierProduct.shared.callAddEditProductApi(
                isAdd: editingType == .add,
                productId: (product?.productId).asInt(),
                storeCategoryId: (category?.storeCategoryId).asInt(),
                andDetail: productDetails,
                responseData: { product in
                    self.callbackForLatestDetails?(product)
                    self.product = product
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    self.showOkAlert(message: message) {
                        if isDone {
                            self.popVC()
                        }
                    }
            })
            break
            
        case .show:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierProductDetailsVC") as! SupplierProductDetailsVC
            vc.editingType = .edit
            vc.product = product
            vc.category = category
            
            vc.callbackForLatestDetails = { product in
                self.product = product
                self.bindDbDetails()
                self.callbackForLatestDetails?(product)
            }
            pushVC(vc)
            break
        }
    }
    
    func setupUI() {
        bindDbDetails()
        
//        var textColor = UIColor.black
//        var backImage = #imageLiteral(resourceName: "left_arrow")
        
        var btnTitle = ""
        switch editingType {
        case .add:
            btnTitle = "Add"
            
        case .edit:
            btnTitle = "Save"
            
        case .show:
//            textColor = UIColor.white
//            backImage = #imageLiteral(resourceName: "back_white")
            btnTitle = "Edit"
        }
        
       // lblNavTitle.textColor = textColor
        //btnBack.setImage(backImage, for: .normal)
       // btnBack.setImage(setImageTintColor(image: UIImage(named: "left_arrow"), color: .black), for: .normal)
        let attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnEdit.setTitle(nil, for: .normal)
        btnEdit.setAttributedTitle(attrTitle, for: .normal)
        
        btnEdit.backgroundColor = .appColor
        btnEdit.showBorder(.clear, 10)
        
        view.backgroundColor = .tableViewBg
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierImageScrollingCell",
            "SupplierTextFieldCell",
            "SupplierTextViewCell",
            "SupplierProductAddImageTVC",
            "SupplierAddOnTVC",
            "SupplierInsertAddOnTVC",
            "SupplierPriceOptionsTVC",
            "TableViewCheckBoxCell",
            "SupplierProductActiveStatusTVC"
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
        
        tableView.contentInsetAdjustmentBehavior = .never
        
        let isEditing = editingType != .show
        
        let topSpacing: CGFloat = isEditing ? ((deviceHasNotch() ? 44 : 0) + 44) : 0
        tableView.setHeaderFootertView(headHeight: 0, footHeight: 15)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    func bindDbDetails() {
        guard let product = product else {
            productDetails = Struct_ProductDetails()
            productDetails.priceOptions.append(Struct_AddPriceOptionsDetails(id: nil, name: "Default", price: 0))
            //productDetails.addOns.append(Struct_AddAddOnDetails(id: nil, name: "", price: 0))
            return
        }
        
        productDetails = Struct_ProductDetails()
        
        productDetails.name = product.productName.asString()
        productDetails.extraFeeTag = product.needExtraFees.asInt() == 1
        productDetails.isActive = product.isActive.asInt() == 1
        productDetails.descriptionText = product.productDescription.asString()
        
        if let addons = product.addons {
            productDetails.addOns = addons.map { val in
                return Struct_AddAddOnDetails(id: val.addonId, name: val.addonName.asString(), price: val.addonPrice.asFloat())
            }
        }
        
        if let productOption = product.productOption {
            var index = 0
            productDetails.priceOptions = productOption.map { val in
                if val.isDefault.asInt() == 1 {
                    productDetails.defaultPriceOptionIndex = index
                }
                index += 0
                return Struct_AddPriceOptionsDetails(id: val.optionId, name: val.optionName.asString(), price: val.price.asFloat())
            }
        }
        
    }
    
    override func didFinishPickingMedia(selectedImage image: UIImage?) {
        productDetails.image = image
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierProductDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Enum_ProductDetails_Section(rawValue: indexPath.section) else { return 0 }
        
        switch row {
        case .Images:
            return tableView.frame.width / 1.5
            
        default:
            break
        }
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_ProductDetails_Section(rawValue: section) else { return 0 }
        
        switch row {
        case .InputDetails:
            return txtArr.count
            
        case .PriceOptions:
            return productDetails.priceOptions.count + 1
            
        case .AddOns:
            return productDetails.addOns.count + 1
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_ProductDetails_Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        var index = indexPath.row
        let isEditing = editingType != .show
        
        switch row {
        case .Images:
            let url = URL_PRODUCT_IMAGES + (product?.productImage).asString()

            if !isEditing {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierImageScrollingCell", for: indexPath) as! SupplierImageScrollingCell
                cell.bindDetails(ofURLs: [url])
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProductAddImageTVC", for: indexPath) as! SupplierProductAddImageTVC
                cell.setupUI()
                
                cell.imgView.isUserInteractionEnabled = isEditing
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(openImagePickerClick))
                cell.imgView.addGestureRecognizer(tap)
                cell.imgView.contentMode = .scaleAspectFill
                cell.imgView.clipsToBounds = true
                
                if editingType == .edit {
                    
                    cell.imgView.setWebImage(url, .noImagePlaceHolder)
                    
                } else if let image = productDetails.image {
                    cell.imgView.image = image
                    
                } else {
                    
                    cell.imgView.image = #imageLiteral(resourceName: "add_picture")
                }
                return cell
            }
            
        case .InputDetails:
            let title = txtArr[index]
            if index == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextViewCell", for: indexPath) as! SupplierTextViewCell
                
                cell.txtBox.isEditable = isEditing
                cell.txtBox.tag = index
                cell.txtBox.delegate = self
                
                cell.bindDetails(title: title)
                cell.txtBox.text = productDetails.descriptionText
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextFieldCell", for: indexPath) as! SupplierTextFieldCell
                cell.txtValue.isEnabled = isEditing
                cell.txtValue.tag = index
                cell.txtValue.delegate = self
                cell.txtValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
                
                cell.bindDetails(title: title)
                cell.txtValue.text = productDetails.name
                
                return cell
            }
            
        case .ExtraFreeTag:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCheckBoxCell", for: indexPath) as! TableViewCheckBoxCell
            cell.bindDetails(title: "Extra Fee Tag", isSelected: productDetails.extraFeeTag)
            cell.callbackForSelection = {
                self.productDetails.extraFeeTag = !self.productDetails.extraFeeTag
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            cell.btnCheckBox.isUserInteractionEnabled = isEditing
            return cell
            
        case .ActiveStatus:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProductActiveStatusTVC", for: indexPath) as! SupplierProductActiveStatusTVC
            cell.bindDetails(title: "Active Status", isSelected: productDetails.isActive)
            cell.callbackForSelection = {
                self.productDetails.isActive = !self.productDetails.isActive
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            cell.switchActive.isUserInteractionEnabled = isEditing
            return cell

        case .AddOns:
            if index == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierInsertAddOnTVC", for: indexPath) as! SupplierInsertAddOnTVC
                
                cell.bindDetails(title: isEditing ? "Add Addons" : "Addons")
                cell.btnAdd.isHidden = !isEditing
                
                cell.callbackFornsertAddon = {
                    self.productDetails.addOns.append(Struct_AddAddOnDetails())
                    self.tableView.reloadData()
                }
                return cell
            }
            
            index = index - 1
            let addon = productDetails.addOns[index]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierAddOnTVC", for: indexPath) as! SupplierAddOnTVC
            cell.bindDetails(ofAddOn: addon, isEdit: isEditing)
            
            cell.btnDelete.isHidden = !isEditing
            cell.txtName.isEnabled = isEditing
            cell.txtPrice.isEnabled = isEditing
            
            cell.txtName.tag = index
            cell.txtPrice.tag = index
            
            cell.txtName.addTarget(self, action: #selector(addOnNameTextFieldValueChange(_:)), for: .editingChanged)
            cell.txtPrice.addTarget(self, action: #selector(addOnPriceTextFieldValueChange(_:)), for: .editingChanged)
            
            cell.callbackForDelete = {
                if self.editingType == .edit, let id = addon.id {
                    self.productDetails.addOnsDeleted.append(id)
                }
                self.productDetails.addOns.remove(at: index)
                self.tableView.reloadData()
            }
            
            return cell
            
        case .PriceOptions:
            if index == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierInsertAddOnTVC", for: indexPath) as! SupplierInsertAddOnTVC
                cell.bindDetails(title: isEditing ? "Add Price" : "Price")
                
                cell.btnAdd.isHidden = !isEditing
                
                cell.callbackFornsertAddon = {
                    var detail = Struct_AddPriceOptionsDetails()
                    if self.productDetails.priceOptions.count == 0 {
                        detail = Struct_AddPriceOptionsDetails(id: nil, name: "Default", price: 0)
                        self.productDetails.defaultPriceOptionIndex = 0
                    }
                    self.productDetails.priceOptions.append(detail)
                    self.tableView.reloadData()
                }
                return cell
            }
            
            index = index - 1
            let priceOption = productDetails.priceOptions[index]
            let isDefault = productDetails.defaultPriceOptionIndex == index
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierPriceOptionsTVC", for: indexPath) as! SupplierPriceOptionsTVC
            cell.bindDetails(ofPriceOption: priceOption, isDefault: isDefault, isEdit: isEditing)
            
            cell.btnIsDefault.isUserInteractionEnabled = isEditing
            cell.btnDelete.isHidden = !isEditing
            cell.txtName.isEnabled = isEditing
            cell.txtPrice.isEnabled = isEditing
            
            cell.txtName.tag = index
            cell.txtPrice.tag = index
            
            cell.txtName.addTarget(self, action: #selector(priceOptionsNameTextFieldValueChange(_:)), for: .editingChanged)
            cell.txtPrice.addTarget(self, action: #selector(priceOptionsPriceTextFieldValueChange(_:)), for: .editingChanged)
            
            cell.callbackForIsDefault = {
                self.productDetails.defaultPriceOptionIndex = index
                self.tableView.reloadData()
             }
            
            cell.callbackForDelete = {
                if self.editingType == .edit, let id = priceOption.id {
                    self.productDetails.priceOptionsDeleted.append(id)
                }
                if isDefault {
                    self.productDetails.defaultPriceOptionIndex = 0
                }
                self.productDetails.priceOptions.remove(at: index)
                self.tableView.reloadData()
            }
            
            return cell
        }
    }
}

extension SupplierProductDetailsVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let txtValue = textView.text.asString()
        productDetails.descriptionText = txtValue
    }
    
    @objc func textFieldValueChange(_ txt: UITextField) {
        let txtValue = txt.text.asString()
        productDetails.name = txtValue
    }
    
    @objc func addOnNameTextFieldValueChange(_ txt: UITextField) {
        let index = txt.tag
        let txtValue = txt.text.asString()
        
        productDetails.addOns[index].name = txtValue
    }
    
    @objc func addOnPriceTextFieldValueChange(_ txt: UITextField) {
        let index = txt.tag
        let txtValue = txt.text.asString()
        
        if let price = Float(txtValue) {
            productDetails.addOns[index].price = price
        } else {
            productDetails.addOns[index].price = 0
        }
    }
    
    @objc func priceOptionsNameTextFieldValueChange(_ txt: UITextField) {
        let index = txt.tag
        let txtValue = txt.text.asString()
        
        productDetails.priceOptions[index].name = txtValue
    }
    
    @objc func priceOptionsPriceTextFieldValueChange(_ txt: UITextField) {
        let index = txt.tag
        let txtValue = txt.text.asString()
        
        if let price = Float(txtValue) {
            productDetails.priceOptions[index].price = price
        } else {
            productDetails.priceOptions[index].price = 0
        }
    }
}
