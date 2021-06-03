//
//  OrderListVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 20/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class OrderListVC: BaseViewController {
    //CONSTANTS
    
    //VARIABLES
    var selectedTab = 1 // 1-Current 2-Past
    private lazy var currentOrderViewController: CurrentOrderVC = {
        // Instantiate View Controller
        var viewController = HomeStoryboard.instantiateViewController(withIdentifier: "CurrentOrderVC") as! CurrentOrderVC
        viewController.delegate = self
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var pastOrderViewController: PastOrderVC = {
    
        // Instantiate View Controller
        var viewController = HomeStoryboard.instantiateViewController(withIdentifier: "PastOrderVC") as! PastOrderVC
        viewController.delegate = self
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        //self.containerView.
        return viewController
    }()
    
    //IBOUTLETS
    @IBOutlet weak var btnCurrent: UIButton!
    @IBOutlet weak var btnPast: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTabContainer: UIView!
    @IBOutlet weak var stackTab: UIStackView!
    
    //MARK:- VC LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       isTabbarHidden(false)
       self.setupView()
   }
    
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
         
    }
     
    func setupGUI() {
         updateViewConstraints()
         self.view.layoutIfNeeded()
        
        
         lblTitle.text = "Orders"
         lblTitle.textColor = .white
         lblTitle.font = UIFont(name: fFONT_BOLD, size: 20.0)
         
        viewTabContainer.backgroundColor = .clear
        drawBorder(view: viewTabContainer, color: .white, width: 1.0, radius: 5.0)
        drawBorder(view: stackTab, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: btnCurrent, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: btnPast, color: .clear, width: 0.0, radius: 5.0)
        
        btnCurrent.backgroundColor = .white
        btnPast.backgroundColor = .clear
        btnCurrent.setTitle("Current", for: .normal)
        btnPast.setTitle("Past", for: .normal)
        btnCurrent.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 17.0))
        btnPast.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 17.0))
        btnCurrent.setTitleColor(THEME_COLOR, for: .selected)
        btnCurrent.setTitleColor(.white, for: .normal)
        btnPast.setTitleColor(THEME_COLOR, for: .selected)
        btnPast.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func TabValueChanged(_ sender: UIButton) {
        sender.backgroundColor = .white
        sender.isSelected = true
        if sender == btnCurrent{
            selectedTab = 1
            btnPast.backgroundColor = .clear
            btnPast.isSelected = false
        }else {
            selectedTab = 2
            btnCurrent.backgroundColor = .clear
            btnCurrent.isSelected = false
        }
        updateView()
    }
    
    //MARK:- Functions
    fileprivate func add(asChildViewController viewController: UIViewController) {
        // Add Child View as Subview
        viewContainer.addSubview(viewController.view)
    
        // Configure Child View
        viewController.view.frame = viewContainer.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
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
            remove(asChildViewController: pastOrderViewController)
            remove(asChildViewController: currentOrderViewController)
            add(asChildViewController: currentOrderViewController)
            break
        case 2:
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

extension OrderListVC : CurrentOrderVCDelegate {
    func naviagteToDetail(currentOrder: OrderDetail) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderDetails = currentOrder
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OrderListVC : PastOrderVCDelegate {
    func naviagteToDetail(pastOrder: OrderDetail) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderDetails = pastOrder
        vc.isFromPast = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
