//
//  ViewController.swift
//  CustomDatePicker
//
//  Created by jonlund on 09/19/2019.
//  Copyright (c) 2019 jonlund. All rights reserved.
//

import UIKit
import CustomDatePicker

class ViewController: UIViewController {
	
	@IBOutlet var tf: UITextField!
	@IBOutlet var picker: CustomDatePicker!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tf.inputView = picker
		tf.inputAssistantItem.leadingBarButtonGroups = []
		tf.inputAssistantItem.trailingBarButtonGroups = [picker.shortcuts]
		picker.delegate = self
		tf.becomeFirstResponder()
	}
	
}

extension ViewController: CustomDatePickerDelegate {
	func pickerView(_ pickerView: CustomDatePicker, changedDate: Date) {
		tf.text = Int(changedDate.timeIntervalSince1970).description
	}
	
	func pickerViewDidFinish(_ pickerView: CustomDatePicker) {
		tf.resignFirstResponder()
	}
	
	
}


