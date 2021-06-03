//
//  ViewDriverIdentityDetailsVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 15/04/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import SDWebImage

class ViewDriverIdentityDetailsVC: UIViewController {
    
    //CONSTANTS
    
    //VARIABLES
    var driverDetails : DriverDetail?
    
    //IBOUTLETS
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
        setupGUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getIdentityDetails()
    }
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        tblView.register("IdentityPhotoCell")
        tblView.register("IdentityVehicleTypeCell")
    }
    
    func setupGUI() {
        view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Identity details"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
        
        btnEdit.backgroundColor = THEME_COLOR
        btnEdit.setTitle("Edit", for: .normal)
        btnEdit.setTitleColor(.white, for: .normal)
        btnEdit.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        drawBorder(view: btnEdit, color: .clear, width: 0.0, radius: 8.0)
        
    }
    
    //MARK: - BUTTON ACTIONS
    
    @IBAction func btnBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func btnEditClicked(_ sender: Any) {
        let vc = LoginStoryboard.instantiateViewController(withIdentifier: "UpdateDriverIdentityDetailVC") as! UpdateDriverIdentityDetailVC
        vc.isFromProfile = true
        vc.driverDetails = driverDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension ViewDriverIdentityDetailsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if driverDetails?.vehicleType ==  VehicleType.Cycle.rawValue {
            return 2
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case DriverDetailsFields.photo.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Photo"
            cell.btnAction.tag = indexPath.row
            cell.btnAction.isUserInteractionEnabled = false
             let image = #imageLiteral(resourceName: "add_photo")
            if let imgUrl = driverDetails?.driverPhoto{
                cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
            }else {
                cell.btnAction.setImage(image, for: .normal)
            }
            
            return cell
            
        case DriverDetailsFields.licence.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Licence Photo"
            cell.btnAction.tag = indexPath.row
            cell.btnAction.isUserInteractionEnabled = false
             let image = #imageLiteral(resourceName: "add_photo")
            if let imgUrl = driverDetails?.licencePhoto{
                cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
            }else {
                cell.btnAction.setImage(image, for: .normal)
            }
            return cell
            
        case DriverDetailsFields.vehicleType.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityVehicleTypeCell",for: indexPath) as! IdentityVehicleTypeCell
            cell.lblField.text = "Add Vehicle Type"
            cell.btnCar.isUserInteractionEnabled = false
            cell.btnBike.isUserInteractionEnabled = false
            cell.btnCycle.isUserInteractionEnabled = false
            
            if driverDetails?.vehicleType == VehicleType.Car.rawValue {
                cell.btnCar.setImage(UIImage(named: "car_selected"), for: .normal)
                cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
                cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
            } else if driverDetails?.vehicleType ==  VehicleType.Bike.rawValue{
                cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
                cell.btnBike.setImage(UIImage(named: "bike_selected"), for: .normal)
                cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
            } else {
                cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
                cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
                cell.btnCycle.setImage(UIImage(named: "cycle_selected"), for: .normal)
            }
            return cell
            
        case DriverDetailsFields.registrationProof.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Registration Proof"
            cell.btnAction.tag = indexPath.row
            cell.btnAction.isUserInteractionEnabled = false
             let image = #imageLiteral(resourceName: "add_photo")
            if let imgUrl = driverDetails?.registrationProof{
                cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
            }else {
                cell.btnAction.setImage(image, for: .normal)
            }
            return cell
            
        case DriverDetailsFields.numberPlate.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Number Plate"
            cell.btnAction.isUserInteractionEnabled = false
             let image = #imageLiteral(resourceName: "add_photo")
            if let imgUrl = driverDetails?.numberPlate{
                cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
            }else {
                cell.btnAction.setImage(image, for: .normal)
            }
            
            return cell
            
        default:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


