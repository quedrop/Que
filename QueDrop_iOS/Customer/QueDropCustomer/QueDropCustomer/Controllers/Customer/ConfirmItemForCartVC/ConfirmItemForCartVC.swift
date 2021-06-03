//
//  ConfirmItemForCartVC.swift
//  QueDrop
//
//  Created by C100-104 on 14/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import SDWebImage
import ImageSlideshow
import CoreLocation

class ConfirmItemForCartVC: BaseViewController {

    @IBOutlet var btnback: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var viewImageSlider: ImageSlideshow!
    @IBOutlet var imageStoreLogo: UIImageView!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblStoreName: UILabel!
    @IBOutlet var lblStoreAddress: UILabel!
    @IBOutlet var lblStoreTiming: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblAddons: UILabel!
    @IBOutlet var lblNoOfQty: UILabel!
    @IBOutlet var lblTotalAmt: UILabel!
    @IBOutlet var btnMinusQty: UIButton!
    @IBOutlet var btnIncreseQty: UIButton!
    @IBOutlet var btnCustomise: UIButton!
    @IBOutlet var lblTotalAmtBottom: UILabel!
    @IBOutlet var btnAddToCart: UIButton!
    @IBOutlet var viewQty: UIView!
    @IBOutlet var customiseButtonConstraint: NSLayoutConstraint!
    
    
    //var
    var ProductAmtWithAddons : Float = structCustomerTempCart.ItemFinalAmmount
    var storeDetails = structCustomerTempCart.store
    
    var arrimg: [InputSource] = []
    var productFinalAmt : Float = 0.0{
        didSet{
            self.lblTotalAmt.text = "\(Currency)\(productFinalAmt)"
            self.lblTotalAmtBottom.text = "Item total \(Currency)\(productFinalAmt)"
            structCustomerTempCart.ItemFinalAmmount = Float(productFinalAmt)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewQty.layer.borderWidth = 0.5
        self.viewQty.layer.borderColor = UIColor.darkGray.cgColor
        customiseButtonConstraint.constant = (structCustomerTempCart.product?.hasAddons ?? 0 == 1) ? 15 : 0
        self.setData()
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

    @IBAction func actionShowCustomization(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionIncreseQty(_ sender: UIButton) {
        var currQty = Int(lblNoOfQty.text ?? "1") ?? 1
        currQty += 1
        if currQty > 1
        {
            //sender.isEnabled = true
            btnMinusQty.setImage(UIImage(), for: .normal)
            btnMinusQty.setTitle("-", for: .normal)
        }
        self.lblNoOfQty.text = "\(currQty)"
        updateQty(qty: currQty)
    }
    @IBAction func actionMinusQty(_ sender: UIButton) {
        var currQty = Int(lblNoOfQty.text ?? "1") ?? 1
        if currQty == 1
        {
            IsItemDiscard = true
            if structCustomerTempCart.product?.hasAddons ?? 0 == 1 || structCustomerTempCart.product?.productOption?.count ?? 1 > 1
            {
                popTwoViewBack()
            }
            else
            {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
        currQty = currQty - 1
        self.lblNoOfQty.text = "\(currQty)"
        if currQty < 2
        {
            //sender.isEnabled = false
            btnMinusQty.setImage(#imageLiteral(resourceName: "bin_gray"), for: .normal)
            btnMinusQty.setTitle("", for: .normal)
            
        }
        updateQty(qty: currQty)
    }
    @IBAction func actionAddToCart(_ sender: UIButton) {
        structCartAry.CartItemsAry.append(structCustomerTempCart)
        self.addItemToCart()
    }
    
    //MARK:- custom Methods
    
    func setData()
    {
        self.lblNoOfQty.text = "\(structCustomerTempCart.productQty)"
        if structCustomerTempCart.productQty < 2
        {
            //sender.isEnabled = false
            btnMinusQty.setImage(#imageLiteral(resourceName: "bin_gray"), for: .normal)
            btnMinusQty.setTitle("", for: .normal)
            
        }
        else
        {
            btnMinusQty.setImage(UIImage(), for: .normal)
            btnMinusQty.setTitle("-", for: .normal)
        }
        self.lblStoreName.text = storeDetails?.storeName ?? ""
        self.lblStoreTiming.text = ""
        self.lblStoreAddress.text = storeDetails?.storeAddress ?? ""
        self.lblDistance.text = ""
        self.lblRating.text =  "\(storeDetails?.storeRating ?? 0.0)"
        self.lblItemName.text = structCustomerTempCart.product?.productName ?? ""
        self.lblAddons.text = ""
        self.productFinalAmt = ProductAmtWithAddons * Float(structCustomerTempCart.productQty)
        //addonText
        setAddonText()
        //timing
        var isOpen = false
        var combination = NSMutableAttributedString()
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
            isOpen = self.matchTiming(dayOfWeek: dayOfWeek)
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
            combination.append(setText(text: " \(timing?.openingTime?.dropLast(3) ?? "00:00") am - \(timing?.closingTime?.dropLast(3) ?? "00:00") pm(today)", textColor: .darkGray))

        }
        self.lblStoreTiming.attributedText = combination
        
        //set ImageSlider
        arrimg.removeAll()
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
                            self.arrimg.append(imgDown!)
                            image_is_available_count  += 1
                        }
                        else
                        {
                            self.arrimg.append(ImageSource(image: UIImage(named: "NoImage")!))
                        }
                    }
                }
            }
        }
        self.viewImageSlider.setImageInputs(self.arrimg)
        self.viewImageSlider.contentScaleMode = .scaleAspectFill
        //Distance
        self.lblDistance.text = distance(lat1: Double(storeDetails?.latitude ?? "0.0") ?? 0.0, lon1: Double(storeDetails?.longitude ?? "0.0") ?? 0.0)
        //Profile Image
        if let imageName = self.storeDetails?.storeLogo
        {
            let logoURL = "\(URL_STORE_LOGO_IMAGES)\(imageName)"
            self.imageStoreLogo.sd_setImage(with: URL(string: logoURL), placeholderImage: QUE_AVTAR , completed: nil)
            self.imageStoreLogo.layer.cornerRadius = 3
            self.imageStoreLogo.clipsToBounds = true
        }
        //Like Button
        self.btnLike.isSelected = self.storeDetails?.isFavourite ?? false
    }
    func setAddonText()
    {
        
        var tmpAddons : [Addons] = []
        var addonName : [String] = []
        let productId = structCustomerTempCart.productId ?? 0
        let addons = structCustomerTempCart.productAddons
        
            for index in 0..<addons.count
            {
                let dict = addons[index]
                if let addon = dict[productId]
                {
                    tmpAddons.append(addon)
                    addonName.append(addon.addonName ?? "")
                }
            }
        
        addonName.append(structCustomerTempCart.selectedOptions?.optionName ?? "")
        let addonText = addonName.joined(separator: ", ")
        self.lblAddons.text = addonText
    }
    func updateQty(qty : Int)
    {
        structCustomerTempCart.productQty = qty
        let amt = ProductAmtWithAddons
        //amt += structCustomerTempCart.selectedOptions?.price ?? 0
        let finalAmt = amt * Float(qty)
        self.productFinalAmt = finalAmt
    }
    
    //set Attirbuted Text
    func setText(text: String , textColor : UIColor) -> NSMutableAttributedString
    {
        let myString = text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        let myAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColor , NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let myAttrString = NSMutableAttributedString(string: myString, attributes: myAttribute)
        return myAttrString
    }
    //Match Store Timimg
    func matchTiming(dayOfWeek : Int) -> Bool
    {
        let now = Date()
        let schedule = self.storeDetails?.schedule?[dayOfWeek]
        let openingTime = schedule?.openingTime ?? ""
        let o_hour = Int(openingTime.dropLast(6)) ?? 0
        let o_min = Int((openingTime.dropLast(3)).dropFirst(3)) ?? 0
        let opening = now.dateAt(hours: o_hour, minutes: o_min)
        let closingTime = schedule?.closingTime ?? ""
        let c_hour = Int(closingTime.dropLast(6)) ?? 0
        let c_min = Int((closingTime.dropLast(3)).dropFirst(3)) ?? 0
        let closing = now.dateAt(hours: c_hour, minutes: c_min)
        
        if now >= opening &&
          now <= closing
        {
          return true
        }
        return false
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
        }
        else
        {
            print("Minit : ",time.rounded(toPlaces: 0))
        }
        
        
        let distanceInKM = distanceInMeters / 1000
        if distanceInMeters >= 1000
        {
            return "\(distanceInKM.rounded(toPlaces: 2)) km"
        }
        else
        {
            return "\(distanceInMeters.rounded(toPlaces: 2)) meters"
        }
        return "\(distanceInKM)"
        
        
    }
}
