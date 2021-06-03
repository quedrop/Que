//
//  SupplierOfferDetailsVC.swift
//  QueDrop
//
//  Created by C100-105 on 06/04/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class SupplierOfferDetailsVC: SupplierBaseViewController {
    
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewAlert: TableViewAlert?
    var datePickerVC: SupplierOfferDateTimeSelectionVC?
    
    var arrOfCategory: [FoodCategory] = []
    var arrOfProducts: [ProductInfo] = []
    
    var callbackForLatestDetails: ((SupplierOffer)->())?
    var editingType = Enum_ItemEditingType.show
    var isEditingDetails = false
    
    var offerDetails = Struct_OfferDetails()
    var offer: SupplierOffer?
    
    var isNeedToOpenCategoryAlert = false
    var isNeedToOpenProductAlert = false
    
    enum Enum_OfferDetails_Section: Int {
        case Image = 0
        case InputDetails
        case Descrition
        case ActiveStatus
    }
    
    let txtArr: [String] = [
        "Select Category",
        "Select Product",
        "Offer Percentage (%)",
       // "Offer Code",
        "Offer Start date",
        "Offer Expiration date"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEditingDetails = editingType != .show
        setupUI()
        if arrOfCategory.count == 0 {
            getCategories()
        }
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
            API_SupplierOffer.shared.callAddEditOfferApi(
                isAdd: editingType == .add,
                productOfferId: (offer?.productOfferId).asInt(),
                offerDetails: offerDetails,
                responseData: { offer in
                    self.callbackForLatestDetails?(offer)
                    self.offer = offer
                    self.tableView.reloadData()
            },
                errorData: { isDone, message in
                    self.showOkAlert(message) {
                        if isDone {
                            self.popVC()
                        }
                    }
            })
            break
            
        case .show:
            let vc = storyboard?.instantiateViewController(withIdentifier: "SupplierOfferDetailsVC") as! SupplierOfferDetailsVC
            vc.editingType = .edit
            vc.offer = offer
            vc.arrOfCategory = arrOfCategory
            
            vc.callbackForLatestDetails = { offer in
                self.offer = offer
                self.bindDbDetails()
                self.callbackForLatestDetails?(offer)
            }
            pushVC(vc)
            break
        }
    }
    
    func setupUI() {
        bindDbDetails()
        
        let textColor = UIColor.black
        let backImage = #imageLiteral(resourceName: "left_arrow")
        
        var btnTitle = ""
        switch editingType {
        case .add:
            btnTitle = "Add"
            
        case .edit:
            btnTitle = "Save"
            
        case .show:
            //textColor = UIColor.white
            //backImage = #imageLiteral(resourceName: "back_white")
            btnTitle = "Edit"
        }
        
        lblNavTitle.textColor = .white//textColor
        btnBack.setImage(backImage, for: .normal)
        
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
            "SupplierTextFieldCell",
            "SupplierTextViewCell",
            "SupplierProductAddImageTVC",
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
        
        //tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.setHeaderFootertView(headHeight: 15, footHeight: 15)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    func bindDbDetails() {
        guard let offer = offer else {
            offerDetails = Struct_OfferDetails()
            return
        }
        
        offerDetails = Struct_OfferDetails()
        
        offerDetails.additionalInfo = offer.additionalInfo.asString()
        offerDetails.code = offer.offerCode.asString()
        offerDetails.percentage = offer.offerPercentage.asInt()
        offerDetails.isActive = offer.isActive.asInt() == 1
        
        let start = offer.startDate.asString() + " " + offer.startTime.asString()
        let end = offer.expirationDate.asString() + " " + offer.expirationTime.asString()
        
        offerDetails.startTime = start.toDate()
        offerDetails.endTime = end.toDate()
        
        if offerDetails.category == nil {
            if arrOfCategory.count == 0 {
                getCategories()
            } else {
                bindCategoryToObj()
            }
        } else if offerDetails.product == nil {
            if arrOfProducts.count == 0 {
                getProducts()
            } else {
                bindProductToObj()
            }
        }
    }
    
    func bindCategoryToObj() {
        for category in arrOfCategory {
            if category.storeCategoryId == self.offer?.storeCategoryId {
                self.offerDetails.category = category
                self.getProducts()
                break
            }
        }
        self.tableView.reloadData()
    }
    
    func bindProductToObj() {
        for product in arrOfProducts {
            if product.productId == self.offer?.productId {
                self.offerDetails.product = product
                break
            }
        }
        self.tableView.reloadData()
    }
    
    func getCategories() {
        API_SupplierCategory.shared.getSupplierCategories(
            responseData: { list, loadMore in
                self.arrOfCategory = list
                
                if self.editingType != .add {
                    self.bindCategoryToObj()
                }
                if self.isNeedToOpenCategoryAlert {
                    self.openCategorySelectionAlert()
                }
        },
            errorData: { isDone, message in
                if !isDone {
                    self.showAlert(title: "Alert", message: message)
                }
        })
    }
    
    func getProducts() {
        guard let storeCategoryId = offerDetails.category?.storeCategoryId else {
            return
        }
        
        API_SupplierProduct.shared.getSupplierProducts(
            storeCategoryId: storeCategoryId,
            responseData: { list, loadMore in
                self.arrOfProducts = list
                if self.editingType != .add {
                    self.bindProductToObj()
                }
                if self.isNeedToOpenProductAlert {
                    self.openProductSelectionAlert()
                }
        },
            errorData: { isDone, message in
                if !isDone {
                    self.showAlert(title: "Alert", message: message)
                }
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SupplierOfferDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Enum_OfferDetails_Section(rawValue: indexPath.section) else { return 0 }
        
        switch row {
        case .Image:
            return tableView.frame.width / 1.5
            
        default:
            break
        }
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_OfferDetails_Section(rawValue: section) else { return 0 }
        
        switch row {
        case .Image:
            if editingType == .add && offerDetails.product == nil {
                return 0
            }
            
        case .InputDetails:
            return txtArr.count
            
        default:
            break
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_OfferDetails_Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        let index = indexPath.row
        
        switch row {
        case .Image:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProductAddImageTVC", for: indexPath) as! SupplierProductAddImageTVC
            cell.setupUI()
            
            cell.imgView.isUserInteractionEnabled = isEditingDetails
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(openImagePickerClick))
            cell.imgView.addGestureRecognizer(tap)
            cell.imgView.contentMode = .scaleAspectFill
            cell.imgView.clipsToBounds = true
            
            var productImage = (offer?.productImage).asString()
            if editingType != .show, let image = offerDetails.product?.productImage {
                productImage = image
            }
            
            let url = URL_PRODUCT_IMAGES + productImage
            cell.imgView.setWebImage(url, .noImagePlaceHolder)
            
            return cell
            
        case .InputDetails:
            let title = txtArr[index]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextFieldCell", for: indexPath) as! SupplierTextFieldCell
            
            cell.txtValue.tag = index
            cell.txtValue.delegate = self
            cell.txtValue.keyboardType = .default
            cell.txtValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
            
            cell.bindDetails(title: title)
            cell.callbackForImageTap = nil
            
            var value: String? = ""
            var image: UIImage? = nil
            switch index {
            case 0:
                value = offerDetails.category?.storeCategoryTitle
                image = #imageLiteral(resourceName: "supplier_down_arrow")
                cell.callbackForImageTap = {
                    self.openCategorySelectionAlert()
                }
                break
                
            case 1:
                value = offerDetails.product?.productName
                image = #imageLiteral(resourceName: "supplier_down_arrow")
                cell.callbackForImageTap = {
                    self.openProductSelectionAlert()
                }
                break
                
            case 2:
                cell.txtValue.keyboardType = .numberPad
                value = offerDetails.percentage.description
                break
                
           /* case 3:
                //cell.viewTextBox.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                //cell.txtValue.isEnabled = false
                value = offerDetails.code
                break*/
                
            case 3, 4: //case 4, 5:
                let dtFormate = "dd-MM-yyyy HH:mm:ss"
                if index == 3 {
                    value = offerDetails.startTime?.toString(format: dtFormate)
                } else {
                    value = offerDetails.endTime?.toString(format: dtFormate)
                }
                
                image = #imageLiteral(resourceName: "supplier_calendar")
                cell.callbackForImageTap = {
                    self.openDateTimeSelectionAlert(index: index)
                }
                break
                
            default:
                break
            }
            
//            if !isEditingDetails {
//                image = nil
//            }
            
            cell.txtValue.text = value
            cell.setImage(image: image)
            
            cell.txtValue.isEnabled = isEditingDetails
            cell.imgRightIcon.isUserInteractionEnabled = isEditingDetails
            cell.imgRightIcon.tag = index
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapForOpenSelectionAlert(_:)))
            
            cell.imgRightIcon.addGestureRecognizer(tap)
            
            return cell
            
        case .Descrition:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextViewCell", for: indexPath) as! SupplierTextViewCell
            
            cell.txtBox.isEditable = isEditingDetails
            cell.txtBox.tag = index
            cell.txtBox.delegate = self
            
            cell.bindDetails(title: "Additional Info")
            cell.txtBox.text = offerDetails.additionalInfo
            
            return cell
            
        case .ActiveStatus:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProductActiveStatusTVC", for: indexPath) as! SupplierProductActiveStatusTVC
            cell.bindDetails(title: "Active Status", isSelected: offerDetails.isActive)
            cell.callbackForSelection = {
                self.offerDetails.isActive = !self.offerDetails.isActive
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            cell.switchActive.isUserInteractionEnabled = isEditingDetails
            return cell
        }
    }
}

extension SupplierOfferDetailsVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let txtValue = textView.text.asString()
        offerDetails.additionalInfo = txtValue
    }
    
    @objc func textFieldValueChange(_ txt: UITextField) {
        let txtValue = txt.text.asString()
        let index = txt.tag
        
        switch index {
        case 2:
            if let per = Int(txtValue) {
                offerDetails.percentage = per
            } else {
                offerDetails.percentage = 0
            }
            break
            
       /* case 3:
            offerDetails.code = txtValue
            break*/
            
        default:
            break
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let allowedTags = [2/*, 3*/]
        let tag = textField.tag
        let isAllow = allowedTags.contains(tag)
        
        if !isAllow {
            openAlert(ofTag: tag)
        }
        return isAllow
    }
    
    @objc func tapForOpenSelectionAlert(_ sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            openAlert(ofTag: tag)
        }
    }
    
    func openAlert(ofTag tag: Int) {
        switch tag {
        case 0:
            if arrOfCategory.count == 0 {
                getCategories()
                isNeedToOpenCategoryAlert = true
            } else {
                openCategorySelectionAlert()
            }
            break
            
        case 1:
            if arrOfProducts.count == 0 {
                getProducts()
                isNeedToOpenProductAlert = true
            } else {
                openProductSelectionAlert()
            }
            break
            
        case 3, 4: //4, 5:
            openDateTimeSelectionAlert(index: tag)
            break
            
        default:
            break
        }
    }
    
    func openCategorySelectionAlert() {
        isNeedToOpenCategoryAlert = false
        var arr: [String] = []
        var selectedIndex = -1
        for index in 0..<arrOfCategory.count {
            let category = arrOfCategory[index]
            arr.append(category.storeCategoryTitle.asString())
            
            if category.storeCategoryId == offerDetails.category?.storeCategoryId {
                selectedIndex = index
            }
        }
        openSelectionAlert(
            index: 0,
            arr: arr,
            selectedIndex: selectedIndex,
            response: { value, index in
                let category = self.arrOfCategory[index]
                if self.offerDetails.category?.storeCategoryId != category.storeCategoryId {
                    self.offerDetails.product = nil
                    self.offerDetails.category = category
                    self.arrOfProducts.removeAll()
                    self.getProducts()
                    self.tableView.reloadData()
                }
        })
    }
    
    func openProductSelectionAlert() {
        isNeedToOpenProductAlert = false
        var arr: [String] = []
        var selectedIndex = -1
        for index in 0..<arrOfProducts.count {
            let product = arrOfProducts[index]
            arr.append(product.productName.asString())
            
            if product.productId == offerDetails.product?.productId {
                selectedIndex = index
            }
        }
        
        openSelectionAlert(
            index: 1,
            arr: arr,
            selectedIndex: selectedIndex,
            response: { value, index in
                self.offerDetails.product = self.arrOfProducts[index]
                self.tableView.reloadData()
        })
    }
    
    
}

extension SupplierOfferDetailsVC {
    
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
        
        let indexPath = IndexPath(row: index, section: Enum_OfferDetails_Section.InputDetails.rawValue)
        let cell = tableView.cellForRow(at: indexPath) as! SupplierTextFieldCell
        
        let rows = CGFloat(arr.count)
        var tblHeight = CGFloat(rows * cellSize)
        if rows > 5 {
            tblHeight = CGFloat(4 * cellSize)
        }
        let tblSize = CGSize(width: cell.viewContainer.frame.width, height: tblHeight)
        
        var frame = tableView.getFrame(ofIndexPath: indexPath)
        var point = CGPoint.zero
        point = view.convert(frame.origin, to: view)
        point.y += cell.viewContainer.frame.height
        
        point.x = cell.viewContainer.frame.minX
        frame = CGRect(origin: point, size: tblSize)
        
        tableViewAlert = TableViewAlert()
        tableViewAlert?.cellSize = cellSize
        tableViewAlert?.showView(viewDisplay: view, frame: frame, data: arr, selectedIndex: selectedIndex)
        
        tableViewAlert?.callback = response
        
        tableViewAlert?.dismissCallback = {
            self.tableViewAlert = nil
        }
    }
    
    func openDateTimeSelectionAlert(index: Int) {
        view.endEditing(true)
        
        var title = ""
        var minDate: Date? = Date()
        var selectedDate: Date? = nil
        let maxDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        
        switch index {
        case 3://4:
            title = "Offer Start Date"
            selectedDate = offerDetails.startTime
            
        case 4: //5:
            title = "Offer Expiration Date "
            selectedDate = offerDetails.endTime
            if let date = offerDetails.startTime {
                minDate = date
            }
            
        default:
            return
        }
        
        datePickerVC = SupplierOfferDateTimeSelectionVC(nibName: "SupplierOfferDateTimeSelectionVC", bundle: nil)
        
        datePickerVC?.strTitle = title
        datePickerVC?.selectedDate = selectedDate
        datePickerVC?.minDate = minDate
        datePickerVC?.maxDate = maxDate
        
        datePickerVC?.showView(viewDisplay: view, inFrom: .BOTTOM, isAnimate: true)
        
        datePickerVC?.dtPicker.datePickerMode = .dateAndTime
        
        datePickerVC?.callbackForSelectedDate = { date in
            if index == 3 {
                self.offerDetails.startTime = date
            } else if index == 4 {
                self.offerDetails.endTime = date
            }
            self.tableView.reloadData()
        }
        
        datePickerVC?.callbackForCancel = {
            self.datePickerVC = nil
        }
        
        datePickerVC?.dismissCallback = {
            self.datePickerVC = nil
        }
    }
    
}
