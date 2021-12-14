//
//  MemoTableFooterCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/26.
//

import UIKit

class MemoTableFooterCell: UITableViewHeaderFooterView {

    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.accessibilityLabel = "memoView"
        textField.returnKeyType = .done
        // Initialization code
    }

}
