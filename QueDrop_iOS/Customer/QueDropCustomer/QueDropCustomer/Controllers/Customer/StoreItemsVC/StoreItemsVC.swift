//
//  StoreItemsVC.swift
//  QueDrop
//
//  Created by C100-104 on 10/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
class StoreItemsVC: BaseViewController {

	@IBOutlet var btnBack: UIButton!
	@IBOutlet var lbltitle: UILabel!
	@IBOutlet var btnSearch: UIButton!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewNoFeesViewBG: UIView!
	@IBOutlet var viewNoFees: UIView!
	@IBOutlet var lblPopUpTitle: UILabel!
	@IBOutlet var lblPopupContent: UILabel!
	
	@IBOutlet var lblResultNotFound: UILabel!
	@IBOutlet var bottomCartViewHeight: NSLayoutConstraint!
	@IBOutlet var bottomCartView: GradientView!
	@IBOutlet var lblItemAmmount: UILabel!
	@IBOutlet var btnViewCart: UIButton!
	@IBOutlet var viewSearchHeight: NSLayoutConstraint!
	@IBOutlet var txtSearchBar: UITextField!
	@IBOutlet var btnCancelSearch: UIButton!
	
	//MARK:- variables
	var storeId = 0
	var StoreCategories : [FoodCategory] = []
	var filterStoreCategories : [FoodCategory] = []
	var selctedProId = 0
	var apiCalled = false
	var OriginalStoreCategories : [FoodCategory] = []
	var SelectedCatIndex = 0
	var textSearch = ""
	var tempSKCategories : [FoodCategory] = []
    var cartDetails : AddedProductDetails?
	var isSearch = false
    var isFreshProduced = false
    
	//MARK:- View Methods
	override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
		self.tableView.dataSource = self
		self.tableView.delegate = self
		bottomCartViewHeight.constant = 0
		self.bottomCartView.alpha = 0.0
		//self.txtSearchBar.delegate = self
		self.txtSearchBar.setLeftPadding(30)
		self.txtSearchBar.setRightPadding(30)
		self.getStoreItems(storeId: storeId)
		self.viewSearchHeight.constant = isSearch ? 50 : 0
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		
		IsItemDiscard = false
		structCustomerTempCart.product = nil
		structCustomerTempCart.productAddons.removeAll()
		structCustomerTempCart.productAddonsIds.removeAll()
		structCustomerTempCart.productId = 0
		structCustomerTempCart.productQty = 1
		structCustomerTempCart.selectedOptions = nil
		structCustomerTempCart.ItemFinalAmmount = 0
	/*
        cartItems = structCartAry.CartItemsAry.count
		if cartItems == 0
		{
			bottomCartViewHeight.constant = 0
			self.bottomCartView.alpha = 0.0
		}
		else
		{
			var price = 0
			for item in structCartAry.CartItemsAry
			{
				price += item.ItemFinalAmmount
			}
			bottomCartViewHeight.constant = 70
			lblItemAmmount.text = "\(structCartAry.CartItemsAry.count) items | \(Currency)\(price)"
			self.bottomCartView.alpha = 1.0
		}*/
		getStoreItems(storeId: storeId)
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		 let touch = touches.first
	   if(touch?.view?.tag == -99) {
		 UIView.animate(withDuration: 0.4, animations: {
			  self.viewNoFeesViewBG.alpha = 0.0
		  }, completion: {isCompleted in
			  self.viewNoFeesViewBG.isHidden = true
		  })
	   }
	}
	@IBAction func textfieldEditingChanged(_ sender: Any) {
		
		textSearch = txtSearchBar.text ?? ""
		if textSearch == ""
		{
//			StoreCategories = (UserDefaults.standard.getCustom(forKey: kItemCategories) as? [FoodCategory])!
//			OriginalStoreCategories = StoreCategories
			StoreCategories.removeAll()
			StoreCategories.append(contentsOf: OriginalStoreCategories)
		}
		else
		{
			StoreCategories.removeAll()
			StoreCategories.append(contentsOf: filterRecord(searchText: textSearch))
			//StoreCategories = filterRecord(searchText: textSearch)
		}
		reloadData()
		
	}
	
	//MARK:- Action Methods
	@IBAction func actionBackPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionSearch(_ sender: UIButton) {
		UIView.animate(withDuration: 0.8, animations: {
			self.viewSearchHeight.constant = 50
		}, completion: nil)
	}
    @IBAction func actionHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    /*@IBAction func actionPopUpCancel(_ sender: Any) {
		UIView.animate(withDuration: 0.4, animations: {
			self.viewNoFeesViewBG.alpha = 0.0
		}, completion: {isCompleted in
			self.viewNoFeesViewBG.isHidden = true
		})
	}
	@IBAction func actionPopUpConfirm(_ sender: UIButton) {
		let tag = sender.tag
		let section = tag / 100
		let row = tag % 100
		structCustomerTempCart.productId = self.StoreCategories[section].products?[row].productId
		structCustomerTempCart.product = self.StoreCategories[section].products?[row]
		structCustomerTempCart.ItemFinalAmmount = self.StoreCategories[section].products?[row].productPrice ?? 0
		UIView.animate(withDuration: 0.4, animations: {
			self.viewNoFeesViewBG.alpha = 0.0
		}, completion: {isCompleted in
			self.viewNoFeesViewBG.isHidden = true
			if structCustomerTempCart.product?.hasAddons ?? 0 == 1
			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ItemAddOnVC") as! ItemAddOnVC
				nextViewController.setDetails(titleString: self.StoreCategories[section].storeCategoryTitle ?? "", id: self.selctedProId)
				self.navigationController?.pushViewController(nextViewController, animated: true)
			}
			else
			{
				let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmItemForCartVC") as! ConfirmItemForCartVC
				self.navigationController?.pushViewController(nextViewController, animated: true)
			}
			
		})
	}*/
	
	@IBAction func actionShowCart(_ sender: Any) {
		let nextViewController = CustomerCartStoryboard.instantiateViewController(withIdentifier: "CartViewVC") as! CartViewVC
		self.navigationController?.pushViewController(nextViewController, animated: true)
	}
	
	@IBAction func actionCancelSearch(_ sender: Any) {
		txtSearchBar.text = ""
		txtSearchBar.resignFirstResponder()
//		StoreCategories = (UserDefaults.standard.getCustom(forKey: kItemCategories) as? [FoodCategory])!
//		OriginalStoreCategories = StoreCategories
		StoreCategories.removeAll()
		StoreCategories.append(contentsOf: OriginalStoreCategories)
		reloadData()
		UIView.animate(withDuration: 0.8, animations: {
			self.viewSearchHeight.constant = 0
		}, completion: nil)
	}
	
	//MARK:- custom Methods
    func setStoreId(storeId : Int , isSearch : Bool, SelectedCatIndex : Int, isFreshProduce : Bool)
	{
		self.storeId = storeId
		self.isSearch = isSearch
		self.SelectedCatIndex = SelectedCatIndex
        self.isFreshProduced = isFreshProduce
	}
	func reloadData()
	{
		//apiCalled = true
		UIView.performWithoutAnimation {
                self.collectionView.reloadData()
        }
		self.tableView.reloadData()
        if cartDetails != nil && cartDetails?.totalItems ?? 0 > 0
        {
            self.bottomCartView.isHidden = false
            bottomCartViewHeight.constant = 70
            lblItemAmmount.text = "\(cartDetails?.totalItems ?? 0) items | \(Currency)\(cartDetails?.totalPrice ?? 0)"
            self.bottomCartView.alpha = 1.0
        }
        else
        {
            bottomCartViewHeight.constant = 0
            self.bottomCartView.alpha = 0.0
            self.bottomCartView.isHidden = true
        }
		if SelectedCatIndex != 0
		{
			if collectionView.visibleCells.count > 0
			{
				collectionView.scrollToItem(at: IndexPath(row: SelectedCatIndex, section: 0), at: .top, animated: true)
			}
			if tableView.indexPathsForVisibleRows?.count ?? 0 > 0
			{
				self.tableView.scrollToRow(at: IndexPath(row: 0, section: SelectedCatIndex), at: .top, animated: true)
			}
			//SelectedCatIndex = 0
		}
	}
}
//MARK:- TextField Delegate Methods
extension StoreItemsVC : UITextFieldDelegate{
	
	
	/*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField.text?.count == 1 && string == ""
		{
			textSearch = ""
			StoreCategories = OriginalStoreCategories
			reloadData()
			return true
		}
		textSearch = "\(textField.text ?? "")\(string)"
		StoreCategories = filterRecord(searchText: textSearch)
		reloadData()
		return true
	}*/
	func filterRecord(searchText : String) -> [FoodCategory]
	{
		
		
		//Start
		
		/*		let filtered = orgArr.filter { category in
		category.products?.contains(where:
		{
		($0.productName?.lowercased().contains(searchText.lowercased()) ?? false)
		
		}) ?? false
		}
		*/

	
			
		//End
		

		var tmpSearchedCatArry : [FoodCategory] = []
		
		//var cat_found = false
		//var product_found = false
		var productCount = 0
		var CategoryCount = 0
		for category in self.OriginalStoreCategories
		{
			let tmpSearchedCat: FoodCategory = FoodCategory(json: "")
			tmpSearchedCat.storeCategoryImage = category.storeCategoryImage
			tmpSearchedCat.storeCategoryTitle = category.storeCategoryTitle
			tmpSearchedCat.isActive = category.isActive
			tmpSearchedCat.products = []
			tmpSearchedCat.storeCategoryId = category.storeCategoryId
			
			//let tmpSearchedCat : FoodCategory = category
			if category.products?.count != 0
			{
				var tmpsearchProduct : [Products]? = []
				productCount = 0
				if let product = category.products
				{
					for item in product
					{
						print("Item Name : ",item.productName ?? "")
						if (item.productName ?? "").lowercased().contains(searchText.lowercased())
						{
							productCount += 1
							tmpsearchProduct?.append(item)
						}
					}
				}
				if productCount > 0
				{
					tmpSearchedCat.products = []
					tmpSearchedCat.products?.append(contentsOf: tmpsearchProduct ?? [])
					//tmpSearchedCat.products = tmpsearchProduct
					CategoryCount += 1
					tmpSearchedCatArry.append(tmpSearchedCat)
				}
			}
		}
		return tmpSearchedCatArry
		
	}
}
//MARK:- TableView Delegate
extension StoreItemsVC : UITableViewDelegate , UITableViewDataSource ,UIScrollViewDelegate{
	func numberOfSections(in tableView: UITableView) -> Int {
		if apiCalled
		{
			return self.StoreCategories.count
		}
		return 2
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if apiCalled
		{
			if let _ = self.StoreCategories[section].products
			{
				return self.StoreCategories[section].products?.count ?? 0
			}
			return 1
			
		}
		return 3
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.StoreCategories[section].storeCategoryTitle ?? ""
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30.0
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if self.StoreCategories.count == 0
		{
			let returnedView = FAShimmerButtonView(frame:  CGRect(x: 10, y: 0, width: tableView.bounds.width, height: 30))
			if #available(iOS 13.0, *) {
				returnedView.backgroundColor = .secondarySystemBackground
			} else {
				returnedView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
			}
			 return returnedView
		}
		else
		{
			let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)) //set these values as necessary
			if #available(iOS 13.0, *) {
				returnedView.backgroundColor = .secondarySystemBackground
			} else {
				returnedView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
			}
			
            returnedView.backgroundColor = .clear
			let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.width - 20, height: 30))
			  
			   label.text = self.StoreCategories[section].storeCategoryTitle ?? ""
			   returnedView.addSubview(label)

			   return returnedView
		}
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if !apiCalled
		{
			if let cell = tableView.dequeueReusableCell(withIdentifier: "StoreItemTVShimmerCell", for: indexPath) as? StoreItemTVCell
			{
				cell.selectionStyle = .none
				return cell
			}
		}
		else
		{
			if self.StoreCategories[indexPath.section].products?.count ?? 0 == 0
			{
				let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
				cell.selectionStyle = .none
				cell.textLabel?.frame = CGRect(x: 10, y: 5, width: cell.contentView.bounds.width - 20, height: cell.contentView.bounds.height - 5)
				cell.textLabel?.layer.cornerRadius = 5
				cell.textLabel?.backgroundColor = .white
				cell.contentView.backgroundColor = .clear
				cell.textLabel?.text = "Items Not Available."
				cell.textLabel?.textColor = .black
				return cell
			}
			else if let cell = tableView.dequeueReusableCell(withIdentifier: "StoreItemTVCell", for: indexPath) as? StoreItemTVCell
			{
				if let productObj = self.StoreCategories[indexPath.section].products?[indexPath.row]
				{
					let imageurl = "\(URL_PRODUCT_IMAGES)\(productObj.productImage ?? "")"
                    cell.imageItem.sd_setImage(with: URL(string: imageurl), placeholderImage: QUE_AVTAR,completed : nil)
					//cell.imageItem.sd_setImage(with: URL(string: imageurl), completed: nil)
					cell.lblItemName.text = productObj.productName ?? ""
					cell.lblItemPrice.text = "\(Currency)\(productObj.productPrice ?? 0)"
					cell.btnPriceTag.tag = (indexPath.section*100)+indexPath.row
					if productObj.isProductSelected ?? 0 == 1
					{
						cell.btnAdd.setTitle("Added", for: .normal)
						cell.btnAdd.setTitleColor(.white, for: .normal)
                        //cell.btnAdd.gradientBackground(ColorSet: GRADIENT_ARRAY, direction: .topToBottom)
                        cell.btnAdd.setBackgroundImage(GRADIENT_IMAGE, for: .normal)
                        cell.btnAdd.clipsToBounds = true
					}
					else
					{
						cell.btnAdd.setTitle("Add", for: .normal)
						cell.btnAdd.setTitleColor(.darkGray, for: .normal)
						cell.btnAdd.backgroundColor = .white
						cell.btnAdd.layer.borderColor = UIColor.darkGray.cgColor
                        cell.btnAdd.backgroundColor = .clear
                        cell.btnAdd.setBackgroundImage(nil, for: .normal)
					}
					cell.btnAdd.tag = (indexPath.section*100)+indexPath.row
                    if productObj.needExtraFees ?? 0 == 1
                    {
                        cell.btnPriceTag.isHidden  = true
                    } else {
                        cell.btnPriceTag.isHidden  = false
                    }
				}
				cell.selectionStyle = .none
				
				
				cell.btnPriceTag.addTarget(self, action: #selector(priceTagDidTap), for: .touchUpInside)
				cell.btnAdd.addTarget(self, action: #selector(addItemDidTap), for: .touchUpInside)
				return cell
			}
		}
		
		
		return UITableViewCell()
	}
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.indexPathsForVisibleRows?.count != 0
        {
            if let indexPath = tableView.indexPathsForVisibleRows?[0]
            {
                if SelectedCatIndex != indexPath.section
                {
                    SelectedCatIndex = indexPath.section
                    UIView.performWithoutAnimation {
                            self.collectionView.reloadData()
                    }
                }
            }
        }
    }
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	@objc func addItemDidTap(_ sender : UIButton){
		let tag = sender.tag
		let section = tag / 100
		let row = tag % 100
		structCustomerTempCart.productId = nil
		structCustomerTempCart.product = nil
		structCustomerTempCart.productId = self.StoreCategories[section].products?[row].productId
		structCustomerTempCart.product = self.StoreCategories[section].products?[row]
        structCustomerTempCart.ItemFinalAmmount = Float(self.StoreCategories[section].products?[row].productPrice ?? 0)
		let productId = self.StoreCategories[section].products?[row].productId ?? 0
		print("Product Name",self.StoreCategories[section].products?[row].productName ?? "")
		self.selctedProId = productId
		if structCustomerTempCart.product?.hasAddons ?? 0 == 1 || structCustomerTempCart.product?.productOption?.count ?? 0 > 1
		{
			let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ItemAddOnVC") as! ItemAddOnVC
			nextViewController.setDetails(titleString: self.StoreCategories[section].storeCategoryTitle ?? "", id: productId)
			self.navigationController?.pushViewController(nextViewController, animated: true)
		}
		else
		{
			structCustomerTempCart.selectedOptions = self.StoreCategories[section].products?[row].productOption?[0]
			let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmItemForCartVC") as! ConfirmItemForCartVC
			self.navigationController?.pushViewController(nextViewController, animated: true)
		}
        
	}
	
	
	@objc func priceTagDidTap(_ sender : UIButton){
		let tag = sender.tag
		let section = tag / 100
		let row = tag % 100
		let needExtraFees = self.StoreCategories[section].products?[row].needExtraFees ?? 0
		let productId = self.StoreCategories[section].products?[row].productId ?? 0
		print("Product Name",self.StoreCategories[section].products?[row].productName ?? "")
		
		self.selctedProId = productId
		
		if needExtraFees == 0{
			self.viewNoFeesViewBG.isHidden = false
			UIView.animate(withDuration: 0.8, animations: {
				self.viewNoFeesViewBG.alpha = 1.0
			}, completion: nil)
			//self.viewNoFeesViewBG.isHidden = false
		}
	}
}
//MARK:- CollecetionView Delegate
extension StoreItemsVC : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if apiCalled
		{
			self.lblResultNotFound.isHidden = StoreCategories.count != 0
		}
		return StoreCategories.count != 0 ? StoreCategories.count : 5
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if StoreCategories.count == 0
		{
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonShimmerCVC", for: indexPath) as? CategoryButtonCVC
			{
				return cell
			}
		}
		else
		{
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonCVC", for: indexPath) as? CategoryButtonCVC
			{
				cell.btnCategory.setTitle(StoreCategories[indexPath.row].storeCategoryTitle, for: .normal)
				if SelectedCatIndex == indexPath.row
				{
					//cell.btnCategory.isSelected = true
                    cell.btnView.backgroundColor = .white
					cell.btnCategory.setTitleColor(THEME_COLOR, for: .normal)
                    cell.btnView.layer.borderColor = UIColor.clear.cgColor
					self.lbltitle.text = StoreCategories[indexPath.row].storeCategoryTitle
				}
				else
				{
					//cell.btnCategory.isSelected = false
					cell.btnView.backgroundColor = .clear
					cell.btnCategory.setTitleColor(.white, for: .normal)
					cell.btnView.layer.borderColor = UIColor.white.cgColor
				}
				cell.btnCategory.tag = indexPath.row
				cell.btnCategory.addTarget(self, action: #selector(CategoryDidTap(_:)), for: .touchUpInside)
				return cell
			}
		}
		return UICollectionViewCell()
	}
	
	
	/*func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
		return UICollectionViewFlowLayout.automaticSize
	}
	*/
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}

	func collectionView(_ collectionView: UICollectionView, layout
		collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}
	
	@objc func CategoryDidTap(_ sender : UIButton){
		SelectedCatIndex = sender.tag
		
		self.tableView.scrollToRow(at: IndexPath(row: 0, section: SelectedCatIndex), at: .top, animated: true)
	}
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		<#code#>
//	}
}
