//
//  AddNewStoreVC.swift
//  QueDrop
//
//  Created by C100-104 on 21/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
import ImageSlideshow

class AddNewStoreVC: BaseViewController {

	@IBOutlet var btnBack: UIButton!
	@IBOutlet var btnAdd: UIButton!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var tableView: UITableView!
	
	//MARK:- ENUM
	enum enumNewStoreField : Int {
		case imageSlider = 0
		case storeName
		case storeAddress
		case discription
	}
	//MARK:- Struct
	struct storeDetails {
		var storeName : String? = nil
		var storeAddress : String? = nil
		var storeLat : String? = nil
		var storeLon : String? = nil
		var storeDiscription : String? = nil
	}
	//MARK:- Var
	var pickedImage : [UIImage] = []
	var imagePicker = UIImagePickerController()
	var structStoreDetails = storeDetails()
	var isStoreAdded = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		imagePicker.delegate = self
    }
	override func viewWillAppear(_ animated: Bool) {
		isTabbarHidden(true)
		if isStoreAdded
		{
			self.navigationController?.popViewController(animated: false)
		}
	}
	//MARK:- Action Methods
	@IBAction func actionBack(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func actionAdd(_ sender: UIButton) {
		if structStoreDetails.storeName?.isEmpty ?? true
		{
            ShowToast(message: "Please add store name.")
			return
		}
		else if structStoreDetails.storeAddress?.isEmpty ?? true
		{
            ShowToast(message: "Please select store location.")
			return
		}
		else
		{
			registerStore()
		}
	}
	//MARK:- Function
	func openGallary()
	{
		imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
		imagePicker.allowsEditing = false
		self.present(imagePicker, animated: true, completion: nil)
	}
}
extension AddNewStoreVC : UITableViewDelegate , UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case enumNewStoreField.imageSlider.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageSliderTVC", for: indexPath) as? ImageSliderTVC
			{
				cell.selectionStyle = .none
				cell.imageSlider.contentMode = .scaleAspectFill
				cell.imageSlider.contentScaleMode = .scaleAspectFill
				let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePickerTapped(tapGestureRecognizer:)))
				cell.imageSlider.addGestureRecognizer(tapGestureRecognizer)
				if pickedImage.count != 0
				{
					cell.imageSlider.setImageInputs([ImageSource(image: pickedImage[0])])
				}
				else
				{
					cell.imageSlider.setImageInputs([ImageSource(image: #imageLiteral(resourceName: "add_picture"))])
				}
				return cell
			}
		case enumNewStoreField.storeName.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "NameTVCell", for: indexPath) as? NameTVCell
			{
				cell.selectionStyle = .none
				cell.lblTitle.text = "Store Name"
				cell.textField.tag = 25
				cell.textField.delegate = self
				cell.btnLocation.isHidden = true
				return cell
			}
		case enumNewStoreField.storeAddress.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "NameTVCell", for: indexPath) as? NameTVCell
			{
				cell.selectionStyle = .none
				cell.lblTitle.text = "Store Address"
				cell.textField.tag = 30
				cell.textField.setRightPadding(15)
				cell.textField.delegate = self
				let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAddress(tapGestureRecognizer:)))
				cell.textField.addGestureRecognizer(tapGestureRecognizer)
				cell.btnLocation.isHidden = false
				return cell
			}
		case enumNewStoreField.discription.rawValue:
			if let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTVCell", for: indexPath) as? InfoTVCell
			{
				cell.selectionStyle = .none
				cell.lblTitle.text  = "Discription"
				cell.textView.tag = 36
				cell.textView.delegate = self
				cell.textView.layer.borderColor = UIColor.gray.cgColor
				return cell
			}
		default:
				return UITableViewCell()
		}
		return UITableViewCell()
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.row {
		case enumNewStoreField.imageSlider.rawValue:
			return 230
		case enumNewStoreField.storeName.rawValue:
			return UITableView.automaticDimension
		case enumNewStoreField.storeAddress.rawValue:
			return UITableView.automaticDimension
		case enumNewStoreField.discription.rawValue:
			return 180
		default:
			return 0
		}
	}
	@objc func selectAddress(tapGestureRecognizer: UITapGestureRecognizer)
	{
		if let mapPicker = self.storyboard?.instantiateViewController(withIdentifier: "LocationPickerVC") as? LocationPickerVC
		{
			mapPicker.delegate = self
            mapPicker.modalPresentationStyle = .fullScreen
			self.present(mapPicker, animated: true, completion: nil)
		}
		
	}
	@objc func imagePickerTapped(tapGestureRecognizer: UITapGestureRecognizer)
	{
		openGallary()
	}
}
//MARK:- textField / TextView Delegate Method
extension AddNewStoreVC : UITextFieldDelegate,UITextViewDelegate{
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.tag == 36
		{
			self.structStoreDetails.storeDiscription = textView.text ?? ""
		}
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField.tag == 25
		{
			self.structStoreDetails.storeName = textField.text ?? ""
		}
	}
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		if textField.tag == 30
		{
			textField.resignFirstResponder()
			if let mapPicker = self.storyboard?.instantiateViewController(withIdentifier: "LocationPickerVC") as? LocationPickerVC
			{
				mapPicker.delegate = self
				self.present(mapPicker, animated: true, completion: nil)
			}
		}
		return true
	}
}
//MARK:- LocationPicker Delegate Method
extension AddNewStoreVC : locationPickerDelegate{
	func selectedLocationAddress(at storelocation: Address) {
		//storelocation
		if let cell = self.tableView.cellForRow(at: IndexPath(row: enumNewStoreField.storeAddress.rawValue, section: 0)) as? NameTVCell
		{
			cell.textField.text = storelocation.address
			structStoreDetails.storeAddress = storelocation.address
			structStoreDetails.storeLat = storelocation.latitude ?? ""
			structStoreDetails.storeLon = storelocation.longitude ?? ""
		}
	}
	
	
}
//MARK:- ImagePicker Delegate Method
extension AddNewStoreVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[.originalImage] as? UIImage {
			self.pickedImage.removeAll()
			self.pickedImage.append(pickedImage)
			if let cell = self.tableView.cellForRow(at: IndexPath(row: enumNewStoreField.imageSlider.rawValue, section: 0)) as? ImageSliderTVC
			{
				cell.imageSlider.setImageInputs([ImageSource(image: self.pickedImage[0])])
			}
		}
		picker.dismiss(animated: true, completion: nil)
		
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	
	}
	
	
	
}
