//
//  ConfirmDeliveryVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 01/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import FloatRatingView

class ConfirmDeliveryVC: UIViewController {
    //CONSTANTS
       
    //VARIABLES
    var orderDetails : OrderDetail?
    
    //IBOUTLETS
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCustomer: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewCustomerInfo: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewrating: FloatRatingView!
    @IBOutlet weak var btnGiveRating: UIButton!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        allNotificationCenterObservers()
        initializations()
        setupGUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadOrderData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: ncNOTIFICATION_ORDER_DELIVERED), object: nil)
    }
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        
    }
     
    func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
         
        viewBG.backgroundColor = VIEW_BACKGROUND_COLOR
        viewrating.isUserInteractionEnabled = false
         lblTitle.text = "Confirmed order delivery"
         lblTitle.textColor = .white
         lblTitle.font = UIFont(name: fFONT_MEDIUM, size: 20.0)
        
         lblInfo.text = "Scanned Customer\n QR Code"
         lblInfo.textColor = .lightGray
         lblInfo.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 22.0))
                
        lblCustomer.textColor = .black
        lblCustomer.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
        
        lblPhoneNumber.textColor = .lightGray
        lblPhoneNumber.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 12.0))
        
        makeCircular(view: imgUser)
        drawBorder(view: btnGiveRating, color: THEME_COLOR, width: 0.6, radius: 5.0)
        drawBorder(view: btnChat, color: .clear, width: 0.0, radius: 5.0)
        
        btnGiveRating.backgroundColor = .clear
        btnGiveRating.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))
        btnGiveRating.setTitle("Give Review", for: .normal)
        btnGiveRating.setTitleColor(THEME_COLOR, for: .normal)
        
        btnChat.backgroundColor = THEME_COLOR
        btnChat.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 13.0))
        btnChat.setTitle("Chat", for: .normal)
        btnChat.setTitleColor(.white, for: .normal)
        
       /* viewCustomerInfo.layer.shadowColor = UIColor.black.cgColor
        viewCustomerInfo.layer.shadowOffset = CGSize(width: 1, height: 1)
        viewCustomerInfo.layer.shadowRadius = 4
        viewCustomerInfo.layer.shadowOpacity = 1
        */
        
        
        
        viewCustomerInfo.addShadow(location: .top)
        loadOrderData()
    }
    
    func allNotificationCenterObservers() {
          NotificationCenter.default.addObserver(self, selector: #selector(orderDeliveredNotification(notification:)), name: NSNotification.Name(rawValue: ncNOTIFICATION_ORDER_DELIVERED), object: nil)
    }
    
    //MARK:- LOAD ORDER DATA
    func loadOrderData() {
       let objCustomer = orderDetails?.customerDetail
        if (objCustomer?.firstName!.length)! > 0 {
            lblCustomer.text = "\(objCustomer?.firstName ?? "") \(objCustomer?.lastName ?? "")"
        } else {
            lblCustomer.text = "\(objCustomer?.email?.components(separatedBy: "@")[0] ?? "")"
        }
        lblPhoneNumber.text = "+\(objCustomer?.countryCode ?? 0) \(objCustomer?.phoneNumber ?? "")"
        if let imgUrl = objCustomer?.userImage{
            imgUser.sd_setImage(with: imgUrl.getUserImageURL(), placeholderImage: UIImage(named: "avtar"),completed : nil)
        }
        else {
            imgUser.image = UIImage(named: "avtar")
        }
        viewrating.rating = Double(objCustomer!.rating!)
        imgQRCode.image = generateQRCode(from: "\(orderDetails!.orderId!)")
        imgQRCode.layer.magnificationFilter = CALayerContentsFilter.nearest
    }
    
    //MARK: - BUTTON ACTIONS
    
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnGiveRatingClicked(_ sender: Any) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "GiveReviewVC") as! GiveReviewVC
        vc.orderId = orderDetails?.orderId
        vc.customerId = orderDetails?.customerDetail?.userId
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnChatClicked(_ sender: Any) {
        if let objCustomer = orderDetails?.customerDetail {
            var name = "\(objCustomer.firstName ?? "") \(objCustomer.lastName ?? "")"
            if (objCustomer.firstName!.length) > 0 {
                name = "\(objCustomer.firstName ?? "") \(objCustomer.lastName ?? "")"
            } else {
                name = "\(objCustomer.email?.components(separatedBy: "@")[0] ?? "")"
            }
            let imgUrl = (objCustomer.userImage?.isValidUrl())! ? objCustomer.userImage ?? "" : "\(URL_USER_IMAGES)\(objCustomer.userImage ?? "")"
            let strId = objCustomer.userId
            
            let nextViewController = HomeStoryboard.instantiateViewController(withIdentifier: "DriverChatVC") as! DriverChatVC
           nextViewController.receiver_id = strId!
           nextViewController.receiver_name = name
           nextViewController.receiver_profile = imgUrl
            nextViewController.orderId = orderDetails?.orderId ?? 0
            nextViewController.orderStatus = orderDetails?.orderStatus ?? ""
           self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    //MARK: - GENERATE QR CODE
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    @objc func orderDeliveredNotification(notification : Notification) {
        if let dic = notification.userInfo {
            if dic["order_id"] as? Int == orderDetails?.orderId {
                navigationController?.popViewControllers(viewsToPop: 2)
            }
        }
    }
}

extension UINavigationController {

  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
      popToViewController(vc, animated: animated)
    }
  }

  func popViewControllers(viewsToPop: Int, animated: Bool = true) {
    if viewControllers.count > viewsToPop {
      let vc = viewControllers[viewControllers.count - viewsToPop - 1]
      popToViewController(vc, animated: animated)
    }
  }

}

