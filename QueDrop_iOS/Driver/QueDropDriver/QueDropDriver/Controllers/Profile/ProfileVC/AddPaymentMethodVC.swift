//
//  AddPaymentMethodVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 16/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

struct Struct_SupplierBankDetails {
    var bank: Banks?
    
    var accountNumber = ""
    var ifscCode = ""
    var otherDetails = ""
    
    //1- saving, 2-current
    var accountType = Enum_BankAccountType.Saving
    
    var isParimary = false
}

class AddPaymentMethodVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    enum Enum_AddPaymentType: Int {
        case BankName = 0
        case AccountType
        case InputFields
        case Description
        case IsPrimary
    }
    
    let txtArr = ["Account Number", "IFSC Code"]
    
    var arrOfBanks: [Banks] = []
    
    private var isEditDetails = false
    var bankDetails = Struct_SupplierBankDetails()
    var bankObj: BankDetails?
    
    var tableViewAlert: TableViewAlert?
    var callbackForLatestDetails: ((BankDetails)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditDetails = bankObj != nil
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBankList()
        
    }
    
    func bindDetails() {
        guard let bank = bankObj else {
            return
        }
        
        bankDetails = Struct_SupplierBankDetails()
        bankDetails.accountNumber = bank.accountNumber.asString()
        
        bankDetails.isParimary = bank.isPrimary.asInt() == 1
        bankDetails.ifscCode = bank.ifscCode.asString()
        
        if let accType = bank.accountType, let type = Enum_BankAccountType(rawValue: accType) {
            bankDetails.accountType = type
        } else {
            bankDetails.accountType = .Saving
        }
        bankDetails.otherDetails = bank.otherDetail.asString()
        bindBankToObj()
        
        tableView.reloadData()
    }
    
    func setupUI() {
        bindDetails()
        view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text =  bankObj == nil ? "Add Bank Account" : "Edit Bank Account"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        let btnTitle = bankObj == nil ? "Add" : "Save"
        let attrTitle = NSMutableAttributedString(string: btnTitle)
        attrTitle.setColorTo(text: btnTitle, withColor: .white)
        attrTitle.bold(btnTitle, 19)
        
        btnAdd.setTitle(nil, for: .normal)
        btnAdd.setAttributedTitle(attrTitle, for: .normal)
        
        btnAdd.backgroundColor = THEME_COLOR
        btnAdd.showBorder(.clear, 8)
        
        setupTableView(tableView: tableView)
    }
    
    func setupTableView(tableView: UITableView) {
        
        let cellIdentifiers = [
            "SupplierTextFieldCell",
            "SupplierTextViewCell",
            "SupplierAccountTypeTVC",
            "SupplierProductActiveStatusTVC"
        ]
        
        for ids in cellIdentifiers {
            tableView.register(ids)
        }
        
        //setupPullRefresh(tblView: tableView, delegate: self)
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.isScrollEnabled = true
        tableView.bounces = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        
        //tableView.contentInsetAdjustmentBehavior = .never
        tableView.setHeaderFootertView(headHeight: 10, footHeight: 10)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddClick(_ sender: Any) {
        let valid = validatePaymentDetails(detail: bankDetails)
        if !valid.0 {
            ShowToast(message: valid.1)
        } else {
            addEditBankDetail(isAdd:  !isEditDetails, bankDetailId: (bankObj?.bankDetailId).asInt(), detail: bankDetails)
        }
        
        
        
    }
    
    func validatePaymentDetails(detail: Struct_SupplierBankDetails) -> (Bool, String) {
        var isValid = false
        var msg = ""
        
        if detail.bank == nil {
            msg = "Please select bank"

        } else if detail.accountNumber.isEmpty {
            msg = "Please enter account number"

        } else if detail.ifscCode.isEmpty {
            msg = "Please enter IFSC Code"
            
        } else {
            isValid = true
        }
        
        return (isValid, msg)
    }
    
    func getBankList() {
        getBankNameList()
    }
    
    func bindBankToObj() {
        for bank in arrOfBanks {
            if bank.bankId == self.bankObj?.bankId {
                self.bankDetails.bank = bank
                break
            }
        }
        self.tableView.reloadData()
    }
}
// MARK: - UITABLEVIEW DELEGATE/DATASOURCE METHODS
extension AddPaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let row = Enum_AddPaymentType(rawValue: section) else {
            return 0
        }
        switch row {
        case .InputFields:
            return txtArr.count
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Enum_AddPaymentType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        let index = indexPath.row
        
        switch row {
        case .BankName, .InputFields:
            return getTextDetailCell(row: row, indexPath: indexPath)
            
        case .Description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextViewCell", for: indexPath) as! SupplierTextViewCell
            cell.tag = 50 + index
            cell.txtBox.isEditable = true
            cell.txtBox.tag = index
            cell.txtBox.delegate = self
            
            cell.bindDetails(title: "Other Details")
            cell.txtBox.text = bankDetails.otherDetails
            
            let cellBgColor = UIColor.white // #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            cell.txtBox.backgroundColor = cellBgColor
            cell.txtBox.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
            
            return cell
            
        case .AccountType:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierAccountTypeTVC", for: indexPath) as! SupplierAccountTypeTVC
            cell.tag = 50 + index
            
            let isSaving = bankDetails.accountType == .Saving
            cell.bindDetail(isSaving: isSaving)
            cell.callbackForAccountTypeChange = { type in
                self.bankDetails.accountType = type
                tableView.reloadData()
            }
            return cell
            
        case .IsPrimary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierProductActiveStatusTVC", for: indexPath) as! SupplierProductActiveStatusTVC
            cell.bindDetails(title: "Primary Bank Account", isSelected: bankDetails.isParimary)
            cell.callbackForSelection = {
                self.bankDetails.isParimary = !self.bankDetails.isParimary
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            cell.switchActive.isUserInteractionEnabled = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getTextDetailCell(row: Enum_AddPaymentType, indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplierTextFieldCell", for: indexPath) as! SupplierTextFieldCell
        cell.tag = 50 + index
        cell.txtValue.tag = index
        cell.txtValue.delegate = self
        cell.txtValue.addTarget(self, action: #selector(textFieldValueChange(_:)), for: .editingChanged)
        
        cell.callbackForImageTap = nil
        
        var value: String? = ""
        var image: UIImage? = nil
        
        switch row {
        case .BankName:
            image =  UIImage(named: "drop_down")
            value = bankDetails.bank?.bankName
            
            cell.txtValue.tag = 101
            cell.bindDetails(title: "Bank Name")
            
            cell.callbackForImageTap = {
                self.openBankSelectionAlert()
            }
            break
            
        default:
            let title = txtArr[index]
            cell.bindDetails(title: title)
            switch index {
            case 0:
                value = bankDetails.accountNumber
                break
                
            case 1:
                value = bankDetails.ifscCode
                break
                
            default:
                break
            }
            break
        }
        
        cell.txtValue.keyboardType = .numberPad
        cell.txtValue.text = value
        cell.setImage(image: image)
        
        cell.txtValue.isEnabled = true
        cell.imgRightIcon.isUserInteractionEnabled = (row == .BankName)
        
        let cellBgColor = UIColor.white // #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        cell.viewTextBox.backgroundColor = cellBgColor
        
        cell.txtValue.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 17.0))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapForOpenBankSelectionAlert(_:)))
        cell.imgRightIcon.addGestureRecognizer(tap)
        
        return cell
    }
}

extension AddPaymentMethodVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let txtValue = textView.text.asString()
        bankDetails.otherDetails = txtValue
    }
    
    @objc func textFieldValueChange(_ txt: UITextField) {
        let value = txt.text.asString()
        let index = txt.tag
        
        if index == 0 {
            bankDetails.accountNumber = value
        } else if index == 1 {
            bankDetails.ifscCode = value
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        if tag == 101 {
            openBankSelectionAlert()
        }
        return !(tag == 101)
    }
}

extension AddPaymentMethodVC {
    
    @objc func tapForOpenBankSelectionAlert(_ sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag, tag == 101 {
            openBankSelectionAlert()
        }
    }
    
    func openBankSelectionAlert() {
        var arr: [String] = []
        var selectedIndex = -1
        for index in 0..<arrOfBanks.count {
            let bank = arrOfBanks[index]
            arr.append(bank.bankName.asString())
            
            if bank.bankId == bankDetails.bank?.bankId {
                selectedIndex = index
            }
        }
        
        openSelectionAlert(
            index: 0,
            arr: arr,
            selectedIndex: selectedIndex,
            response: { value, index in
                self.bankDetails.bank = self.arrOfBanks[index]
                self.tableView.reloadData()
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
        
        let indexPath = IndexPath(row: index, section: Enum_AddPaymentType.BankName.rawValue)
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
    
}
