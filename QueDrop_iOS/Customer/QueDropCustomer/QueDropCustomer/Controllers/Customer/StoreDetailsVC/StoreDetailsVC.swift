//
//  StoreDetailsVC.swift
//  QueDrop
//
//  Created by C100-104 on 05/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import ImageSlideshow
import CoreLocation
class StoreDetailsVC: BaseViewController {

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var btnBack: UIButton!
	@IBOutlet var btnLike: UIButton!
	@IBOutlet var btnSearch: UIButton!
	@IBOutlet var shimmerView: UIScrollView!
    @IBOutlet weak var lblCategoriesNotAvailable: UILabel!
    
	
	//vaiable
	var storeId = 0
	var storeDetails : StoreDetail?
    var arrFoodCategory : [FoodCategory] = []
    var arrFreshProducedCategory : [FoodCategory] = []
    var CategoryType : Int = 1
    
	override func viewDidLoad() {
        super.viewDidLoad()
        lblCategoriesNotAvailable.isHidden = true
		shimmerView.isHidden = false
		self.btnLike.isEnabled = false
		self.btnSearch.isEnabled = false
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		self.getStoreDetails(storeId : storeId)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.default
    }
	override var preferredStatusBarStyle: UIStatusBarStyle {
		  return .lightContent
	}
    
    //MARK:- Action Methods
	@IBAction func actionBack(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionLike(_ sender: UIButton) {
		if isGuest
		{
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
		}
		else
		{
			if self.storeDetails?.isFavourite ?? false
			{
				self.markAsFavourite(favouriteStatus: 0 , StoreId: self.storeDetails?.storeId ?? 0)
				sender.isSelected = false
			}
			else
			{
				self.markAsFavourite(favouriteStatus: 1 , StoreId: self.storeDetails?.storeId ?? 0)
				sender.isSelected = true
			}
		}
	}
	@IBAction func actionSearch(_ sender: UIButton) {
		let id = storeDetails?.storeId ?? 0
		let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreItemsVC") as! StoreItemsVC
        nextViewController.setStoreId(storeId: id, isSearch: true, SelectedCatIndex: 0, isFreshProduce: CategoryType == 1 ? false : true)
		self.navigationController?.pushViewController(nextViewController, animated: true)
		
	}
	//MARK:- function Methods
	func setStoreId(storeId : Int)
	{
		self.storeId = storeId
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

extension StoreDetailsVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
	
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
		
			headerView.lblCollectionTitle.text = "Categories"
		
		headerView.lblstoretitle.text = self.storeDetails?.storeName ?? ""
		headerView.lblRating.text = "\(self.storeDetails?.storeRating ?? 0.0)"
		headerView.lblStoreAddress.text  = self.storeDetails?.storeAddress ?? ""
		var isOpen = false
		/*
		if self.storeDetails?.canProvideService ?? 0 == 1
		{
			isOpen = true
			combination.append(setText(text: "Open now", textColor: .green))
		}
		else
		{
			isOpen = false
			combination.append(setText(text: "Close now", textColor: .red))
		}*/
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
			if isOpen
			{
					combination.append(setText(text: " - ", textColor: .green))
			} else {
					combination.append(setText(text: " - ", textColor: .red))
			}
			
			
			let timing = storeDetails?.schedule![dayOfWeek]
			combination.append(setText(text: " \(timing?.openingTime?.dropLast(3) ?? "00:00") - \(timing?.closingTime?.dropLast(3) ?? "00:00")(today)", textColor: .darkGray))

		}
		headerView.lblStoreTiming.attributedText = combination
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
			headerView.imageStoreLogo.sd_setImage(with: URL(string: logoURL), placeholderImage: QUE_AVTAR, completed: nil)
			headerView.imageStoreLogo.layer.cornerRadius = 3
			headerView.imageStoreLogo.clipsToBounds = true
		}
		self.btnLike.isSelected = self.storeDetails?.isFavourite ?? false
		
        //FOR CATEGORIES AND FRESH PRODUCED
        
           if arrFreshProducedCategory.count > 0 {
            headerView.viewSeparator.isHidden = false
            headerView.btnFreshProduce.isHidden = false
           } else {
            headerView.viewSeparator.isHidden = true
            headerView.btnFreshProduce.isHidden = true
           }
           headerView.btnCategory.addTarget(self, action: #selector(btnCategoriesClicked(sender:)), for: .touchUpInside)
           headerView.btnFreshProduce.addTarget(self, action: #selector(btnFreshProducedClicked(sender:)), for: .touchUpInside)
           
           if CategoryType == 1 {
            headerView.btnCategory.setTitleColor(.black, for: .normal)
            headerView.btnFreshProduce.setTitleColor(.lightGray, for: .normal)
           } else {
            headerView.btnCategory.setTitleColor(.lightGray, for: .normal)
            headerView.btnFreshProduce.setTitleColor(.black, for: .normal)
           }
		return headerView
		 default:
		   // 4
		   assert(false, "Invalid element type")
		 }
		return UICollectionReusableView()
	}
	
    @objc func btnCategoriesClicked(sender : UIButton) {
        CategoryType = 1
        self.collectionView.reloadData()
    }
	@objc func btnFreshProducedClicked(sender : UIButton) {
        CategoryType = 2
        self.collectionView.reloadData()
    }
    
    
	func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = CGSize(width: 300, height: 100)
		size = CGSize(width: (collectionView.bounds.width / 2 )  , height: (200) )
		return size
	}
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0.0
	}

	func collectionView(_ collectionView: UICollectionView, layout
		collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  CategoryType == 1 ? arrFoodCategory.count : arrFreshProducedCategory.count   //self.storeDetails?.foodCategory?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCategoriesCVCell", for: indexPath) as? ItemCategoriesCVCell
		if let detailObj = self.storeDetails
		{
			// if let catObj = detailObj.foodCategory?[indexPath.row]
            let catObj = CategoryType == 1 ? arrFoodCategory[indexPath.row] : arrFreshProducedCategory[indexPath.row]
			//{
				cell?.lblRating.text = "\(detailObj.storeRating ?? 0.0)"
				cell?.lblCategoryTitle.text = catObj.storeCategoryTitle ?? ""
				cell?.lblCategoryOffer.text = "---"
				let imgURL = "\(URL_STORE_CATEGORY_IMAGES)\(catObj.storeCategoryImage ?? "")"
				cell?.imageCategory.sd_setImage(with: URL(string: imgURL), placeholderImage: CATEGORY_AVTAR, completed: nil)
			//}
		}
		return cell ?? UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let id = storeDetails?.storeId ?? 0
		let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreItemsVC") as! StoreItemsVC
		nextViewController.setStoreId(storeId: id, isSearch: false, SelectedCatIndex: indexPath.row, isFreshProduce: CategoryType == 1 ? false : true)
		self.navigationController?.pushViewController(nextViewController, animated: true)
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
