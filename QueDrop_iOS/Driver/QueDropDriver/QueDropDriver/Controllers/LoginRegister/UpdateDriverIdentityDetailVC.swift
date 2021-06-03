//
//  UpdateDriverIdentityDetailVC.swift
//  QueDropDriver
//
//  Created by C100-174 on 03/03/20.
//  Copyright © 2020 C100-174. All rights reserved.
//

import UIKit
import SDWebImage

class UpdateDriverIdentityDetailVC: BaseViewController {
    
    //CONSTANTS
    
    //VARIABLES
    var currentPhotoFor : DriverDetailsFields = DriverDetailsFields(rawValue: 0)!
    var selectedVehicleType = VehicleType.Car.rawValue
    
	var imgPhoto : UIImage? = nil
    var imgLicence : UIImage? = nil
    var imgReg : UIImage? = nil
    var imgNumP : UIImage? = nil
    
     var isFromLaunch : Bool = false
    var isFromProfile : Bool = false
    var driverDetails : DriverDetail?
    
    //IBOUTLETS
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
    //MARK: - VC LIFE CYCLE METHOD
    override func viewDidLoad() {
        super.viewDidLoad()
        initializations()
            setupGUI()
    }
        
    //MARK:- SETUP & INITIALISATION
    func initializations()  {
        tblView.register("IdentityPhotoCell")
        tblView.register("IdentityVehicleTypeCell")
    }
    
    func setupGUI() {
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        lblTitle.text = "Identity Verification"
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: fFONT_SEMIBOLD, size: calculateFontForWidth(size: 18))
    
        btnDone.backgroundColor = THEME_COLOR
        btnDone.setTitle("Done", for: .normal)
        btnDone.setTitleColor(.white, for: .normal)
        btnDone.titleLabel?.font = UIFont(name: fFONT_MEDIUM, size: calculateFontForWidth(size: 20.0))
        
        if let vt = driverDetails?.vehicleType {
            selectedVehicleType = vt
        }
    }
    
    //MARK: - BUTTON ACTIONS
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if isFromLaunch{
            callLogoutAPI()
        } else {
             navigationController?.popViewController(animated: true)
        }

    }
    @IBAction func btnDoneClicked(_ sender: Any) {
        if doValidate() {
            updateDriverIdentityDetails()
        }
    }
    
    @objc func btnAddPhotoClicked(sender : UIButton) {
        currentPhotoFor = DriverDetailsFields(rawValue: sender.tag)!
        let vc = MainStoryboard.instantiateViewController(withIdentifier: "PhotoPickerVC") as! PhotoPickerVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func btnSelectVehicle(sender : UIButton) {
        let cell = tblView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IdentityVehicleTypeCell
        
        if(sender == cell.btnCar) {
            selectedVehicleType = VehicleType.Car.rawValue
            cell.btnCar.setImage(UIImage(named: "car_selected"), for: .normal)
            cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
            cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
        } else if(sender == cell.btnBike) {
            selectedVehicleType = VehicleType.Bike.rawValue
            cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
            cell.btnBike.setImage(UIImage(named: "bike_selected"), for: .normal)
            cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
        } else {
            selectedVehicleType = VehicleType.Cycle.rawValue
            cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
            cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
            cell.btnCycle.setImage(UIImage(named: "cycle_selected"), for: .normal)
        }
        tblView.reloadData()
    }
    
    //MARK: - VALIDATION
    func doValidate() -> Bool {
        var strError = ""
        
        
        if imgNumP == nil && (selectedVehicleType != VehicleType.Cycle.rawValue) {
            if isFromProfile && (driverDetails?.numberPlate!.count)! > 0 {
            } else {
                strError = "Please provide number plate photo"
            }
        }
		if imgReg == nil && (selectedVehicleType != VehicleType.Cycle.rawValue){
            if isFromProfile && (driverDetails?.registrationProof!.count)! > 0 {
             }else {
                strError = "Please provide registration proof"
             }
        }
        if imgLicence == nil && (selectedVehicleType != VehicleType.Cycle.rawValue){
            if isFromProfile && (driverDetails?.registrationProof!.count)! > 0 {
             }else {
                strError = "Please provide licence photo"
             }
        }
        if selectedVehicleType.length == 0 {
                    strError = "Please select type of vehicle"
               }
		if imgPhoto == nil{
            if isFromProfile && (driverDetails?.driverPhoto!.count)! > 0 {
            }else{
                strError = "Please provide driver photo"
            }
        }
        
        if(strError.count > 0){
            //SHOW ERROR MSG
            ShowToast(message: strError)
            return false
        }
        return true
    }

}

//MARK: - UITABLEVIEW DELEGATE AND DATASOURCE
extension UpdateDriverIdentityDetailVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedVehicleType == VehicleType.Cycle.rawValue{
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

            let image = #imageLiteral(resourceName: "add_photo")
            
			if let image  = imgPhoto {
			    cell.btnAction.setImage(image, for: .normal)
			}
			else {
                if let imgUrl = driverDetails?.driverPhoto{
                    cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
                }else {
                    cell.btnAction.setImage(image, for: .normal)
                }
			}
            cell.btnAction.addTarget(self, action: #selector(btnAddPhotoClicked(sender:)), for: .touchUpInside)
            return cell
                
        case DriverDetailsFields.licence.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Licence Photo"
            cell.btnAction.tag = indexPath.row
            let image = #imageLiteral(resourceName: "add_photo")
            
			if let image  = imgLicence {
			    cell.btnAction.setImage(image, for: .normal)
			}
			else {
                if let imgUrl = driverDetails?.licencePhoto{
                    cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
                } else {
                    cell.btnAction.setImage(image, for: .normal)
                }
			}
            cell.btnAction.addTarget(self, action: #selector(btnAddPhotoClicked(sender:)), for: .touchUpInside)
            return cell
                
        case DriverDetailsFields.vehicleType.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityVehicleTypeCell",for: indexPath) as! IdentityVehicleTypeCell
            cell.lblField.text = "Add Vehicle Type"
            cell.btnCar.addTarget(self, action: #selector(btnSelectVehicle(sender:)), for: .touchUpInside)
            cell.btnBike.addTarget(self, action: #selector(btnSelectVehicle(sender:)), for: .touchUpInside)
            cell.btnCycle.addTarget(self, action: #selector(btnSelectVehicle(sender:)), for: .touchUpInside)
            
            let vt = selectedVehicleType
            //if let vt = driverDetails?.vehicleType {
                if vt == VehicleType.Car.rawValue {
                   cell.btnCar.setImage(UIImage(named: "car_selected"), for: .normal)
                   cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
                   cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
               } else if vt ==  VehicleType.Bike.rawValue{
                   cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
                   cell.btnBike.setImage(UIImage(named: "bike_selected"), for: .normal)
                   cell.btnCycle.setImage(UIImage(named: "cycle"), for: .normal)
               } else {
                   cell.btnCar.setImage(UIImage(named: "car"), for: .normal)
                   cell.btnBike.setImage(UIImage(named: "bike"), for: .normal)
                   cell.btnCycle.setImage(UIImage(named: "cycle_selected"), for: .normal)
               }
            //}
            return cell
        
        case DriverDetailsFields.registrationProof.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Registration Proof"
            cell.btnAction.tag = indexPath.row
            let image = #imageLiteral(resourceName: "add_photo")
           
			if let image  = imgReg {
			    cell.btnAction.setImage(image, for: .normal)
			}
			else {
                if let imgUrl = driverDetails?.registrationProof{
                    cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
                }else {
                    cell.btnAction.setImage(image, for: .normal)
                }
			}
            cell.btnAction.addTarget(self, action: #selector(btnAddPhotoClicked(sender:)), for: .touchUpInside)
            return cell
        
        case DriverDetailsFields.numberPlate.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IdentityPhotoCell",for: indexPath) as! IdentityPhotoCell
            cell.lblField.text = "Add Number Plate"
            let image = #imageLiteral(resourceName: "add_photo")
           
			if let image  = imgNumP {
			    cell.btnAction.setImage(image, for: .normal)
			}
			else {
                if let imgUrl = driverDetails?.numberPlate{
                    cell.btnAction!.sd_setImage(with:  URL(string: "\(URL_DRIVER_DETAILS_IMAGES)\(imgUrl)"), for: .normal, placeholderImage: image, options: SDWebImageOptions(rawValue: 0), completed: nil)
                }else {
                    cell.btnAction.setImage(image, for: .normal)
                }
			}
            cell.btnAction.tag = indexPath.row
            cell.btnAction.addTarget(self, action: #selector(btnAddPhotoClicked(sender:)), for: .touchUpInside)
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

//MARK: - PHOTO PICKER DELEGATE
extension UpdateDriverIdentityDetailVC : PhotoPickerVCDelegate {
    func imagePicked(img: UIImage) {
        switch currentPhotoFor.rawValue {
        case DriverDetailsFields.photo.rawValue:
            imgPhoto = img
            let cell = tblView.cellForRow(at: IndexPath(row: DriverDetailsFields.photo.rawValue, section: 0)) as! IdentityPhotoCell
            cell.btnAction.setImage(imgPhoto, for: .normal)
            
        case DriverDetailsFields.licence.rawValue:
            imgLicence = img
            let cell = tblView.cellForRow(at: IndexPath(row: DriverDetailsFields.licence.rawValue, section: 0)) as! IdentityPhotoCell
            cell.btnAction.setImage(imgLicence, for: .normal)
                
        case DriverDetailsFields.registrationProof.rawValue:
            imgReg = img
            let cell = tblView.cellForRow(at: IndexPath(row: DriverDetailsFields.registrationProof.rawValue, section: 0)) as! IdentityPhotoCell
            cell.btnAction.setImage(imgReg, for: .normal)
        
        case DriverDetailsFields.numberPlate.rawValue:
            imgNumP = img
            let cell = tblView.cellForRow(at: IndexPath(row: DriverDetailsFields.numberPlate.rawValue, section: 0)) as! IdentityPhotoCell
            cell.btnAction.setImage(imgNumP, for: .normal)
        default :
            break
        }
    }
}
