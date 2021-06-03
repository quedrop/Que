//
//  CountryPickerVC.swift
//  QueDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit

@objc protocol CountryPickerVCDelegate:NSObjectProtocol{
    func countrySelected(dic : [String:Any])
}

class CountryPickerVC: BaseViewController {

    //CONSTANT
       
    //VARIABLES
    var delegate:CountryPickerVCDelegate?
    var imagePicker = UIImagePickerController()
    var arrCountries = [[String : Any]]()
    var arrSearch = [[String : Any]]()
    var currentCountry = [String : Any]()
    var isSearch : Bool = false
    
    //IBOUTLETS
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tblCountry: UITableView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    //MARK: - VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
    }
    
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
    }
    
    func setupGUI() {
        lblTitle.text = "Select Country"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        lblNoData.text = "No Countries Found"
        lblNoData.textColor = .gray
        lblNoData.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14))
    
        btnDone.setTitle("Done", for: .normal)
        btnDone.setTitleColor(.white, for: .normal)
        btnDone.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 16.0))
        
        txtSearch.textColor = .black
        txtSearch.tintColor = txtSearch.textColor
        txtSearch.font = UIFont(name: fFONT_REGULAR, size: calculateFontForWidth(size: 14))
        txtSearch.addTarget(self, action: #selector(didEditing(sender:)), for: .editingChanged)
        
        viewSearch.layer.masksToBounds = false
        viewSearch.layer.shadowColor = UIColor.gray.cgColor
        viewSearch.layer.shadowOffset = CGSize(width: 0, height: 1)
        viewSearch.layer.shadowRadius = 3
        viewSearch.layer.shadowOpacity = 0.7
        viewSearch.layer.cornerRadius = 10.0
        viewSearch.clipsToBounds = false
        
        arrCountries = getAllCountriesDialCode()
        if arrCountries.count > 0 {
            lblNoData.isHidden = true
            tblCountry.isHidden = false
        }else {
            lblNoData.isHidden = false
            tblCountry.isHidden = true
        }
        tblCountry.reloadData()
    }
    
    //MARK: - BUTTONS ACTION
    @IBAction func btnBackClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        if (self.delegate?.responds(to: #selector(self.delegate?.countrySelected(dic:))))! {
            self.delegate?.countrySelected(dic: currentCountry)
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnClearSearchClicked(_ sender: Any) {
        txtSearch.text = ""
        isSearch = false
       if arrCountries.count > 0 {
           lblNoData.isHidden = true
           tblCountry.isHidden = false
       }else {
           lblNoData.isHidden = false
           tblCountry.isHidden = true
       }
       tblCountry.reloadData()
        txtSearch.resignFirstResponder()
    }
    
    @objc func didEditing(sender: UITextField) {
        isSearch = true
        arrSearch = arrCountries.filter{($0["name"] as! String).lowercased().contains(txtSearch.text!.lowercased()) || ($0["dial_code"] as! String).lowercased().contains(txtSearch.text!.lowercased())}
        if arrSearch.count > 0 {
            lblNoData.isHidden = true
            tblCountry.isHidden = false
        }else {
            lblNoData.isHidden = false
            tblCountry.isHidden = true
        }
        tblCountry.reloadData()
    }
}

extension CountryPickerVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  isSearch ? arrSearch.count : arrCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell",for: indexPath) as! CountryPickerCell
        let d = isSearch ? arrSearch[indexPath.row] : arrCountries[indexPath.row]
        cell.lblCountryName.text = d["name"] as? String
        cell.lblCode.text = d["dial_code"] as? String
        cell.imgFlag.image = UIImage(named: "\(d["code"] ?? "")".uppercased())
        
        if currentCountry["code"] as! String == d["code"] as! String {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCountry = isSearch ? arrSearch[indexPath.row] : arrCountries[indexPath.row]
        tblCountry.reloadData()
    }
}

//MARK: - UITEXTFIELD DELEGATE METHODS
extension CountryPickerVC : UITextFieldDelegate {
    
}
