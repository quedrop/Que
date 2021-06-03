//
//  UITableView+Extension.swift
//  Freddy
//
//  Created by C100-107 on 22/05/19.
//  Copyright © 2019 C100-107. All rights reserved.
//

import Foundation
import UIKit
extension UITableView{
    func register(_ cellClass: String) {
        register(UINib(nibName: cellClass, bundle: nil), forCellReuseIdentifier: cellClass)
    }

	func scrollToBottom(){
		
		DispatchQueue.main.async {
			let indexPath = IndexPath(
				row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
				section: self.numberOfSections - 1)
			if (self.numberOfRows(inSection:  self.numberOfSections - 1) - 1) >= 0{
				self.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
			
		}
	}
    func scrollToTop() {
        setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        DispatchQueue.main.async {
//            let indexPath = IndexPath(row: 0, section: 0)
//            self.scrollToRow(at: indexPath, at: .top, animated: false)
//        }
    }
	
	func setFootertView() {
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 65))
		tableFooterView = footerView
	}
	
	
	func getFrame(ofIndexPath indexPath: IndexPath) -> CGRect {
		   let rect = self.rectForRow(at: indexPath)
		   return self.convert(rect, to: self.superview)
	}
	
    
    func setHeaderFootertView(headHeight: CGFloat, footHeight: CGFloat) {
        var view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: headHeight))
        tableHeaderView = view
        
        view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: footHeight))
        tableFooterView = view
    }
	
    func setRows(_ array: [Any], noDataTitle title: String, message: String, font: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)) -> Int {
        let totalCount = array.count
        
        if totalCount == 0 {
            setEmptyView(title: title, message: message, font: font)
        } else {
            restore()
        }
        
        return array.count
    }
    
    private func setEmptyView(title: String, message: String, font: UIFont) {
        self.backgroundView = self.getEmptyView(title: title, message: message, font: font)
        self.separatorStyle = .none
    }
    
    public func restore() {
        self.backgroundView = nil
    }
}

