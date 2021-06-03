//
//  ImageViewerVC.swift
//  QueDrop
//
//  Created by C100-104 on 31/03/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

class ImageViewerVC: UIViewController {

	@IBOutlet var imgView: UIImageView!
	@IBOutlet var btnClose: UIButton!
	
	
	var image : UIImage? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

		if image != nil
		{
			imgView.image = image
		}
    }
	func setImage(image : UIImage)
	{
		self.image = image
	}
	@IBAction func actionClose(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
		self.navigationController?.popViewController(animated: true)
	}
	
}
