//
//  CustomModalTextField.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/14.
//

import UIKit

protocol CustomModalForTextFieldDelegate {
    func okButtonTapped(idx: Int, textFieldValue: String)
    func okButtonAddTapped(textFieldValue: String)
    func cancelButtonTapped()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    func textFieldDidEndEditing(_ textField: UITextField)
}

class CustomModalForTextField: UIViewController  {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleString: UILabel!
    @IBOutlet weak var descriptionString: UILabel!
    @IBOutlet weak var textField: UITextField!
   
    var delegate: CustomModalForTextFieldDelegate? = nil
    var modalTitle: String!
    var modalDescription: String!
    var idxForSection: Int!
    var isModify: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        if isModify {
            textField.text = modalTitle
            textField.accessibilityLabel = "modify"
            textField.accessibilityIdentifier = String(idxForSection)
        } else {
            textField.text = ""
            textField.accessibilityLabel = "add"
        }
        
        titleString.text = modalTitle
        descriptionString.text = modalDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    func setUpView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        if isModify {
            delegate?.okButtonTapped(idx: idxForSection, textFieldValue: textField.text!)
        }
        else {
            delegate?.okButtonAddTapped(textFieldValue: textField.text!)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomModalForTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(textField) ?? false
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        delegate?.textFieldDidEndEditing(textField)
//    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldEndEditing(textField) ?? false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(textField)
    }
}
