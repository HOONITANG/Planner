//
//  SettingHeaderCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/29.
//

import UIKit

class SettingHeaderCell: UITableViewHeaderFooterView {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.font = UIFont.openSansBold(size: 22)
    }
    
}
