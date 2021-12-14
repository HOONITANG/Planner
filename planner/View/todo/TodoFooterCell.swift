//
//  TodoFooterCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/24.
//

import UIKit

class TodoFooterCell: UITableViewHeaderFooterView {

    @IBOutlet weak var plusImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var line: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //textField.placeholder = "Add Task"
        //textField.borderStyle = .none
        //line.backgroundColor = UIColor(rgb: K.BrandColors.lightGray)
        //textField.textColor = UIColor(rgb: K.BrandColors.lightGray)
        //textField.font = UIFont.montserratRegular(size: 24)
        plusImage.tintColor = UIColor(rgb: K.BrandColors.lightGray)
        textField.returnKeyType = .done
        
//        imageView.contentMode = .AspectFit
        
        // place holder 설정
        //https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
    }
}

