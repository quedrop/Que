//
//  TableViewAlert.swift
//  Tournament
//
//  Created by C100-105 on 03/01/20.
//  Copyright © 2020 C100-105. All rights reserved.
//

import UIKit

class TableViewAlert: BaseAlertViewController {
    
    var tblValues = UITableView()
    var blurrView = AlertBlurrView()
    
    var selectedIndex = -1
    var cellSize: CGFloat = 40
    var arrOfData: [String] = []
    var callback: ((String, Int) -> ())? = nil
    
    //MARK: - VC life cycle callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurrView = AlertBlurrView(frame: view.frame)
        
        setupAlertDismiss(toView: blurrView)
        
        tblValues = UITableView(frame: view.frame)
        tblValues.delegate = self
        tblValues.dataSource = self
        
        tblValues.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tblValues.separatorStyle = .singleLine
        tblValues.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tblValues.bounces = true
        tblValues.isScrollEnabled = true
        
        view.backgroundColor = .clear
        tblValues.backgroundColor = VIEW_BACKGROUND_COLOR
        blurrView.backgroundColor = .lightGray
        blurrView.alpha = 0.5
        
        view.addSubview(blurrView)
        view.addSubview(tblValues)
        
        tblValues.isUserInteractionEnabled = true
    }
    
    //MARK: - Show View
    func showView(viewDisplay: UIView, frame: CGRect, data: [String], selectedIndex: Int) {
        super.showView(viewDisplay: viewDisplay)
        
        self.selectedIndex = selectedIndex
        self.arrOfData = data
        self.tblValues.frame = frame
        self.tblValues.showBorder(.clear, 10)
        
        if isViewLoaded {
            tblValues.reloadData()
        }
    }
    
}

//MARK: - TableView delegate callbacks
extension TableViewAlert: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let data = arrOfData[index]
        
        let font = UIFont.systemFont(ofSize: 20)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = .black
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.text = data
        cell.textLabel?.font = font
        
        var image = #imageLiteral(resourceName: "radio_unselect")
        if index == selectedIndex {
            image = #imageLiteral(resourceName: "radio_selected")
        }
        cell.imageView?.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        let data = arrOfData[index]
        callback?(data, index)
        
        hideDialog()
    }
}
