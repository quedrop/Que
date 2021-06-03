//
//  UiViewController+Helper.swift
//  motiv8
//
//  Created by C100-104 on 22/01/19.
//  Copyright © 2019 C100-104. All rights reserved.
//

import UIKit



//import MMDrawerController

//extension UIViewController
//{
//    func hideMenu()
//    {
//         let button = UIButton(type: .custom)
//
//        button.setImage(UIImage(named: "ham-burger"), for: .normal)
//
//        button.addTarget(self, action: #selector(self.hideDrawer(_:)), for: .touchUpInside)
//
//        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//
//        let barButtonItem = UIBarButtonItem(customView: button)
//
//
//        navigationItem.leftBarButtonItem = barButtonItem
//
//    }
//
//    @objc func hideDrawer(_ sender: NSObject)
//    {
//        self.view.endEditing(true)
//        self.mm_drawerController.toggle(MMDrawerSide.left, animated: true, completion: nil)
//    }
//}


enum GradientDirection : Int {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}

extension UIView {
	func AddDashedborderTov() -> CAShapeLayer
	{
		let yourViewBorder = CAShapeLayer()
		yourViewBorder.strokeColor = THEME_COLOR.cgColor
		yourViewBorder.lineDashPattern = [4, 4]
		yourViewBorder.frame = self.bounds
		yourViewBorder.fillColor = nil
		yourViewBorder.path = UIBezierPath(rect: self.bounds).cgPath
		return yourViewBorder
	}
	
	
	func gradientBackground(ColorSet arrColor : [CGColor], direction : GradientDirection) {
        /*var arrCGColors : [CGColor] = [CGColor]()
        for color: UIColor? in arrColor {
            arrCGColors.append(color?.cgColor ?? UIColor.white.cgColor)
        }*/
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = arrColor
        gradientLayer.frame = self.bounds
        
        switch direction {
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            break;
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
            break;
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            break;
            
        case .TopLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            break;
            
        case .TopRightToBottomLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            break;
            
        case .BottomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            break;
            
        case .BottomRightToTopLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
            break;
            
        default: //Default Case is Top To Bottom
            break;
        }
        self.layer.insertSublayer(gradientLayer, at: 0)
      //  self.clipsToBounds = true
        
    }
	
    func tableView() -> UITableView? {
        var currentView: UIView = self
        while let superView = currentView.superview {
            if superView is UITableView {
                return (superView as! UITableView)
            }
            currentView = superView
        }
        return nil
    }
    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}

extension UIColor{
    class func getCustomYellowColor() -> UIColor{
        return UIColor(red:255/255, green:188/255 ,blue:12/255 , alpha:1.00)
    }
}

extension UIActivityIndicatorView
{
    //MARK:- ActivityIndicator Methods
    
    class func startActivityIndicator(activityIndicator: UIActivityIndicatorView , myview : UIView)
    {
        activityIndicator.center = myview.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.gray;
        myview.addSubview(activityIndicator);
        
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    class func stopActivityIndicator(activityIndicator: UIActivityIndicatorView)
    {
        
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
        
    }
}
extension UICollectionView
{
    class func setItemPerRow(uiCollectionView: UICollectionView , itemPerRow: Int)
    {
        let Size = (UIScreen.main.bounds.width / 3) - 10
        let CollectionViewlayout = UICollectionViewFlowLayout()
        CollectionViewlayout.itemSize = CGSize(width: Size, height: Size)
        //        CollectionViewlayout.minimumInteritemSpacing = 1
        //        CollectionViewlayout.minimumLineSpacing = 1
        uiCollectionView.collectionViewLayout = CollectionViewlayout
    }
}
extension UIViewController
{
   
    func updateNavigationButton(backBtnImageName: String, title:String , tintColor : UIColor , clearNav : Bool)
    {
        
        //self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Snell Roundhand", size: 25)!]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.layer.masksToBounds = false
		if title != ""
		{
			self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
			self.navigationController?.navigationBar.layer.shadowOpacity = 0.2
			self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10)
			self.navigationController?.navigationBar.layer.shadowRadius = 10
		}
		else
		{
			self.navigationController?.navigationBar.layer.shadowColor = UIColor.white.cgColor
			self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
			self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
			self.navigationController?.navigationBar.layer.shadowRadius = 0
		}
        
        self.navigationController?.navigationBar.tintColor = tintColor
        if clearNav
        {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        }
        else{
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.view.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
        }
        if title == ""
        {
            let logo = UIImage(named: "title")
            let imageView = UIImageView(image:logo)
            self.navigationItem.titleView = imageView
        }
        else
        {
            self.title = title
			if UIScreen.main.bounds.height > 600
            {
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor,                                                                        NSAttributedString.Key.font: UIFont(name: "Montserrat", size: 24)!]
            }
            else
            {
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : tintColor,                                                                        NSAttributedString.Key.font: UIFont(name: "Montserrat", size: 18)!]
            }
        }
         self.navigationItem.hidesBackButton = true
        if backBtnImageName != ""
        {
           
            let newBackButton = UIBarButtonItem(title: "",
                                                style: UIBarButtonItem.Style.plain,
                                                target: self,
                                                action: #selector(self.back(sender:)))
            newBackButton.image = UIImage(named: backBtnImageName)
            self.navigationItem.leftBarButtonItem = newBackButton
        }
        
    }
    @objc func back(sender: UIBarButtonItem)
    {
        
        self.navigationController?.popViewController(animated: true)
    }
  @objc func showAlertForTwoSec(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showAlert(title: String, message: String )
    {
        // create the alert
        let alert = UIAlertController(title: title  , message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    @objc func showAlert(title: String, message: String, completion: @escaping (UIAlertAction) -> Void)
    {
        // create the alert
        let alert = UIAlertController(title: title  , message: message, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: completion))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    
    }
    func setProgress()
    {
//        let iprogress: iProgressHUD = iProgressHUD()
//        iprogress.isShowModal = false
//        iprogress.isShowCaption = true
//        iprogress.iprogressStyle = .horizontal
//        iprogress.isTouchDismiss = false
//        iprogress.attachProgress(toView: self.view)
//
//        view.updateCaption(text: "Please Wait")
//        view.updateIndicator(style: .ballRotateChase)
    }
    
}




extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.6, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
}
extension UIImageView{
    func circularImageView() {
    
        
    /*
         if screenHeight > 600
        {
                self.layer.cornerRadius = (self.frame.size.width / 2) + 7
        }
        else
        {
            self.layer.cornerRadius = (self.frame.size.width / 2) - 5
        }
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.8
        self.layer.masksToBounds = true
    */
    }
}
