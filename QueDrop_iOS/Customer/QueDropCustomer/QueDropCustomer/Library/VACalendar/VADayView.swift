//
//  VADayView.swift
//  VACalendar
//
//  Created by Anton Vodolazkyi on 20.02.18.
//  Copyright © 2018 Vodolazkyi. All rights reserved.
//

import UIKit

@objc
public protocol VADayViewAppearanceDelegate: class {
    @objc optional func font(for state: VADayState) -> UIFont
    @objc optional func textColor(for state: VADayState) -> UIColor
    @objc optional func textBackgroundColor(for state: VADayState) -> UIColor
    @objc optional func backgroundColor(for state: VADayState) -> UIColor
    @objc optional func borderWidth(for state: VADayState) -> CGFloat
    @objc optional func borderColor(for state: VADayState) -> UIColor
    @objc optional func dotBottomVerticalOffset(for state: VADayState) -> CGFloat
    @objc optional func shape() -> VADayShape
    // percent of the selected area to be painted
    @objc optional func selectedArea() -> CGFloat
}

protocol VADayViewDelegate: class {
    func dayStateChanged(_ day: VADay)
}

class VADayView: UIView {
    
    var day: VADay
    weak var delegate: VADayViewDelegate?
    
    weak var dayViewAppearanceDelegate: VADayViewAppearanceDelegate? {
        return (superview as? VAWeekView)?.dayViewAppearanceDelegate
    }
    
    private var dotStackView: UIStackView {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = dotSpacing
        return stack
    }
    
    private let dotSpacing: CGFloat = 5
    private let dotSize: CGFloat = 5
    private var supplementaryViews = [UIView]()
    private let dateLabel = UILabel()
    
    init(day: VADay) {
        self.day = day
        super.init(frame: .zero)
        
        self.day.stateChanged = { [weak self] state in
            self?.setState(state)
        }
        
        self.day.supplementariesDidUpdate = { [weak self] in
            self?.updateSupplementaryViews()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelect))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupDay() {
        switch currentlyUsingVACalenderFor {
        case .AdvancedOrder,.SingleStore:
            let shortestSide: CGFloat = (frame.width < frame.height ? frame.width : frame.height)
            let side: CGFloat = shortestSide * (dayViewAppearanceDelegate?.selectedArea?() ?? 0.8)
            dateLabel.frame = CGRect(
                       x: 0,
                       y: 0,
                       width: side,
                       height: side
                   )
            break
        case .EarningDate:
            //let shortestSide: CGFloat = (frame.width < frame.height ? frame.width : frame.height)
            
            if DateFormatter(format: "E").string(from: day.date) == "Wed" || DateFormatter(format: "E").string(from: day.date) == "Tue"
            {
                dateLabel.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: frame.height,
                    height: frame.height
                )
                dateLabel.layer.cornerRadius = 3
                dateLabel.clipsToBounds = true
                dateLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner,.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            else
            {
                if DateFormatter(format: "E").string(from: day.date) == "Thu"
                {
                    clipsToBounds = true
                    layer.cornerRadius = 3
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                }
                else if DateFormatter(format: "E").string(from: day.date) == "Mon"
                {
                    clipsToBounds = true
                    layer.cornerRadius = 3
                    layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
                else{
                    clipsToBounds = true
                    layer.cornerRadius = 0
                }
               
                dateLabel.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: frame.width,
                    height: frame.height
                )
            }
            break
        }
        
        
		dateLabel.font = UIFont(name: fFONT_REGULAR, size: 18.0)!
        dateLabel.text = VAFormatters.dayFormatter.string(from: day.date)
        dateLabel.textAlignment = .center
		
       
        dateLabel.center = CGPoint(x: frame.width / 2, y: frame.height / 2)

        setState(day.state)
        addSubview(dateLabel)
        
        updateSupplementaryViews()
    }
    
    @objc
    private func didTapSelect() {
		guard day.state != .out && day.state != .unavailable else { return }
		print("==>",day.date)
        switch currentlyUsingVACalenderFor {
        case .AdvancedOrder:
            if DateFormatter(format: "MM-dd-yyyy").string(from: day.date) ==  DateFormatter(format: "MM-dd-yyyy").string(from: Date()){
                delegate?.dayStateChanged(day)
            }else if day.date > Date() &&  day.date < Calendar.current.date(byAdding: .month, value: 3, to: Date())!{
                delegate?.dayStateChanged(day)
            } else {
                print("==>","Past date selection is not alloed")
            }
            break
        case .EarningDate,.SingleStore:
             if day.date <= Date(){
                   delegate?.dayStateChanged(day)
               } else {
                   print("==>","Future date selection is not alloed")
               }
            break
        }
        
        
    }
	private func getFormateddate(date : Date) -> Date
	{
		return DateFormatter(format: "yyyy-MM-dd").string(from: date).toDate() ?? Date()
	}
    private func setState(_ state: VADayState) {
        if dayViewAppearanceDelegate?.shape?() == .circle && state == .selected {
            dateLabel.clipsToBounds = true
            dateLabel.layer.cornerRadius = dateLabel.frame.height / 2
        }
        
        backgroundColor = dayViewAppearanceDelegate?.backgroundColor?(for: state) ?? backgroundColor
        layer.borderColor = dayViewAppearanceDelegate?.borderColor?(for: state).cgColor ?? layer.borderColor
        layer.borderWidth = dayViewAppearanceDelegate?.borderWidth?(for: state) ?? dateLabel.layer.borderWidth
        switch currentlyUsingVACalenderFor {
        case .AdvancedOrder:
            if DateFormatter(format: "MM-dd-yyyy").string(from: day.date) ==  DateFormatter(format: "MM-dd-yyyy").string(from: Date()){
                dateLabel.textColor = dayViewAppearanceDelegate?.textColor?(for: state) ?? dateLabel.textColor
                dateLabel.font = dayViewAppearanceDelegate?.font?(for: state) ?? dateLabel.font
            }else if day.date < Date() ||  day.date > Calendar.current.date(byAdding: .month, value: 3, to: Date())!{
                dateLabel.textColor = .lightGray
                dateLabel.font = dayViewAppearanceDelegate?.font?(for: state) ?? dateLabel.font
            } else {
                dateLabel.textColor = dayViewAppearanceDelegate?.textColor?(for: state) ?? dateLabel.textColor
                dateLabel.font = dayViewAppearanceDelegate?.font?(for: state) ?? dateLabel.font
            }
            break
        case .EarningDate,.SingleStore:
            if day.date > Date() {
                dateLabel.textColor = .lightGray
                dateLabel.font = dayViewAppearanceDelegate?.font?(for: state) ?? dateLabel.font
            } else {
                dateLabel.textColor = dayViewAppearanceDelegate?.textColor?(for: state) ?? dateLabel.textColor
                dateLabel.font = dayViewAppearanceDelegate?.font?(for: state) ?? dateLabel.font
            }
            break
        }
        
        if currentlyUsingVACalenderFor == .AdvancedOrder || currentlyUsingVACalenderFor == .SingleStore{
            dateLabel.backgroundColor = dayViewAppearanceDelegate?.textBackgroundColor?(for: state) ?? dateLabel.backgroundColor
        }
        else{
            switch state {
            case .selected:
                if DateFormatter(format: "E").string(from: day.date) == "Wed" || DateFormatter(format: "E").string(from: day.date) == "Tue"
                {
                    dateLabel.backgroundColor = THEME_COLOR
                    dateLabel.textColor = .white
                    dateLabel.font =  UIFont(name: fFONT_BOLD, size: 15.0)!
                }
                else
                {
                    dateLabel.backgroundColor = LIGHT_THEME
                    dateLabel.textColor = .black
                    dateLabel.font =  UIFont(name: fFONT_REGULAR, size: 15.0)!
                }
                
                break
            default:
                dateLabel.backgroundColor = .clear
                break
            }
        }
        
        
        updateSupplementaryViews()
    }
    
    private func updateSupplementaryViews() {
        removeAllSupplementaries()
        
        day.supplementaries.forEach { supplementary in
            switch supplementary {
            case .bottomDots(let colors):
                let stack = dotStackView

                colors.forEach { color in
                    let dotView = VADotView(size: dotSize, color: color)
                    stack.addArrangedSubview(dotView)
                }
                let spaceOffset = CGFloat(colors.count - 1) * dotSpacing
                let stackWidth = CGFloat(colors.count) * dotSpacing + spaceOffset
                
                let verticalOffset = dayViewAppearanceDelegate?.dotBottomVerticalOffset?(for: day.state) ?? 0
                stack.frame = CGRect(x: 0, y: dateLabel.frame.maxY + verticalOffset, width: stackWidth, height: dotSize)
                stack.center.x = dateLabel.center.x
                addSubview(stack)
                supplementaryViews.append(stack)
            }
        }
    }
    
    private func removeAllSupplementaries() {
        supplementaryViews.forEach { $0.removeFromSuperview() }
        supplementaryViews = []
    }
    
}
