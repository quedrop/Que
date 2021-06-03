//
//  OrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 13/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class OrderVC: BaseViewController  {

    @IBOutlet weak var imgPlaceholder: UIImageView!
    @IBOutlet weak var viewGuestOrder: UIView!
    @IBOutlet var btnCurrent: UIButton!
	@IBOutlet var btnFuture: UIButton!
	@IBOutlet var btnPast: UIButton!
	@IBOutlet var containerView: UIView!
    @IBOutlet var viewTab: UIView!
    @IBOutlet weak var lblNotAvailable: UILabel!
    @IBOutlet weak var lblGuestTitle: UILabel!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblGuestSubtitle: UILabel!
    //ViewControllers
	
	private lazy var currentOrderViewController: CurrentOrderVC = {
	
		// Instantiate View Controller
		var viewController = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "CurrentOrderVC") as! CurrentOrderVC
		viewController.delegate = self
		// Add View Controller as Child View Controller
		self.add(asChildViewController: viewController)
		//self.containerView.
		return viewController
	}()
	
	private lazy var pastOrderViewController: PastOrderVC = {
	
		// Instantiate View Controller
		var viewController = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "PastOrderVC") as! PastOrderVC
		viewController.delegate = self
		// Add View Controller as Child View Controller
		self.add(asChildViewController: viewController)
		//self.containerView.
		return viewController
	}()
	
	//Variables
	var selectedTab = 1 // 1-Current  / 2-Feature / 3-Past
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        drawBorder(view: viewTab, color: .white, width: 1.0, radius: 5.0)
        lblNotAvailable.isHidden = true
        self.SegmentValueChanged(btnCurrent)
        setUpUI()
    }
	override func viewDidAppear(_ animated: Bool) {
		self.setupView()
	}
    override func viewWillAppear(_ animated: Bool) {
		isTabbarHidden(false)
        if isGuest {
            viewGuestOrder.isHidden = false
        } else{
            viewGuestOrder.isHidden = true
        }
		//UpdateTabBar(index: tabBarIndex.order.rawValue)
	}
    
    func setUpUI() {
        viewGuestOrder.backgroundColor = VIEW_BG_COLOR
        btnLogin.backgroundColor = THEME_COLOR
        lblGuestTitle.font = UIFont(name: fFONT_BOLD, size: calculateFontForWidth(size: 30.0))
        lblGuestSubtitle.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 17.0))
        imgPlaceholder.image = tintedWithLinearGradientColors(colorsArr: GRADIENT_ARRAY, img : UIImage(named: "order_placeholder")!)
        imgPlaceholder.alpha = 0.7
        lblGuestTitle.textColor = THEME_COLOR
        btnLogin.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 17.0))
        
    }
	@IBAction func SegmentValueChanged(_ sender: UIButton) {
		
		
		if sender.tag == 10{
            sender.backgroundColor = .white
			sender.isSelected = true
			selectedTab = 1
			btnFuture.backgroundColor = .clear
			btnFuture.isSelected = false
			lblNotAvailable.isHidden = true
			btnPast.backgroundColor = .clear
			btnPast.isSelected = false
		}else if sender.tag == 20{
			sender.backgroundColor = .white
			sender.isSelected = true
			selectedTab = 2
			btnCurrent.backgroundColor = .clear
			btnCurrent.isSelected = false
			lblNotAvailable.isHidden = false
			btnPast.backgroundColor = .clear
			btnPast.isSelected = false
		}else if sender.tag == 30{
            sender.backgroundColor = .white
			sender.isSelected = true
			selectedTab = 3
			btnFuture.backgroundColor = .clear
			btnFuture.isSelected = false
			lblNotAvailable.isHidden = true
			btnCurrent.backgroundColor = .clear
			btnCurrent.isSelected = false
		}
		updateView()
	}
	
    @IBAction func btnLoginClicked(_ sender: Any) {
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
    
	//MARK:- Functions
	fileprivate func add(asChildViewController viewController: UIViewController) {
		// Add Child View as Subview
		containerView.addSubview(viewController.view)
	
		// Configure Child View
		viewController.view.frame = containerView.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	/*private func add(asChildViewController viewController: UIViewController) {
		// Add Child View Controller
		addChildViewController(viewController)
	
		// Add Child View as Subview
		view.addSubview(viewController.view)
	
		// Configure Child View
		viewController.view.frame = view.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	
		// Notify Child View Controller
		viewController.didMove(toParentViewController: self)
	}*/
	private func remove(asChildViewController viewController: UIViewController) {
		// Notify Child View Controller
		viewController.willMove(toParent: nil)
	
		// Remove Child View From Superview
		viewController.view.removeFromSuperview()
	
		// Notify Child View Controller
		viewController.removeFromParent()
	}
	private func updateView() {
		switch selectedTab {
		case 1:
//			remove(asChildViewController: sessionsViewController)
			remove(asChildViewController: pastOrderViewController)
			remove(asChildViewController: currentOrderViewController)
			add(asChildViewController: currentOrderViewController)
			break
		case 2:
			remove(asChildViewController: pastOrderViewController)
			remove(asChildViewController: currentOrderViewController)
			break
		case 3:
			remove(asChildViewController: currentOrderViewController)
			remove(asChildViewController: pastOrderViewController)
			add(asChildViewController: pastOrderViewController)
			break
		default:
			break
		}
	}
	func setupView() {
		updateView()
	}
}
extension OrderVC : NavigatefromChildViewControllerDelegate{
    func navigateToDetails(OrderObj: CurrentOrder, isPastOrder: Bool) {
        let nextViewController = CustomerOrdersStoryboard.instantiateViewController(withIdentifier: "OrderDetailsVC") as! OrderDetailsVC
        let orderId  = OrderObj.orderId ?? 0
        nextViewController.orderId = orderId
        //nextViewController.setOrderId(orderId, isPastOrder)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
