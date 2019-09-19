//
//  CustomDatePicker.swift
//  TestCustomDatePicker
//
//  Created by Jon Lund on 9/18/19.
//  Copyright © 2019 Mana Mobile, LLC. All rights reserved.
//

import UIKit

public protocol CustomDatePickerDelegate: class {
	func pickerView(_ pickerView: CustomDatePicker, changedDate: Date)
	func pickerViewDidFinish(_ pickerView: CustomDatePicker)
}

fileprivate var pickerFont: UIFont = {
	let f = UIFont.systemFont(ofSize: 54, weight: .bold)
	return f
}()

fileprivate let kDefaultHeight: CGFloat = 400

public class CustomDatePicker: UIInputView {

	private var picker: UIPickerView
	private let dayFormatter: DateFormatter = {
		let d = DateFormatter()
		d.dateFormat = "EEE MMM dd"
		return d
	}()
	private var startOfToday: Date 					// beginning of today
	private var columnSizes: [CGFloat] = []
	private var _date: Date = Date()

	override public var intrinsicContentSize: CGSize { return CGSize(width: 400, height: kDefaultHeight) }
	
	/// delegate that receives date changes
	public weak var delegate: CustomDatePickerDelegate?
	
	/// defaults to now
	public var minDate: Date = Date()
	
	/// defaults to a year from now
	public var maxDate: Date = Date().addingTimeInterval(36500*3600*24)
	
	/// the current selected date
	public var date: Date {
		get { return _date }
	}
	
	/// a bar button group that will give some quick buttons (assign by textField.inputAssistanItem.trailingBarButtonGroups = CustomDatePicker.shortcuts
	public var shortcuts: UIBarButtonItemGroup {
		let bbiASAP = UIBarButtonItem(title: "ASAP", style: .done, target: self, action: #selector(asapPressed(_:)))
		let bbiDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
		return UIBarButtonItemGroup(barButtonItems: [bbiASAP,bbiDone], representativeItem: nil)
	}
	
	/// set the font that will be used by the picker
	static func setPickerFont(_ font: UIFont) {
		pickerFont = font
	}
	
	
	// MARK: - Initializers
	
	override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
		picker = UIPickerView(frame: .zero)
		let today = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: 0, weekdayOrdinal: 0, quarter: 0, weekOfMonth: 0, weekOfYear: 0, yearForWeekOfYear: 0)
		startOfToday = today.date!
		super.init(frame: frame, inputViewStyle: inputViewStyle)
		myInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		picker = UIPickerView(frame: .zero)
		let today = Calendar.current.dateComponents([.calendar, .timeZone, .year,.day,.month], from: Date())
		startOfToday = today.date!
		super.init(coder: aDecoder)
		myInit()
	}
	
	private func myInit() {
		picker.frame = CGRect(origin: .zero, size: frame.size)
		picker.autoresizingMask = [.flexibleWidth,.flexibleHeight]
		picker.showsSelectionIndicator = true
		//autoresizingMask = [.flexibleWidth]
		self.translatesAutoresizingMaskIntoConstraints = false
		addSubview(picker)
		picker.delegate = self
		self.allowsSelfSizing = true
		updateColumnSizes()
		self.backgroundColor = .lightGray
		
		let heightConstraint = NSLayoutConstraint(
			item:self,
			attribute:NSLayoutConstraint.Attribute.height,
			relatedBy:NSLayoutConstraint.Relation.equal,
			toItem:nil,
			attribute:NSLayoutConstraint.Attribute.notAnAttribute,
			multiplier:0.0,
			constant:kDefaultHeight)
		
		self.addConstraint(heightConstraint)
		setUIForDate(_date, animated: false)
	}
	
	
	// MARK: - View Methods
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		updateColumnSizes()
	}


	// MARK: - Public Member Methods
	
	public func setDate(_ newValue: Date, animated: Bool = false) {
		_date = newValue
		setUIForDate(newValue, animated: animated)
	}
	
	@IBAction func asapPressed(_ sender: UIBarButtonItem) {
		_date = Date()
		setUIForDate(_date, animated: true)
		delegate?.pickerView(self, changedDate: _date)
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		guard picker.isChanging == false else { return }
		delegate?.pickerViewDidFinish(self)
	}


	// MARK: - Private Member Methods
	
	private func updateColumnSizes() {
		let w = self.frame.size.width
		columnSizes = [
			w * 0.5,
			w * 0.2,
			w * 0.13,
			w * 0.13
		]
	}
	
	private func valueChanged() {
		let dayOffset = picker.selectedRow(inComponent: 0)
		let amPm = picker.selectedRow(inComponent: 3)
		let hour = picker.selectedRow(inComponent: 1) + (amPm > 0 ? 12 : 0)
		let min  = picker.selectedRow(inComponent: 2)
		let time = TimeInterval( dayOffset*3600*24 + hour*3600 + min*60 )
		
		let newDate = startOfToday.addingTimeInterval(time)
		if newDate < minDate {
			self._date = minDate
			setUIForDate(minDate, animated: true)
		}
		else if newDate > maxDate {
			self._date = maxDate
			setUIForDate(maxDate, animated: true)
		}
		else {
			self._date = newDate
		}
		delegate?.pickerView(self, changedDate: self._date)
	}
	
	private func setUIForDate(_ date: Date, animated: Bool) {
		let dayOffset = date.timeIntervalSince(minDate)
		guard dayOffset > -0.1 else { return }
		
		let day = Int(dayOffset/(3600*24))
		picker.selectRow(day, inComponent: 0, animated: animated)

		let components = Calendar.current.dateComponents([.hour,.minute], from: date)
		picker.selectRow(components.hour!.fromHour, inComponent: 1, animated: animated)
		picker.selectRow(components.minute!, inComponent: 2, animated: animated)
		picker.selectRow(components.hour! < 12 ? 0 : 1, inComponent: 3, animated: animated)
	}
	
}


// MARK: -

extension CustomDatePicker: UIPickerViewDelegate {
	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		valueChanged()
	}
	
	public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 64
	}
	
	public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		return columnSizes[component]
	}
	
}


// MARK: -

extension CustomDatePicker: UIPickerViewDataSource {
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 4
	}
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:		return 1000		// arbitrary
		case 1:		return 12
		case 2:		return 60
		case 3:		return 2
		default:	fatalError()
		}
	}
	
	public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		let label = UILabel(frame: .zero)
		label.textAlignment = .right
		label.attributedText = self.pickerView(pickerView, attributedTitleForRow: row, forComponent: component)
		label.sizeToFit()
		return label
	}
	
	public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		switch component {
		case 0:
			if row == 0 { return "Today".attributed }
			return dayFormatter.string(from: startOfToday.addingTimeInterval(TimeInterval(row*24*3600))).attributed
			
		case 1:
			return (row.toHour).description.attributed
			
		case 2:
			return String(format: "%02d", row).attributed
			
		case 3:
			return (row == 0 ? "AM" : "PM").attributed
			
		default: fatalError()
		}
	}
}


// MARK: - Extensions

fileprivate extension String {
	var attributed: NSAttributedString {
		return NSAttributedString(string: self, attributes: [
			NSAttributedString.Key.font : pickerFont,
			])
	}
	
	func attributedWithColor(_ color: UIColor) -> NSAttributedString {
		return NSAttributedString(string: self, attributes: [
			NSAttributedString.Key.font : pickerFont,
			NSAttributedString.Key.foregroundColor: color
			])
	}
}

fileprivate extension UIView {
	func descendantScrollviews() -> [UIScrollView] {
		var myScrollviews = subviews.compactMap { $0 as? UIScrollView }
		for child in subviews {
			myScrollviews.append(contentsOf: child.descendantScrollviews())
		}
		return myScrollviews
	}
}

fileprivate extension UIPickerView {
	var isChanging: Bool {
		let allScrollViews = self.descendantScrollviews()
		return allScrollViews.reduce (false) { $0 || $1.isDecelerating }
	}
}

fileprivate extension Int {
	var toHour: Int {		return self == 0 ? 12 : self	}
	var fromHour: Int {		return self%12	}
}
