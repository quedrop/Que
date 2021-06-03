//
//  EarningVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 21/05/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

class EarningVC: BaseViewController {
    
    //CONSTANTS
    
    //VARIABLES
    var selectedTab = 1 // 1-Current 2-Past
    var fromHomeEarning : Bool = false
    private lazy var ManualEarningViewController: ManualStoreEarningVC = {
        // Instantiate View Controller
        var viewController = HomeStoryboard.instantiateViewController(withIdentifier: "ManualStoreEarningVC") as! ManualStoreEarningVC
        viewController.delegate = self
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var WeeklyEarningViewController: WeeklyEarningVC = {
        
        // Instantiate View Controller
        var viewController = HomeStoryboard.instantiateViewController(withIdentifier: "WeeklyEarningVC") as! WeeklyEarningVC
        viewController.delegate = self
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        //self.containerView.
        return viewController
    }()
    
    //IBOUTLETS
    @IBOutlet weak var btnManual: UIButton!
    @IBOutlet weak var btnWeekly: UIButton!
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
        
        if APP_DELEGATE!.FromHomeEarning {
            APP_DELEGATE!.FromHomeEarning = false
            openWeeklyEarning()
        }
    }
    
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        
    }
    
    func setupGUI() {
        updateViewConstraints()
        self.view.layoutIfNeeded()
        
        
        lblTitle.text = "Earnings"
        lblTitle.textColor = .black
        lblTitle.font = UIFont(name: fFONT_BOLD, size: 20.0)
        
        viewTabContainer.backgroundColor = THEME_COLOR
        drawBorder(view: viewTabContainer, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: stackTab, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: btnManual, color: .clear, width: 0.0, radius: 5.0)
        drawBorder(view: btnWeekly, color: .clear, width: 0.0, radius: 5.0)
        
        btnManual.backgroundColor = THEME_COLOR
        btnWeekly.backgroundColor = .white
        btnManual.setTitle("Manual Store Payment", for: .normal)
        btnWeekly.setTitle("Earn Payment", for: .normal)
        btnManual.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        btnWeekly.titleLabel?.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 13.0))
        btnManual.setTitleColor(.white, for: .selected)
        btnManual.setTitleColor(THEME_COLOR, for: .normal)
        btnWeekly.setTitleColor(.white, for: .selected)
        btnWeekly.setTitleColor(THEME_COLOR, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openWeeklyEarning), name: NSNotification.Name(ncNOTIFICATION_WEEKLY_PAYMENT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openManualEarning), name: NSNotification.Name(ncNOTIFICATION_MANUAL_PAYMENT), object: nil)
    }
    
    // MARK: - BUTTONS ACTION
    @IBAction func TabValueChanged(_ sender: UIButton) {
        
        if sender == btnManual{
            sender.backgroundColor = THEME_COLOR
            sender.isSelected = true
            selectedTab = 1
            btnWeekly.backgroundColor = .white
            btnWeekly.isSelected = false
        }else {
            sender.backgroundColor = THEME_COLOR
            sender.isSelected = true
            selectedTab = 2
            btnManual.backgroundColor = .white
            btnManual.isSelected = false
        }
        updateView()
    }
    
    @objc func openWeeklyEarning() {
        if selectedTab == 1 {
            TabValueChanged(btnWeekly)
        }
        
    }
    
    @objc func openManualEarning() {
        if selectedTab == 2 {
            TabValueChanged(btnManual)
        }
        
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
            remove(asChildViewController: WeeklyEarningViewController)
            remove(asChildViewController: ManualEarningViewController)
            add(asChildViewController: ManualEarningViewController)
            break
        case 2:
            remove(asChildViewController: ManualEarningViewController)
            remove(asChildViewController: WeeklyEarningViewController)
            add(asChildViewController: WeeklyEarningViewController)
            break
        default:
            break
        }
    }
    func setupView() {
        updateView()
    }
}

extension EarningVC : ManualStoreEarningVCDelegate {
    func naviagteToDetail(objOrder : OrderDetail) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderDetails = objOrder
        vc.isFromPast = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension EarningVC : WeeklyEarningVCDelegate {
    func naviagteToDetail(obj : OrderDetail) {
        let vc = HomeStoryboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderDetails = obj
        vc.isFromPast = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
