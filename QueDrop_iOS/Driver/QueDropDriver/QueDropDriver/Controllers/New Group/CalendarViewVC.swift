//
//  CalendarViewVC.swift
//  QueDropDeliveryCustomer
//
//  Created by C205 on 21/05/20.
//  Copyright © 2020 C100-104. All rights reserved.
//

import UIKit
protocol CalenderViewDelegate {
    func selectedWeekDates(dates : [Date])
}

/*enum weekDay : String{
   case mo = "Mon"
   case tu = "Tue"
   case we = "Wed"
   case th = "Thu"
   case fr = "Fri"
   case sa = "Sat"
   case su = "Sun"
}*/
   

class CalendarViewVC: UIViewController {
    
    @IBOutlet var monthHeaderView: VAMonthHeaderView! {
        didSet {
            let appereance = VAMonthHeaderViewAppearance(
                monthFont: UIFont(name: fFONT_BOLD, size: 17.0)!,
                monthTextColor: .black,
                previousButtonImage: #imageLiteral(resourceName: "previous"),
                nextButtonImage: #imageLiteral(resourceName: "next")
            )
            
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }
    
    @IBOutlet var weekDaysView: VAWeekDaysView!{
        didSet {
            if usedFor != .advanced {
                defaultCalendar.firstWeekday = 4
            } else {
                defaultCalendar.firstWeekday = 1
            }
            let appereance = VAWeekDaysViewAppearance(symbolsType: .short, weekDayTextColor: .black, weekDayTextFont:  UIFont(name: fFONT_MEDIUM, size: 15.0)!, leftInset: 2.0, rightInset: 2.0, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    @IBOutlet var calendarView: UIView!
    @IBOutlet var viewBG: UIView!
    var calendarViewNew: VACalendarView!
   
    var selectedDates : [Date] = []
    var currSelectionStyle : VASelectionStyle = .single
    var usedFor : VASelectionStyle = .single
    var currDate = Date()
    var delegate : CalenderViewDelegate?
    var isForFutureOrder : Bool = false
    var arrFutureDates : [FutureOrderDates] = []
    var isForMonthly : Bool = false
    var arrMonthlyDates : [String] = []
    
    var selectedDate = Date()
    var selectedWeekDate = Date()
   
    var defaultCalendar: Calendar = {
           var calendar = Calendar.current
        calendar.firstWeekday =  4
        
           //calendar.timeZone = TimeZone(secondsFromGMT: 0)!
           
           return calendar
       }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        if usedFor != .advanced {
            currentlyUsingVACalenderFor = usedFor == .multi ? .EarningDate : .SingleStore
        } else {
            currentlyUsingVACalenderFor = .AdvancedOrder
        }
    }
    
    func setUp()
    {
//        self.updateViewConstraints()
//        self.view.layoutIfNeeded()
        if usedFor != .advanced {
            defaultCalendar.firstWeekday = 4
        } else {
            defaultCalendar.firstWeekday = 1
        }
        
        let calendar = VACalendar(startDate: nil, endDate: nil, selectedDate: nil, calendar: defaultCalendar)
        
        calendarViewNew = VACalendarView(frame: .zero, calendar: calendar)
        calendarViewNew.showDaysOut = true
        calendarViewNew.selectionStyle = currSelectionStyle
        calendarViewNew.monthDelegate = monthHeaderView
        calendarViewNew.dayViewAppearanceDelegate = self
        calendarViewNew.monthViewAppearanceDelegate = self
        calendarViewNew.calendarDelegate = self
        calendarViewNew.scrollDirection = .horizontal
        let dates = getWeekDates(from: currDate)
        selectedDates.removeAll()
        selectedDates.append(contentsOf: dates)
        let dt = usedFor == .multi ? dates : [currDate]
       
        calendarViewNew.selectDates(dt)
        
        if isForFutureOrder {
            var dt : [(Date, [VADaySupplementary])] = []
           let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            for futureDt in arrFutureDates {
                dt.append((df.date(from: futureDt.futureOrderDate!)!, [VADaySupplementary.bottomDots([THEME_COLOR])]))
            }
            calendarViewNew.setSupplementaries(dt)
        }
        
        if isForMonthly {
            var dt : [(Date, [VADaySupplementary])] = []
           let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            for str in arrMonthlyDates {
                dt.append((df.date(from: str)!, [VADaySupplementary.bottomDots([THEME_COLOR])]))
            }
            calendarViewNew.setSupplementaries(dt)
        }
        
        
        calendarView.addSubview(calendarViewNew)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        gesture.numberOfTapsRequired = 1
        viewBG.addGestureRecognizer(gesture)
        
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}
extension CalendarViewVC : VAMonthHeaderViewDelegate , VACalendarViewDelegate
{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
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
    func didTapNextMonth() {
        calendarViewNew.nextMonth()
    }
    
    func didTapPreviousMonth() {
        calendarViewNew.previousMonth()
    }
    func selectedDate(_ date: Date) {
        if usedFor == .multi
        {
            if !(selectedDates.contains(date)){
                let selectedDate = date
                let weekDates = getWeekDates(from: selectedDate)
                print(weekDates)
               selectedDates.removeAll()
               selectedDates.append(contentsOf: weekDates)
                calendarViewNew.selectDates(weekDates)
            }
            else{
                delegate?.selectedWeekDates(dates: selectedDates)
                self.dismiss(animated: false, completion: nil)
            }
        }
        else{
                selectedDates.removeAll()
                selectedDates.append(date)
                delegate?.selectedWeekDates(dates: selectedDates)
                self.dismiss(animated: false, completion: nil)
        }
    }
   /* func getWeekDates(from date : Date) -> [Date]
    {
        let day = DateFormatter(format: "EEE").string(from: date)
        print("Day : ",day )
        var newDate = date
        switch day {
        case weekDay.mo.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -5, to: date)!
            break
        case weekDay.tu.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!
            break
        case weekDay.we.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: 0, to: date)!
            break
        case weekDay.th.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            break
        case weekDay.fr.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -2, to: date)!
            break
        case weekDay.sa.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -3, to: date)!
            break
        case weekDay.su.rawValue:
            newDate = Calendar.current.date(byAdding: .day, value: -4, to: date)!
            break
        default:
            break
        }
        //selectWeek(From: newDate)
        var weekDates : [Date] = []
        for index in 0...6
        {
            weekDates.append(Calendar.current.date(byAdding: .day, value: index, to: newDate)!)
        }
        selectedDates.removeAll()
        selectedDates.append(contentsOf: weekDates)
        return weekDates
    }*/
}

extension CalendarViewVC: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 0.0
    }
    
    func rightInset() -> CGFloat {
        return 0.0
    }
    
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont(name: fFONT_BOLD, size: 16.0)!
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .gray
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
    
}

extension CalendarViewVC: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return .lightGray
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
            return UIFont(name: fFONT_MEDIUM, size: 15.0)!
        default:
            return UIFont(name: fFONT_REGULAR, size: 15.0)!
        }
    }
    func shape() -> VADayShape {
        return .square
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 0
        default:
            return 0
        }
    }
    
    
}
