//
//  UITextField+InputView.swift
//  planner
//
//  Created by Taehoon Kim on 2021/11/03.
//

import UIKit

extension UITextField {
    func setDatePickerAsInputViewFor(target: Any, selector: Selector, picker: UIDatePicker) {
        let screenWidth = UIScreen.main.bounds.width
     
        self.inputView = picker
        
        // If the date field has focus, display a date picker instead of keyboard.
        // Set the text to the date currently displayed by the picker.
      
        // toolbar
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 40.0))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: selector)
        toolBar.setItems([cancel,flexibleSpace,done], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }

}
