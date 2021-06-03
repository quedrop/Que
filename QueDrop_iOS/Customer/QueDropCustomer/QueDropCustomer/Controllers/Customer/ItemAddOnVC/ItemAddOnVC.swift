//
//  ItemAddOnVC.swift
//  QueDrop
//
//  Created by C100-104 on 12/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SwiftyJSON
protocol AddonsUpdateDelegate {
    func reloadCart(cartData : NSDictionary ,code : String )
}

class ItemAddOnVC: BaseViewController {

    @IBOutlet var btnBack: UIButton!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgFoodType: UIImageView!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblPriceRange: UILabel!
    @IBOutlet var lblItemSize: UILabel!
    @IBOutlet var lblItemSize2: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lblItemPriceBottom: UILabel!
    @IBOutlet var btnShowSizePicker: UIButton!
    @IBOutlet var TopViewHeight: NSLayoutConstraint!  // 70 / 135
    @IBOutlet var lblAddItem: UILabel!
    @IBOutlet var viewShimmer: UIView!
    
    //Variables
    var delegate : AddonsUpdateDelegate?
    var titleString = ""
    var productId = 0
    var productInfo : ProductInfo?{
        didSet{
            if productInfo != nil
            {
                
            }
        }
    }
    var cartProduct : CartProducts?
    var cartAddons : [Addons] = []
    var cartAddonsId : [Int] = []
    var isCustomisation = false
    var selectedSizePrice : Float = 0
    {
        didSet{
            finalPrice = selectedSizePrice + itemPrice
        }
    }
    var finalPrice : Float = 0
    {
        didSet{
            self.lblItemPriceBottom.text  = "1 item | \(Currency)\(finalPrice)"
            structCustomerTempCart.ItemFinalAmmount = finalPrice
        }
    }
    var itemPrice : Float = 0
    var selectedRow : [Int] = []
    var sections = 2
    var selectedSize :IndexPath? = nil
    enum enumAddons : Int {
        case productSize = 0
        case addOns
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewShimmer.isHidden = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.lblTitle.text = self.titleString
        self.getProductInfo(productId: self.productId)
        setUpCustomisation()
        //itemPrice = structCustomerTempCart.ItemFinalAmmount
    }
    
    //MARK:- Action Method
    @IBAction func actionBack(_ sender: Any) {
        if isCustomisation
        {
            structCustomerTempCart.productAddons.removeAll()
            structCustomerTempCart.productAddonsIds.removeAll()
            structCustomerTempCart.ItemFinalAmmount = 0
            structCustomerTempCart.selectedOptions = nil
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func actionAddItem(_ sender: Any) {
        structCustomerTempCart.productAddons.removeAll()
        structCustomerTempCart.productAddonsIds.removeAll()
        var amt  = selectedSizePrice
        for index in selectedRow {
            if let addons = productInfo?.addons?[index]
            {
                let id = productInfo?.productId ?? 0
                amt += addons.addonPrice ?? 0
                let dict = [id:addons]
                let addonId = addons.addonId ?? 0
                print("ProID : \(id) Addons : \(dict[id]?.addonName ?? "")")
                structCustomerTempCart.productAddons.append(dict)
                structCustomerTempCart.productAddonsIds.append(addonId)
            }
        }
        if isCustomisation
        {
            print("Selected AddOns Id :",structCustomerTempCart.productAddonsIds)
            print("Selected Option Name :",structCustomerTempCart.selectedOptions?.optionName ?? "")
            print("Selected Option Id :",structCustomerTempCart.selectedOptions?.optionId ?? 0)
            updateCartItems()
        }
        else
        {
            DispatchQueue.main.async {
                structCustomerTempCart.ItemFinalAmmount = amt
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmItemForCartVC") as! ConfirmItemForCartVC
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
    }
    @IBAction func actionitemSizePicker(_ sender: Any) {
    }
    //MARK:- Methods
    func setDetails(titleString : String, id : Int)
    {
        self.titleString = titleString
        self.productId = id
        self.isCustomisation = false
    }
    func setCustomiseDetails(titleString : String,cartProduct : CartProducts)
    {
        self.titleString = titleString
        self.productId = cartProduct.productId ?? 0
        self.isCustomisation = true
        self.cartProduct = cartProduct
    }
    
    func setUpCustomisation()
    {
        if isCustomisation
        {
            finalPrice = Float(cartProduct?.productFinalPrice ?? 0)
            lblAddItem.text = "Update Item".uppercased()
            if let CAddons = cartProduct?.addons
            {
                for addon in CAddons
                {
                    cartAddons.append(addon)
                    cartAddonsId.append(addon.addonId ?? 0)
                }
            }
            
        }
    }
    func reloadData()
    {
        sections = 2
        
        self.tableView.reloadData()
        //self.lblItemName.text = productInfo?.productName ?? ""
        self.lblItemName.attributedText = createTitleDescriptionString()
        var maxPrice : Float = 0.0
        for addons in productInfo!.addons ?? []
        {
            maxPrice += addons.addonPrice ?? 0
        }
        
        maxPrice += Float(productInfo!.productOption?[(productInfo!.productOption?.count ?? 1) - 1].price ?? 0)
        viewShimmer.isHidden = true
        
        self.lblPriceRange.text = "\(Currency)\(productInfo!.productOption?[0].price ?? 0) - \(Currency)\(maxPrice)"
        //TopViewHeight.constant = 70
        
        /*if self.productInfo?.productOption?.count ?? 0 == 1
        {
            
            TopViewHeight.constant = 70
            self.lblItemSize.text = self.productInfo?.productOption?[0].optionName
            self.lblItemSize2.text = "\(self.productInfo?.productOption?[0].optionName ?? "")-Rs. \(self.productInfo?.productOption?[0].price ?? 00)"
            structCustomerTempCart.selectedOptions = self.productInfo?.productOption?[0]
        }
        else
        {
            TopViewHeight.constant = 135
            for productOption in self.productInfo!.productOption!
            {
                if productOption.isDefault ?? 0 == 1
                {
                    self.lblItemSize.text = productOption.optionName
                    self.lblItemSize2.text = "\(productOption.optionName ?? "")-Rs. \(productOption.price ?? 00)"
                    structCustomerTempCart.selectedOptions = productOption
                    return
                }
            }
        }*/
    }
    
    func createTitleDescriptionString() -> NSMutableAttributedString{
        let r1 = NSMutableAttributedString(string: productInfo?.productName ?? "" )
        let r2 = NSMutableAttributedString(string: "\n" + productInfo!.productDescription! )
               
        r1.addAttribute(.foregroundColor, value: UIColor.black, range: NSMakeRange(0, r1.length))
        r1.addAttribute(.font, value: UIFont(name: fFONT_SEMIBOLD, size:  16.0)!, range: NSMakeRange(0, r1.length))
        
        if (productInfo?.productDescription!.count)! > 0 {
            r2.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, r2.length))
            r2.addAttribute(.font, value: UIFont(name: fFONT_MEDIUM, size:  14.0)!, range: NSMakeRange(0, r2.length))
            
            r1.append(r2)
        }
            return r1
    }
}

//MARK:- TableView Delegate
extension ItemAddOnVC : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        sections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case enumAddons.productSize.rawValue:
            return productInfo != nil ? productInfo?.productOption?.count ?? 0 : 3
        case enumAddons.addOns.rawValue:
            return productInfo != nil ? productInfo?.addons?.count ?? 0 : 5
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section
        {
            case enumAddons.productSize.rawValue:
                let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)) //set these values as necessary
                returnedView.backgroundColor = .clear
                let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width, height: 30))
                   label.text = "Please select one"
                   returnedView.addSubview(label)
                   return returnedView
            case enumAddons.addOns.rawValue:
                let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)) //set these values as necessary
                returnedView.backgroundColor = .clear
                let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width, height: 30))
                    if productInfo == nil
                    {
                        label.text = "Add addons"
                    }
                    else
                    {
                        label.text = productInfo?.addons?.count ?? 0 > 0 ? "Add addons"    : ""
                    }
                   returnedView.addSubview(label)
                   return returnedView
            default:
                return UIView()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section
        {
            case enumAddons.productSize.rawValue:
                return 30.0
            case enumAddons.addOns.rawValue:
                return productInfo == nil ? 30.0 : (productInfo?.addons?.count ?? 0 > 0 ? 30.0 : 0.0)
            default:
                return 0.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return 40.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case enumAddons.productSize.rawValue:
            if productInfo == nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAddOnShimmerTVC", for: indexPath) as! ItemAddOnTVC
                cell.selectionStyle = .none
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAddOnTVC", for: indexPath) as! ItemAddOnTVC
                cell.lblAddOnTitle.text = "\(productInfo?.productOption?[indexPath.row].optionName ?? "")   \(Currency)\(productInfo?.productOption?[indexPath.row].price ?? 0)"
//                cell.lblAddOnTitle.text = "\(productInfo?.productOption?[indexPath.row].optionName ?? "")"
//                cell.lblAddOnPrice.text = "\(Currency)\(productInfo?.productOption?[indexPath.row].price ?? 0)"
                if isCustomisation
                {
                    if productInfo?.productOption?[indexPath.row].optionId ?? 0 == cartProduct?.optionId ?? 0
                    {
                        cell.imageRadioButton.isHighlighted = true
                        structCustomerTempCart.selectedOptions = productInfo?.productOption?[indexPath.row]
                        selectedSize = indexPath
                        selectedSizePrice = Float(productInfo?.productOption?[indexPath.row].price ?? 0)
                    }
                    else
                    {
                        cell.imageRadioButton.isHighlighted = false
                    }
                }
                else
                {
                    if selectedSize == nil && productInfo?.productOption?[indexPath.row].isDefault ?? 0 == 1
                    {
                        cell.imageRadioButton.isHighlighted = true
                        structCustomerTempCart.selectedOptions = productInfo?.productOption?[indexPath.row]
                        selectedSize = indexPath
                        selectedSizePrice = Float(productInfo?.productOption?[indexPath.row].price ?? 0)
                    }
                    else if selectedSize != nil && indexPath == selectedSize
                    {
                        cell.imageRadioButton.isHighlighted = true
                    }
                    else
                    {
                        cell.imageRadioButton.isHighlighted = false
                    }
                }
                
                cell.selectionStyle = .none
                return cell
            }
        case enumAddons.addOns.rawValue:
            if productInfo == nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAddOnShimmerTVC", for: indexPath) as! ItemAddOnTVC
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAddOnTVC", for: indexPath) as! ItemAddOnTVC
                cell.lblAddOnTitle.text = "\(productInfo?.addons?[indexPath.row].addonName ?? "")   \(Currency)\(productInfo?.addons?[indexPath.row].addonPrice ?? 0)"
//                cell.lblAddOnTitle.text = "\(productInfo?.addons?[indexPath.row].addonName ?? "")"
//                cell.lblAddOnPrice.text = "\(Currency)\(productInfo?.addons?[indexPath.row].addonPrice ?? 0)"
                if isCustomisation
                {
                    if cartAddonsId.contains(productInfo?.addons?[indexPath.row].addonId ?? 0)
                    {
                        itemPrice += productInfo?.addons?[indexPath.row].addonPrice ?? 0
                        finalPrice += productInfo?.addons?[indexPath.row].addonPrice ?? 0
                        selectedRow.append(indexPath.row)
                        cell.imageRadioButton.isHighlighted = true
                    }
                }
                cell.selectionStyle = .none
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if productInfo != nil
        {
            switch indexPath.section {
            case enumAddons.addOns.rawValue:
                if selectedRow.contains(indexPath.row)
                {
                    let cell = tableView.cellForRow(at: indexPath) as? ItemAddOnTVC
                    cell?.imageRadioButton.isHighlighted = false
                    selectedRow = selectedRow.filter({$0 != indexPath.row})
                    itemPrice = itemPrice - (productInfo?.addons?[indexPath.row].addonPrice ?? 0)
                    finalPrice = finalPrice - (productInfo?.addons?[indexPath.row].addonPrice ?? 0)
                }
                else
                {
                    itemPrice += productInfo?.addons?[indexPath.row].addonPrice ?? 0
                    finalPrice += productInfo?.addons?[indexPath.row].addonPrice ?? 0
                    selectedRow.append(indexPath.row)
                    let cell = tableView.cellForRow(at: indexPath) as? ItemAddOnTVC
                    cell?.imageRadioButton.isHighlighted = true
                }
                if let tmpIndexPath = selectedSize
                {
                    let cell = tableView.cellForRow(at: tmpIndexPath) as? ItemAddOnTVC
                    cell?.imageRadioButton.isHighlighted = true
                }
                break
            case enumAddons.productSize.rawValue:
                if let tmpIndexPath = selectedSize
                {
                    if tmpIndexPath != indexPath
                    {
                        let cell = tableView.cellForRow(at: tmpIndexPath) as? ItemAddOnTVC
                        cell?.imageRadioButton.isHighlighted = false
                    }
                }
                let cell = tableView.cellForRow(at: indexPath) as? ItemAddOnTVC
                cell?.imageRadioButton.isHighlighted = true
                selectedSize = indexPath
                structCustomerTempCart.selectedOptions = productInfo?.productOption?[indexPath.row]
                selectedSizePrice = Float(productInfo?.productOption?[indexPath.row].price ?? 0)
                break
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if productInfo != nil
        {
            switch indexPath.section {
            case enumAddons.productSize.rawValue:
                let cell = tableView.cellForRow(at: indexPath) as? ItemAddOnTVC
                cell?.imageRadioButton.isHighlighted = false
                break
            default:
                break
            }
        }
    }
    
}
