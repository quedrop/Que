//
//  DeleteCustomView.swift
//  QueDrop
//
//  Created by C100-104 on 02/01/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
@objc protocol DeleteCustomViewDelegate {
	func dismissDialog()
    @objc optional func deleteAddress()
    @objc optional func deleteStore(storeId : Int)
}
class DeleteCustomView: BaseViewController {

	@IBOutlet var topImageView: UIImageView!
	@IBOutlet var lblText: UILabel!
	@IBOutlet var btnCancel: UIButton!
	@IBOutlet var btnOk: UIButton!
	var delegate : DeleteCustomViewDelegate?
    var isDeleteForCart : Bool = false
    var strMessage = ""
    var storeId : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblText.text = strMessage
    }

	@IBAction func actionCancel(_ sender: Any) {
		delegate?.dismissDialog()
	}
	@IBAction func actionOk(_ sender: Any) {
        if isDeleteForCart {
            delegate?.deleteStore?(storeId: storeId)
        } else {
            delegate?.deleteAddress?()
        }
        
	}
	
	func showDeleteView(viewDisplay: UIView)
	{
		self.view.frame = CGRect(x: 0, y: viewDisplay.frame.height, width: viewDisplay.frame.width, height: self.view.frame.size.height)
		NSLog("%@", NSCoder.string(for: self.view.frame))
		viewDisplay.addSubview(self.view!)
		UIView.animate(withDuration: 0.3, animations: {() -> Void in
			self.view.frame = CGRect(x: 0, y: viewDisplay.frame.height - self.view.frame.size.height, width: viewDisplay.frame.width, height: self.view.frame.size.height)
		}, completion: {(finished: Bool) -> Void in
		})
		
	}
	
	func hideView()
	{
		self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - self.view.frame.size.height, width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height)
		UIView.animate(withDuration: 0.3, animations: {() -> Void in
			self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height)
		}, completion: {(finished: Bool) -> Void in
			self.view!.removeFromSuperview()
		})
		//delegate?.dismissDialog()
	}
}
