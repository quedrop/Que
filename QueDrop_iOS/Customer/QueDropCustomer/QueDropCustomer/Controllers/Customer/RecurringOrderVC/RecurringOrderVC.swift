//
//  RecurringOrderVC.swift
//  QueDrop
//
//  Created by C100-104 on 28/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

protocol AcvanceOrderDetailsDelegate {
	func RecurringDate(recurringTypeId : Int , recurredOn : String ,recurringTime : String ,label : String , repatUntilDate : String)
}

class RecurringOrderVC: BaseViewController , UIPopoverPresentationControllerDelegate{

	@IBOutlet var btnBack: UIButton!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var btnSave: UIButton!
	@IBOutlet var btnRepeatOption: UIButton!
	@IBOutlet var lblselectedRepeatOption: UILabel!
	@IBOutlet var timePicker: UIDatePicker!
	@IBOutlet var repeatOptionViewHeight: NSLayoutConstraint! // 60-120
	
	@IBOutlet var imgLabel: UIImageView!
	@IBOutlet var btnShowLabel: UIButton!
	@IBOutlet var labelViewHeight: NSLayoutConstraint! //60-120
	@IBOutlet var ImgRepeatOptionDown: UIImageView!
	
	@IBOutlet var lblAddedItemName: UILabel!
	@IBOutlet var txtLabel: UITextField!
	@IBOutlet var btnClearText: UIButton!
	@IBOutlet var btnRepeatUntilDate: UIButton!
	@IBOutlet var repeatUntilViewHeight: NSLayoutConstraint! // 0-63
	
	
	//MARK:- VARIABLES
	var Orderid = 0
	var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
	var  pickerViewController : CustomDatePicker?
	var minDate = ""
	struct PickedDate {
		var startDate : String?
		var sDate : Date?
		var startTime : String?
		var endDate : String?
		var endTime : String?
	}
	
	enum pickerType : Int
	{
		case startDate = 0
		case startTime
		case endDate
		case endTime
	}
	var selectedPickerType = 0
	var blackPopView = UIView()
	var structPicledValues = PickedDate()
	var selectedDayIndex : [Int] = [] {// 0-Sunday ,1 - Monday ....
		didSet{
			print("selectedDayIndex ==>",selectedDayIndex)
		}
	}
	var selectedTime : String = ""
	var selectedRecurringTypeId = 0
	var selectedRecurrId = 0
	var untilDate : Date = Date()
	var multiDates : [Date] = []
	
	
	var delegate : AcvanceOrderDetailsDelegate?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.delegate = self
		collectionView.dataSource = self
		GetRecurringTypes()
		collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 5.0, bottom: 5.0, right: 8.0)
		setUPRepeationView()
		let origImage = UIImage(named: "down_arrow_red")
		let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
		ImgRepeatOptionDown.image = tintedImage
		ImgRepeatOptionDown.tintColor = .lightGray
		txtLabel.layer.borderWidth = 0.7
		txtLabel.layer.borderColor = UIColor.lightGray.cgColor
		txtLabel.layer.cornerRadius = 5.0
		txtLabel.setLeftPadding(10.0)
		txtLabel.setRightPadding(50.0)
		txtLabel.returnKeyType = .done
		txtLabel.delegate = self
    }
	
    
	//MARK:- ActionMethods
	@IBAction func actionBack(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func actionSave(_ sender: Any) {
		if validateData()
		{
			var UntilDate = DateFormatter(format: "yyyy-MM-dd").string(from: untilDate)
			if UntilDate == DateFormatter(format: "yyyy-MM-dd").string(from: Date())
			{
				UntilDate = ""
			}
			var recurringOn = ""
			if (arrStructRepeateOptions[selectedRecurrId].name ?? "").lowercased() == enum_repeate_options.once.rawValue
			{
				recurringOn = DateFormatter(format: "yyyy-MM-dd").string(from: Date())
			} else if (arrStructRepeateOptions[selectedRecurrId].name ?? "").lowercased() == enum_repeate_options.weekly.rawValue {
					recurringOn = ""
					var days : [String] = []
					for val in selectedDayIndex
					{
						switch val {
						case 0:
							days.append("Sunday")
							break
						case 1:
							days.append("Monday")
						break
						case 2:
							days.append("Tuesday")
						break
						case 3:
							days.append("Wednesday")
						break
						case 4:
							days.append("Thursday")
						break
						case 5:
							days.append("Friday")
						break
						case 6:
							days.append("Saturday")
						break
						default:
							break
						}
					}
					recurringOn = days.joined(separator: ",")
			} else if (arrStructRepeateOptions[selectedRecurrId].name ?? "").lowercased() == enum_repeate_options.monthly.rawValue {
				recurringOn = ""
				var dateAry : [String] = []
				for date in multiDates
				{
					dateAry.append(DateFormatter(format: "yyyy-MM-dd").string(from: date))
				}
				recurringOn = dateAry.joined(separator: ",")
			}
			structAdvancedOrderDeatils.multiDates.removeAll()
			structAdvancedOrderDeatils.multiDates.append(contentsOf: multiDates)
			structAdvancedOrderDeatils.selectedDayIndex.removeAll()
			structAdvancedOrderDeatils.selectedDayIndex.append(contentsOf: selectedDayIndex)
			structAdvancedOrderDeatils.untilDate = untilDate
			
			
			delegate?.RecurringDate(recurringTypeId: selectedRecurringTypeId, recurredOn: recurringOn, recurringTime: selectedTime, label: lblAddedItemName.text ?? "", repatUntilDate: UntilDate)
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	@IBAction func actionnClearLabelText(_ sender: Any) {
		lblAddedItemName.text  = ""
		txtLabel.text = ""
			UIView.animate(withDuration: 0.5, animations: {
				self.labelViewHeight.constant = 60
				self.view.layoutIfNeeded()
			}	)
			txtLabel.resignFirstResponder()
	}
	@IBAction func actionForRepeatuntilDate(_ sender: Any) {
		
		if pickerViewController != nil
		{
			pickerViewController = nil
		}
		pickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomDatePicker") as? CustomDatePicker
		self.pickerViewController?.delegate = self
		self.pickerViewController?.setSelectedDate(dates: [untilDate], type: .single)
		self.present(self.pickerViewController!, animated: false, completion: nil)
		
	}
	@IBAction func actionShowLabel(_ sender: Any) {
		if self.labelViewHeight.constant == 60
		{
			UIView.animate(withDuration: 0.5, animations: {
				self.labelViewHeight.constant = 120
				self.view.layoutIfNeeded()
			}, completion: { _ in
				self.txtLabel.becomeFirstResponder()
			})
		}
		else
		{
			UIView.animate(withDuration: 0.5, animations: {
				self.labelViewHeight.constant = 60
				self.view.layoutIfNeeded()
			}, completion: { _ in
				self.txtLabel.resignFirstResponder()
			})
		}
	}
	@IBAction func actionTimeChanged(_ sender: UIDatePicker) {
		ShowToast(message: "\(sender.date)")
		if lblselectedRepeatOption.text?.lowercased() == enum_repeate_options.once.rawValue
		{
			if sender.date > Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
			{
				selectedTime = DateFormatter(format: "HH:mm").string(from: sender.date)
			}
			else
			{
				sender.setDate( Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, animated: true)
				ShowToast(message: "The selected time should be two hours later.")
			}
		}
		selectedTime = DateFormatter(format: "HH:mm").string(from: sender.date)
	}
	//s
	@IBAction func actionSelectioRepeatOption(_ sender: Any) {
		blackPopView.frame = self.view.frame
		blackPopView.backgroundColor = UIColor.black
		blackPopView.alpha = 0.8
		
		self.view.addSubview(blackPopView)
		guard let popVC = storyboard?.instantiateViewController(withIdentifier: "AdvancedOrderPopOverView") as? AdvancedOrderPopOverView else { return }
		
		popVC.modalPresentationStyle = .popover
		//popVC.popOverDelegate = self
		let popOverVC = popVC.popoverPresentationController
		//   APP_DELEGATE.delegate = self
		popVC.setUpTableView(delegate: self, dataSource: self)
		//popVC.tableView.dataSource = self
		popOverVC?.permittedArrowDirections = .up
		popOverVC?.containerView?.layer.cornerRadius = 0
		popOverVC?.delegate = self
		popOverVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
		popOverVC?.sourceView = btnRepeatOption
		popOverVC?.sourceRect = CGRect(x: btnRepeatOption.bounds.midX + 5 , y: btnRepeatOption.bounds.minY + 40, width: 0, height: 0)
		popVC.preferredContentSize = CGSize(width: btnRepeatOption.bounds.width, height: 40 * 4)
		popVC.view.layer.cornerRadius = 5
		self.present(popVC, animated: true, completion: {
			popVC.view.superview?.layer.cornerRadius = 5
		})
	}
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.blackPopView.removeFromSuperview()
    }
	
	//MARK:- FUNCTIONS
	func setUPRepeationView()
	{
		lblselectedRepeatOption.text = "Once"
		timePicker.setDate( Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, animated: true)
		labelViewHeight.constant = 60
		repeatUntilViewHeight.constant = 0
		repeatOptionViewHeight.constant = 60
		//let myCalendar = Calendar(identifier: .gregorian)
		//let weekDay = myCalendar.component(.weekday, from: Date())
		let Day = DateFormatter(format: "e").string(from: Date())
		let weekDay = Int(Day) ?? 0
		selectedDayIndex.append(weekDay - 1)
		selectedTime = DateFormatter(format: "HH:mm").string(from: timePicker.date)
		ShowToast(message: "Curr Time : \(selectedTime)")
		if structAdvancedOrderDeatils.recurringTime != ""
		{
			selectedRecurringTypeId = structAdvancedOrderDeatils.recurringTypeId
			let time  = DateFormatter(format: "HH:mm").date(from: structAdvancedOrderDeatils.recurringTime)
			selectedTime = structAdvancedOrderDeatils.recurringTime
			timePicker.date = time ??  Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
			multiDates.append(contentsOf: structAdvancedOrderDeatils.multiDates)
			selectedDayIndex.append(contentsOf: structAdvancedOrderDeatils.selectedDayIndex)
			untilDate = structAdvancedOrderDeatils.untilDate
		}
		
		
	}
	
	func validateData() -> Bool
	{
		if lblselectedRepeatOption.text?.lowercased() == enum_repeate_options.once.rawValue
		{
			if timePicker.date >  Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
			{
				selectedTime = DateFormatter(format: "HH:mm").string(from: timePicker.date)
				return true
			}
			else
			{
				timePicker.setDate(Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, animated: true)
				ShowToast(message: "The selected time should be two hours later.")
				return false
			}
		}  else if lblselectedRepeatOption.text?.lowercased() == enum_repeate_options.weekly.rawValue
		{
			if selectedDayIndex.count == 0
			{
				ShowToast(message: "Please Select days for Weekly Advance Ordering.")
				return false
			}
			return true
		} else if lblselectedRepeatOption.text?.lowercased() == enum_repeate_options.monthly.rawValue
		{
			if multiDates.count == 0
			{
				ShowToast(message: "Please Select dates for Monthly Advance Ordering.")
				return false
			}
			return true
		} else {
			return true
		}
	}
}

//MARK:- PopOver TableView Delegate
extension RecurringOrderVC : UITableViewDelegate , UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AdvancedOrderPopOverSingleTVC", for: indexPath) as! AdvancedOrderPopOverSingleTVC
		cell.lblTitle.text = arrStructRepeateOptions[indexPath.row].name ?? ""
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		return (40)
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//ShowToast(message: arrStructRepeateOptions[indexPath.row].name ?? "")
		selectedRecurringTypeId = arrStructRepeateOptions[indexPath.row].id ?? 0
		selectedRecurrId = indexPath.row
		if (arrStructRepeateOptions[indexPath.row].name ?? "").lowercased() == enum_repeate_options.once.rawValue
		{
			lblselectedRepeatOption.text = arrStructRepeateOptions[indexPath.row].name ?? ""
			timePicker.setDate(Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, animated: true)
			if self.repeatOptionViewHeight.constant == 120
			{
				UIView.animate(withDuration: 0.5, animations: {
					self.repeatOptionViewHeight.constant = 60
					self.repeatUntilViewHeight.constant = 0
					self.view.layoutIfNeeded()
				})
			}
		} else if (arrStructRepeateOptions[indexPath.row].name ?? "").lowercased() == enum_repeate_options.everyday.rawValue
		{
			lblselectedRepeatOption.text = arrStructRepeateOptions[indexPath.row].name ?? ""
			UIView.animate(withDuration: 0.5, animations: {
				self.repeatOptionViewHeight.constant = 120
				self.repeatUntilViewHeight.constant = 63
				self.collectionView.reloadData()
				self.view.layoutIfNeeded()
			})
		} else if  (arrStructRepeateOptions[indexPath.row].name ?? "").lowercased() == enum_repeate_options.weekly.rawValue
		{
			lblselectedRepeatOption.text = arrStructRepeateOptions[indexPath.row].name ?? ""
			UIView.animate(withDuration: 0.5, animations: {
				self.repeatOptionViewHeight.constant = 120
				self.repeatUntilViewHeight.constant = 63
				self.collectionView.reloadData()
				self.view.layoutIfNeeded()
			})
		} else if  (arrStructRepeateOptions[indexPath.row].name ?? "").lowercased() == enum_repeate_options.monthly.rawValue
		{
			lblselectedRepeatOption.text = arrStructRepeateOptions[indexPath.row].name ?? ""
			if pickerViewController != nil
			{
				pickerViewController = nil
			}
			pickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "CustomDatePicker") as? CustomDatePicker
			self.pickerViewController?.delegate = self
			self.pickerViewController?.setSelectedDate(dates: multiDates, type: .multi)
			if self.repeatOptionViewHeight.constant == 120
			{
				UIView.animate(withDuration: 0.5, animations: {
					self.repeatOptionViewHeight.constant = 60
					self.repeatUntilViewHeight.constant = 0
					self.view.layoutIfNeeded()
				})
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
				self.present(self.pickerViewController!, animated: false, completion: nil)
			})
			
		}else
		{
			ShowToast(message: "Available Soon...")
		}
		 dismiss(animated: true, completion: nil)
		  self.blackPopView.removeFromSuperview()
	}
}

//MARK:- TEXT FIELD DELEGATE
extension RecurringOrderVC : UITextFieldDelegate{
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		if !(textField.text?.isEmpty ?? false)
		{
			lblAddedItemName.text  = textField.text
				
		}
		UIView.animate(withDuration: 0.5, animations: {
			self.labelViewHeight.constant = 60
			self.view.layoutIfNeeded()
		}	)
		textField.resignFirstResponder()
		return true
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		if !(textField.text?.isEmpty ?? false)
		{
			lblAddedItemName.text  = textField.text
				
		}
		UIView.animate(withDuration: 0.5, animations: {
			self.labelViewHeight.constant = 60
			self.view.layoutIfNeeded()
		}	)
		textField.resignFirstResponder()
	}
}
//MARK:- CUSTOME DATE PICKER DELEGATE
extension RecurringOrderVC : CustomDatePickerDelegate
{
	func selectedDate(selectedDates: [Date], style: VASelectionStyle) {
		switch style {
		case .multi:
			if selectedDates.count > 0
			{
				multiDates.removeAll()
				multiDates.append(contentsOf: selectedDates)
			}
			break
		case .single:
			if selectedDates.count > 0
			{
				untilDate = selectedDates[0]
			}
			break
		}
	}
	
	
}
//MARK:- CollecetionView Delegate
extension RecurringOrderVC : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 7
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonCVC", for: indexPath) as? CategoryButtonCVC
			{
				cell.btnCategory.setTitle( days[indexPath.row].prefix(3).uppercased(), for: .normal)
				//if SelectedCatIndex == indexPath.row
				if lblselectedRepeatOption.text?.lowercased()  == enum_repeate_options.everyday.rawValue || selectedDayIndex.contains(indexPath.row)
				{
					//cell.btnCategory.isSelected = true
					cell.btnView.backgroundColor = GreenColor
					cell.btnCategory.setTitleColor(.white, for: .normal)
					cell.btnView.layer.borderColor = GreenCGColor
				}
				else
				{
					//cell.btnCategory.isSelected = false
					cell.btnView.backgroundColor = .white
					cell.btnCategory.setTitleColor(.gray, for: .normal)
					cell.btnView.layer.borderColor = UIColor.darkGray.cgColor
				}
				if  lblselectedRepeatOption.text?.lowercased()  == enum_repeate_options.weekly.rawValue {
					cell.btnCategory.tag = indexPath.row
					cell.btnCategory.addTarget(self, action: #selector(CategoryDidTap(_:)), for: .touchUpInside)
				}
				return cell
			}
		
		return UICollectionViewCell()
	}
	
	
	func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: ((collectionView.bounds.width - 5) / 7) , height: collectionView.bounds.height - 10)
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}

	func collectionView(_ collectionView: UICollectionView, layout
		collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5.0
	}
	
	@objc func CategoryDidTap(_ sender : UIButton){
		var tag = sender.tag
		if selectedDayIndex.contains(tag)
		{
			selectedDayIndex.removeAll(where: {$0 == tag})
		}
		else
		{
			selectedDayIndex.append(tag)
		}
		self.collectionView.reloadData()
	}
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		<#code#>
//	}
}
