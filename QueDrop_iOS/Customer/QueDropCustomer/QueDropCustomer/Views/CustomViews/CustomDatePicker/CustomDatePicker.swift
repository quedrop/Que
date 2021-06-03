//
//  CustomDatePicker.swift
//  QueDrop
//
//  Created by C100-104 on 28/02/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit

protocol CustomDatePickerDelegate {
	func selectedDate(selectedDates : [Date], style : VASelectionStyle)
}

class CustomDatePicker: UIViewController {

	@IBOutlet var lblYear: UILabel!
	@IBOutlet var lblTodayDate: UILabel!
	@IBOutlet var monthHeaderView: VAMonthHeaderView! {
		   didSet {
			   let appereance = VAMonthHeaderViewAppearance(
				   previousButtonImage: #imageLiteral(resourceName: "previous_month"),
				   nextButtonImage: #imageLiteral(resourceName: "next_month")
			   )
			
			   monthHeaderView.delegate = self
			   monthHeaderView.appearance = appereance
		   }
	   }
	
	@IBOutlet var weekDaysView: VAWeekDaysView!{
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .veryShort, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
	@IBOutlet var calendarView: UIView!
	var calendarViewNew: VACalendarView!
	let defaultCalendar: Calendar = {
		var calendar = Calendar.current
		calendar.firstWeekday = 1
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!
		
		return calendar
	}()
	var delegate : CustomDatePickerDelegate?
	var selectedDates : [Date] = []
	var currSelectionStyle : VASelectionStyle = .single
	
	override func viewDidLoad() {
		currentlyUsingVACalenderFor = .AdvancedOrder
		let nextMonth = Calendar.current.date(byAdding: .month, value: 4, to: Date())
		let calendar = VACalendar(startDate: Date(), endDate: nextMonth, selectedDate: nil, calendar: defaultCalendar)
		calendarViewNew = VACalendarView(frame: .zero, calendar: calendar)
		
			   calendarViewNew.startDate = Date()
		
		calendarViewNew.showDaysOut = true
			   calendarViewNew.selectionStyle = currSelectionStyle
			   calendarViewNew.monthDelegate = monthHeaderView
			   calendarViewNew.dayViewAppearanceDelegate = self
			   calendarViewNew.monthViewAppearanceDelegate = self
			   calendarViewNew.calendarDelegate = self
			   calendarViewNew.scrollDirection = .horizontal
			   calendarViewNew.selectDates(selectedDates)
			   calendarView.addSubview(calendarViewNew)
    
    }
	override func viewDidAppear(_ animated: Bool) {
		    super.viewDidLoad()
			setupHeader()
	}
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if calendarViewNew.frame == .zero {
            DispatchQueue.main.async {
                self.calendarViewNew.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: self.calendarView.frame.width,
                    height: self.calendarView.frame.height
                )
                self.calendarViewNew.setup()
            }
        }
    }
	func setSelectedDate(dates: [Date],type : VASelectionStyle)
	{
		selectedDates = dates
		self.currSelectionStyle = type
	}
	func setupHeader()
	{
		let formatter = DateFormatter()
		//formatter.dateFormat = "yyyy-MM-dd"
		formatter.dateFormat = "yyyy"
		//Start Date
		let date = Date()
		let year = formatter.string(from: date)
		formatter.dateFormat = "E, MMM d"
		let Today = formatter.string(from: date)
		self.lblYear.text = year
		self.lblTodayDate.text = Today
	}
	//MARK:- ACTION METHODS
	
	@IBAction func actionOK(_ sender: Any) {
		switch currSelectionStyle {
		case .single:
			self.delegate?.selectedDate(selectedDates: selectedDates, style: currSelectionStyle)
			self.dismiss(animated: false, completion: nil)
			break
		case .multi:
			if selectedDates.count > 0
			{
				self.delegate?.selectedDate(selectedDates: selectedDates, style: currSelectionStyle)
				self.dismiss(animated: false, completion: nil)
			}
			else
			{
				ShowToast(message: "Please Select atleast one date for your Monthly Order .")
			}
			break
		}
	}
	
	@IBAction func actionCancel(_ sender: Any) {
		
		self.dismiss(animated: false, completion: nil)
	}
}
extension CustomDatePicker : VAMonthHeaderViewDelegate , VACalendarViewDelegate
{
	
	 func didTapNextMonth() {
		   calendarViewNew.nextMonth()
	   }
	   
	   func didTapPreviousMonth() {
		   calendarViewNew.previousMonth()
	   }
	func selectedDate(_ date: Date) {
		/*
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let startDateTime = formatter.string(from: date)
		let sDate = formatter.date(from: startDateTime) ?? Date()
		*/
		selectedDates.removeAll()
		selectedDates.append(date)
//		self.delegate?.selectedDate(dateTime:sDate, dateTimeInString: startDateTime)
//		self.dismiss(animated: false, completion: nil)
	}
	
	func selectedDates(_ dates: [Date]) {
		
		/*let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		//Start Date
		let sDate = dates.first ?? Date()
		let startDateTime = formatter.string(from: sDate)
		let startDate = formatter.date(from: startDateTime) ?? Date()
		//End Date
		let lDate = dates.last ?? Date()
		let endDateTime = formatter.string(from: lDate)
		//let endDate = formatter.date(from: endDateTime) ?? Date()
		*/
		selectedDates.removeAll()
		selectedDates.append(contentsOf: dates)
		
	}
}

extension CustomDatePicker: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
		return 5.0
    }
    
    func rightInset() -> CGFloat {
		return 5.0
    }
//
//    func verticalMonthTitleFont() -> UIFont {
//        return UIFont.systemFont(ofSize: 16, weight: .semibold)
//    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .gray
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
    
}

extension CustomDatePicker: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
			return .clear
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .black
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return THEME_COLOR
        default:
            return .clear
        }
    }
	func font(for state: VADayState) -> UIFont {
	//
		switch state {
		   case .selected:
			   return UIFont(name: "Montserrat-Medium", size: 13.0)!
		   default:
			   return UIFont(name: "Montserrat-Regular", size: 13.0)!
		   }
	}
    func shape() -> VADayShape {
        return .circle
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
    
}
