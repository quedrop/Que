//
//  AddStoreOrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 13/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
import ImageSlideshow



class AddStoreOrderVC: BaseViewController {

	@IBOutlet var btnBack: UIButton!
	@IBOutlet var btnLike: UIButton!
	@IBOutlet var BtnSearch: UIButton!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var viewIMagePicker: UIView!
	@IBOutlet var btnCamera: UIButton!
	@IBOutlet var btnGallery: UIButton!
	@IBOutlet var btnContinue: UIButton!
	@IBOutlet var btnAddToCart: UIButton!
	@IBOutlet var viewBottom: GradientView!
     
	//struct
	struct NewOrder {
		var productId = 0
		var productImage : UIImage? = nil
		var productImageURL : String = ""
		var imageName :  String = ""
		var productname : String = ""
		var ProductQty : Int = 1
	}
	
	//vaiable
	var arrProductList : [CartProducts] = []
	var storeId = 0
	var deletedIds : [Int] = []{
		didSet{
			if deletedIds.contains(0)
			{
				deletedIds.removeAll(where:{ $0 == 0})
			}
			print("Deleted IDS :: ",deletedIds)
		}
	}
	var userStoreId = 0
	var storeDetails : StoreDetail?
	var itemCount = 1
	var structOrderItems = NewOrder()
	var isNavigateToCart = false
	var arrOrders : [NewOrder] = []{
		didSet{
			if arrOrders.count > 0
			{
				self.viewBottom.isHidden = false
			}
			else
			{
				self.viewBottom.isHidden = true
			}
		}
	}
	var imagePicker = UIImagePickerController()
	var selectedRow = 0
	var isUserAddedStore = false
	var isfromCart = false
	var isAddMoreVisible = false
	var isCameBack = false
	override func viewDidLoad() {
        super.viewDidLoad()
		/*
		if isGuest
		{
			showAlert(title: "Alert", message: "Please login to application to add items for placing order.", completion: {
				_ in
				if let LoginView = LoginStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
				{
					LoginView.setupForGuest()
					let transition:CATransition = CATransition()
						transition.duration = 0.5
						transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
						transition.type = CATransitionType.push
						transition.subtype = CATransitionSubtype.fromTop
						self.navigationController?.view.layer.add(transition, forKey: kCATransition)
					self.navigationController?.pushViewController(LoginView, animated: false)
				}
			})
		}*/
		self.viewBottom.isHidden = true
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.contentInset.top = -UIApplication.shared.statusBarFrame.height
		imagePicker.delegate = self
		collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		isCameBack = false
		if !isUserAddedStore
		{
			self.getStoreDetails(storeId : storeId)
		}
		else if isfromCart
		{
			self.getStoreDetails(storeId : 0)
		}
		else
		{
			guard let navigationController = self.navigationController else { return }
			var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
			navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
			self.navigationController?.viewControllers = navigationArray
		}
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissImagePicker(tapGestureRecognizer:)))
		viewIMagePicker.addGestureRecognizer(tapGestureRecognizer)
			self.navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if isCameBack
		{
			if !isUserAddedStore
			{
				self.getStoreDetails(storeId : storeId)
			}
			else
			{
				self.getStoreDetails(storeId : 0)
			}
		}
		isCameBack = true
		self.navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
		/*if isGuest
		{
			self.navigationController?.popViewController(animated: true)
		}*/
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}
	
	func prefersStatusBarHidden() -> Bool {
		return false
	}
    //MARK:- Action Methods
	@IBAction func actionLike(_ sender: Any) {
	}
	
	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionShowCamera(_ sender: Any) {
		openCamera()
	}
	@IBAction func btnAddToCart(_ sender: Any) {
		for orders in arrOrders
		{
			if "\(orders.ProductQty)".isEmpty
			{
                ShowToast(message: "Please add Product Quentity.")
				return
			}
			if orders.productname.isEmpty
			{
                   ShowToast(message: "Please add Product Name.")
				return
			}
		}
		isNavigateToCart = true
		if arrOrders.count > 0
		{
			orderItemToStore()
		}
	}
	@IBAction func actionContinue(_ sender: Any) {
		for orders in arrOrders
		{
			if "\(orders.ProductQty)".isEmpty
			{
				ShowToast(message: "Please add Product Quentity.")
				return
			}
			if orders.productname.isEmpty
			{
				ShowToast(message: "Please add Product Name.")
				return
			}
		}
		isNavigateToCart = false
		if arrOrders.count > 0
		{
			orderItemToStore()
		}
	}
	@IBAction func actionShowGallery(_ sender: Any) {
		openGallary()
	}
	@objc func dismissImagePicker(tapGestureRecognizer: UITapGestureRecognizer)
	{
		print("ViewDismiss")
		
		UIView.animate(withDuration: 0.5, animations: {
			self.viewIMagePicker.alpha = 0.0
		}, completion: { _ in
				self.viewIMagePicker.isHidden = true
		})
	}
	//MARK:- function Methods
	func manageItems()
	{
		itemCount = 1
		arrOrders.removeAll()
		for product in arrProductList
		{
			structOrderItems.productId = product.userProductId ?? 0
			structOrderItems.productname =  product.productName ?? ""
			structOrderItems.ProductQty = product.quantity ?? 0
			structOrderItems.productImageURL = product.productImage ?? ""
			arrOrders.append(structOrderItems)
			structOrderItems = NewOrder()
			itemCount += 1
		}
		self.collectionView.reloadData()
	}
	func openCamera()
	{
		if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
		{
			imagePicker.sourceType = UIImagePickerController.SourceType.camera
			imagePicker.allowsEditing = true
			// isCameBack = false
			self.present(imagePicker, animated: true, completion: nil)
		}
		else
		{
			let alert  = UIAlertController(title: "Warning", message: "You don't have camera Access", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			//isCameBack = false
			self.present(alert, animated: true, completion: nil)
		}
	}
	func backTwo() {
		let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
		self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
	}
	func openGallary()
	{
		imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
		imagePicker.allowsEditing = true
		//isCameBack = false
		self.present(imagePicker, animated: true, completion: nil)
	}
	func setStoreId(storeId : Int)
	{
		self.storeId = storeId
		self.isUserAddedStore = false
		self.isfromCart = false
	}
	func setUserStoreId(userStoreId : Int)
	{
		self.userStoreId = userStoreId
		self.isUserAddedStore = true
		self.isfromCart = true
	}
	func setStoreObj(storeDetails : StoreDetail)
	{
		self.storeDetails = storeDetails
		self.userStoreId = storeDetails.userStoreId ?? 0
		self.isUserAddedStore =  true
		self.isfromCart = false
	}
	
	//Calculate Distance Between two location
	func distance(lat1:Double, lon1:Double) -> String {
		let lat2 = Double(defaultAddress?.latitude ?? "0.0") ?? 0.0
		let lon2 = Double(defaultAddress?.longitude ?? "0.0") ?? 0.0
		let coordinate₀ = CLLocation(latitude: lat1, longitude: lon1)
		let coordinate₁ = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
		
		let time = distanceInMeters / 400
		if time > 50 && time < 60
		{
			print("around 1 hour(\(time.rounded(toPlaces: 0))minits)")
		}
		else if time >= 60
		{
			print("Hours : ",(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0)))
			//tmproutetime = "\(Int(Double(time/60).rounded(toPlaces: 1).rounded(toPlaces: 0))) Hrs"
		}
		else
		{
			print("Minit : ",time.rounded(toPlaces: 0))
			//tmproutetime = "\(Int(time.rounded(toPlaces: 0))) min"
		}
		
		
		let distanceInKM = distanceInMeters / 1000
		if distanceInMeters >= 1000
		{
			//tmproutedist = "\(distanceInKM.rounded(toPlaces: 2)) KM"
			return "\(distanceInKM.rounded(toPlaces: 2)) km"
		}
		else
		{
			//tmproutedist = "\(distanceInMeters.rounded(toPlaces: 2)) MTR"
			return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
		}
		//return "\(distanceInKM)"
		
		
	}
}
//MARK:- ImagePicker Delegate Method
extension AddStoreOrderVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[.editedImage] as? UIImage {
			if selectedRow == arrOrders.count
			{
				let imagename = "\(info[.imageURL] ?? "")".split(separator: "/").last
				print("ImageName : ",imagename)
				structOrderItems.productImage = pickedImage
				structOrderItems.imageName = "swift_file"//"\(imagename ?? "")"
				arrOrders.append(structOrderItems)
				structOrderItems = NewOrder()
				isAddMoreVisible = true
				self.collectionView.reloadData()
			}
			else
			{
				if let cell = collectionView.cellForItem(at: IndexPath(row: selectedRow, section: 0)) as? AddStoreOrderCVCell
				{
					let imagename = "\(info[.imageURL] ?? "")".split(separator: "/").last
					print("ImageName : ",imagename)
					cell.imageProduct.contentMode = .scaleToFill
					arrOrders[selectedRow].imageName = "swift_file"//"\(imagename ?? "")"
					arrOrders[selectedRow].productImage = pickedImage
					cell.imageProduct.image = pickedImage
				}
			}
		}
		picker.dismiss(animated: true, completion: nil)
		UIView.animate(withDuration: 0.2, animations: {
			self.viewIMagePicker.alpha = 0.0
		}, completion: { _ in
				self.viewIMagePicker.isHidden = true
		})
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
		UIView.animate(withDuration: 0.2, animations: {
			self.viewIMagePicker.alpha = 0.0
		}, completion: { _ in
				self.viewIMagePicker.isHidden = true
		})
	}
	
	func setImageInCell(image : UIImage)
	{
		if let cell = collectionView.cellForItem(at: IndexPath(row: selectedRow, section: 0)) as? AddStoreOrderCVCell
		{
			cell.imageProduct.image = image
		}
	}
	
}

//MARK:- CollectionView Delegate Method
extension AddStoreOrderVC : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
			 // 1
			 switch kind {
			 // 2
			 case UICollectionView.elementKindSectionHeader:
			   // 3
			   guard
				 let headerView = collectionView.dequeueReusableSupplementaryView(
				   ofKind: kind,
				   withReuseIdentifier: "StoreDetailScreenHeaderCVCell",
				   for: indexPath) as? StoreDetailScreenHeaderCVCell
				 else {
				   fatalError("Invalid view type")
			   }
			headerView.contentView.isHidden = true


			var combination = NSMutableAttributedString()

			headerView.lblstoretitle.text = self.storeDetails?.storeName ?? ""
			headerView.lblRating.text = "\(self.storeDetails?.storeRating ?? 0.0)"
			headerView.lblStoreAddress.text  = self.storeDetails?.storeAddress ?? ""
			if !isUserAddedStore
			{
				headerView.StoreTimingBottomConstraint.constant = 15
				headerView.calendarImageHeightConstraint.constant = 12
				var isOpen = false

				if self.storeDetails?.canProvideService ?? 0 == 1
				{
					isOpen = true
					combination.append(setText(text: "Open now", textColor: .green))
				}
				else
				{
					isOpen = false
					combination.append(setText(text: "Close now", textColor: .red))
				}
				if storeDetails?.schedule?.count != 0
				{
					combination = NSMutableAttributedString()
					var dayOfWeek = Calendar.current.dateComponents([.weekday], from: Date()).weekday!
					if dayOfWeek == 1
					{
						dayOfWeek = 6
					}
					else
					{
						dayOfWeek = dayOfWeek - 2
					}
					let index = self.matchTiming(dayOfWeek: dayOfWeek)
					isOpen = index > -1
					if isOpen
					{
						 
						combination.append(setText(text: "Open now", textColor: .green))
					}
					else
					{
						combination.append(setText(text: "Close now", textColor: .red))
					}
					
					if index > -1
					{
						if isOpen
						{
								combination.append(setText(text: " - ", textColor: .green))
						} else {
								combination.append(setText(text: " - ", textColor: .red))
						}
						let timing = storeDetails?.schedule?[index]
					combination.append(setText(text: " \(timing?.openingTime?.dropLast(3) ?? "00:00") - \(timing?.closingTime?.dropLast(3) ?? "00:00")(today)", textColor: .darkGray))
					}

				}
				headerView.lblStoreTiming.attributedText = combination
                self.btnLike.isHidden = false
			}
			else
			{
				headerView.StoreTimingBottomConstraint.constant = 0
				headerView.calendarImageHeightConstraint.constant = 0
                self.btnLike.isHidden = true
			}
			
			
			//set ImageSlider

			headerView.arrimg.removeAll()
			var image_is_available_count = 0
			if storeDetails?.sliderImages != nil
			{
				if storeDetails?.sliderImages?.count != 0
				{

					let images: [SliderImages] = storeDetails!.sliderImages!

					for image in images {
						if let imgName = image.sliderImage {
							let imgDown = SDWebImageSource(urlString: ("\(URL_STORE_SLIDER_IMAGES)\(imgName)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(URL_STORE_SLIDER_IMAGES)\(imgName)")
							if imgDown != nil {
								headerView.arrimg.append(imgDown!)
								image_is_available_count  += 1
							}
							else
							{
								headerView.arrimg.append(ImageSource(image: UIImage(named: "NoImage")!))
							}
						}
					}
				}
			}
			headerView.imageSlider.setImageInputs(headerView.arrimg)
			headerView.imageSlider.contentScaleMode = .scaleAspectFill
	//		if image_is_available_count > 0
	//		{
	//			headerView.imageSlider.backgroundColor = .clear
	//			headerView.imageSlider.contentScaleMode = .scaleAspectFill
	//
	//		}
	//		else
	//		{
	//			headerView.imageSlider.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 0.9)
	//			headerView.imageSlider.contentScaleMode = .center
	//		}
	//End
			//set distance
			headerView.lblDistance.text = distance(lat1: Double(storeDetails?.latitude ?? "0.0") ?? 0.0, lon1: Double(storeDetails?.longitude ?? "0.0") ?? 0.0)

			// set profile image
			if let imageName = self.storeDetails?.storeLogo
			{
				let logoURL = "\(URL_STORE_LOGO_IMAGES)\(imageName)"
				headerView.imageStoreLogo.sd_setImage(with: URL(string: logoURL), placeholderImage: QUE_AVTAR , completed: nil)
				headerView.imageStoreLogo.layer.cornerRadius = 3
				headerView.imageStoreLogo.clipsToBounds = true
            }else {
                headerView.imageStoreLogo.image = QUE_AVTAR
            }
			self.btnLike.isSelected = self.storeDetails?.isFavourite ?? false

			return headerView

			default:
			   // 4
			   assert(false, "Invalid element type")
			 }
			return UICollectionReusableView()
		}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		if isUserAddedStore
		{
			return CGSize(width: collectionView.bounds.width, height: 345)
		}
        return CGSize(width: collectionView.bounds.width, height: 370)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return itemCount
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		//if arrProductList.count > indexPath.row
		if false
		{
			let product = arrProductList[indexPath.row]
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStoreOrderCVCell", for: indexPath) as? AddStoreOrderCVCell
			{
				let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
				cell.imageProduct.addGestureRecognizer(tapGestureRecognizer)
				cell.imageProduct.isUserInteractionEnabled = true
				cell.imageProduct.tag = indexPath.row
				if !(product.productImage?.isEmpty ?? true)
				{
					let imgURL = URL_PRODUCT_IMAGES + (product.productImage ?? "")
					cell.imageProduct.sd_setImage(with: URL(string: imgURL), placeholderImage: QUE_AVTAR, completed: nil)
					cell.imageProduct.contentMode = .scaleToFill
				}
				else
				{
					cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
					cell.imageProduct.contentMode = .center
				}
				cell.btnCancel.addTarget(self, action: #selector(removeRow(_ :)), for: .touchUpInside)
				cell.textProductName.tag = (1*100)+indexPath.row
				cell.textProductQty.tag = (2*100)+indexPath.row
				cell.textProductQty.keyboardType = .numberPad
				cell.textProductName.delegate = self
				cell.textProductQty.delegate = self
				cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
				cell.imageProduct.contentMode = .center
				if arrOrders.count > indexPath.row
				{
					if arrOrders[indexPath.row].productImage == nil
					{
							cell.imageProduct.image =  #imageLiteral(resourceName: "left-image")
							cell.imageProduct.contentMode = .center
					}
					else
					{
						cell.imageProduct.image = arrOrders[indexPath.row].productImage
						cell.imageProduct.contentMode = .scaleToFill
						if arrOrders[indexPath.row].productname.isEmpty
						{
								isAddMoreVisible = false
						}
					}
					cell.btnAddMore.isHidden = !isAddMoreVisible
					cell.textProductName.text = arrOrders[indexPath.row].productname
					cell.textProductQty.text = "\(arrOrders[indexPath.row].ProductQty)"
					if cell.textProductName.text?.isEmpty ?? true
					{
						cell.textProductName.becomeFirstResponder()
					}
					cell.btnAddMore.addTarget(self, action: #selector(addMoreRow(_ :)), for: .touchUpInside)
					cell.btnCancel.isHidden = false
					cell.btnCancel.tag = indexPath.row
				}
				else
				{
					cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
					cell.imageProduct.contentMode = .center
					cell.textProductQty.text  = ""
					cell.textProductName.text = ""
					cell.btnCancel.isHidden = true
					
				}
				return cell
			}
		}
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStoreOrderCVCell", for: indexPath) as? AddStoreOrderCVCell
		{
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
			cell.imageProduct.addGestureRecognizer(tapGestureRecognizer)
			cell.imageProduct.isUserInteractionEnabled = true
			cell.imageProduct.tag = indexPath.row
			cell.btnCancel.addTarget(self, action: #selector(removeRow(_ :)), for: .touchUpInside)
			cell.textProductName.tag = (1*100)+indexPath.row
			cell.textProductQty.tag = (2*100)+indexPath.row
			cell.textProductQty.keyboardType = .numberPad
			cell.textProductName.delegate = self
			cell.textProductQty.delegate = self
			cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
			cell.imageProduct.contentMode = .center
			if arrOrders.count > indexPath.row
			{
				if arrOrders[indexPath.row].productImage == nil
				{
					if arrOrders[indexPath.row].productImageURL.isEmpty
					{
						cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
						cell.imageProduct.contentMode = .center
					}
					else
					{
						let imageURL = URL(string: URL_PRODUCT_IMAGES + arrOrders[indexPath.row].productImageURL)
						cell.imageProduct.sd_setImage(with: imageURL, placeholderImage: QUE_AVTAR, completed: nil)
						cell.imageProduct.sd_imageIndicator = SDWebImageActivityIndicator()
						cell.imageProduct.contentMode = .scaleToFill
					}
				}
				else
				{
					
					
					cell.imageProduct.image = arrOrders[indexPath.row].productImage
					cell.imageProduct.contentMode = .scaleToFill
					if arrOrders[indexPath.row].productname.isEmpty
					{
							isAddMoreVisible = false
					}
				}
				cell.btnAddMore.isHidden = !isAddMoreVisible
				cell.textProductName.text = arrOrders[indexPath.row].productname
				cell.textProductQty.text = "\(arrOrders[indexPath.row].ProductQty)"
				if cell.textProductName.text?.isEmpty ?? true
				{
					cell.textProductName.becomeFirstResponder()
				}
				cell.btnAddMore.addTarget(self, action: #selector(addMoreRow(_ :)), for: .touchUpInside)
				cell.btnCancel.isHidden = false
				cell.btnCancel.tag = indexPath.row
			}
			else
			{
				cell.imageProduct.image = #imageLiteral(resourceName: "left-image")
				cell.imageProduct.contentMode = .center
				cell.textProductQty.text  = ""
				cell.textProductName.text = ""
				cell.btnCancel.isHidden = true
				
			}
			return cell
		}
		return UICollectionViewCell()
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if itemCount - 1 == indexPath.row && isAddMoreVisible
		{
			let width = collectionView.frame.size.width - 10
			let height = CGFloat(135)
			return CGSize(width: width, height: height)
		}
		else
		{
			let width = collectionView.frame.size.width - 10
			let height = CGFloat(105)
			return CGSize(width: width, height: height)
		}
		/*if arrOrders.count != 0
		{
			if arrOrders.count - 1 == indexPath.row && isAddMoreVisible
			{
				let width = collectionView.frame.size.width - 20
				let height = CGFloat(135)
				return CGSize(width: width, height: height)
			}
			if arrOrders.count < indexPath.row - 1
			{
				let width = collectionView.frame.size.width - 20
				let height = CGFloat(105)
				return CGSize(width: width, height: height)
			}
			
		}
		let width = collectionView.frame.size.width - 20
		let height = CGFloat(105)
		return CGSize(width: width, height: height)*/
	}

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
	@objc func removeRow(_ sender: UIButton)
	{
		let index = sender.tag
		
		if index < itemCount
		{
			deletedIds.append(arrOrders[index].productId)
			self.arrOrders.remove(at: index)
			
			self.itemCount = itemCount - 1
//			if #available(iOS 13.0, *) {
//				self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
//			}
//			else
//			{
				self.collectionView.reloadData()
			//}
		}
		if itemCount == 0
		{
			itemCount = 1
			self.isAddMoreVisible = false
			self.collectionView.reloadData()
		}
		
	}
	@objc func addMoreRow(_ sender: UIButton)
	{
		isAddMoreVisible = false
		self.itemCount += 1
		self.collectionView.insertItems(at: [IndexPath(row: itemCount - 1, section: 0)])
	}
	@objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
	{
//		if structOrderItems.productname != "" && structOrderItems.ProductQty != 0
//		{
				let tappedImageView = tapGestureRecognizer.view as! UIImageView
				selectedRow = tappedImageView.tag
				print("ImageTapped")
				self.viewIMagePicker.isHidden = false
				UIView.animate(withDuration: 0.8, animations: {
					self.viewIMagePicker.alpha = 1.0
				}, completion: nil)
//		}
//		else
//		{
//			showAlert(title: "Alert", message: "Please Add Item name and Quantity")
//		}
		
	}
	func setText(text: String , textColor : UIColor) -> NSMutableAttributedString
	{
		let myString = text
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .justified
		let myAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColor , NSAttributedString.Key.paragraphStyle : paragraphStyle]
		let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
		return myAttrString
	}
	func matchTiming(dayOfWeek : Int) -> Int
	{
		let now = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat  = "EEEE"
		let dayInWeek = dateFormatter.string(from: now)
		var curr_index = -1
		for schedule in self.storeDetails?.schedule ?? []
		{
			curr_index += 1
			if schedule.weekday?.lowercased() ?? "" == dayInWeek.lowercased()
			{
				let openingTime = schedule.openingTime ?? ""
				let o_hour = Int(openingTime.dropLast(6)) ?? 0
				let o_min = Int((openingTime.dropLast(3)).dropFirst(3)) ?? 0
				let opening = now.dateAt(hours: o_hour, minutes: o_min)
				let closingTime = schedule.closingTime ?? ""
				let c_hour = Int(closingTime.dropLast(6)) ?? 0
				let c_min = Int((closingTime.dropLast(3)).dropFirst(3)) ?? 0
				let closing = now.dateAt(hours: c_hour, minutes: c_min)
				
				if now >= opening &&
				  now <= closing
				{
				  return curr_index
				}
			}
		}
		
		//let schedule = self.storeDetails?.schedule?[dayOfWeek]
		
		return -1
	}
}
extension AddStoreOrderVC : UITextFieldDelegate{
	func textFieldDidBeginEditing(_ textField: UITextField) {
		print("Begin")
		let tag = textField.tag
		let btnType = tag / 100
		let row = tag % 100
		if row == arrOrders.count
		{
			if btnType == 2
			{
				textField.resignFirstResponder()
                ShowToast(message: "Please add Product Name.")
			}
		}
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		
		let tag = textField.tag
		let btnType = tag / 100
		let row = tag % 100
        var isMatchFound = false
        for order in arrOrders
        {
            if order.productname.lowercased() == (textField.text ?? "").lowercased()
            {
                isMatchFound = true
                ShowToast(message: "Product Name Already Added. \n Please increse Quentity of Product or Change Name.")
            }
        }
        if !(isMatchFound)
        {
            if row == arrOrders.count
            {
                if btnType == 1
                {
                    if !(textField.text?.isEmpty ?? true)
                    {
                        structOrderItems.productname =  textField.text ?? ""
                        arrOrders.append(structOrderItems)
                        structOrderItems = NewOrder()
                        //itemCount += 1
                        self.isAddMoreVisible = true
                        self.collectionView.reloadData()
                    }
                }
            }
            else
            {
                
                if btnType == 1
                {
                    //structOrderItems.productname =  textField.text ?? ""
                    if textField.text?.isEmpty ?? true
                    {
                        ShowToast(message: "Please add Product Name.")
                        textField.becomeFirstResponder()
                    }
                    else
                    {
                        arrOrders[row].productname = textField.text ?? ""
                        isAddMoreVisible = true
                        collectionView.reloadData()
                    }
                }
                else if btnType == 2
                {
                    if textField.text?.isEmpty ?? true
                    {
                        ShowToast(message: "Please add Product Quentity")
                        textField.becomeFirstResponder()
                    }
                    else
                    {
                        arrOrders[row].ProductQty = Int(textField.text ?? "") ?? 0
                        isAddMoreVisible = true
                        collectionView.reloadData()
                    }
                    
                }
            }
        }
	}
}
