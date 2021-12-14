//
//  SectionHeaderWithAddTableViewCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/15.
//

import UIKit

class SectionHeaderWithAddTableViewCell: UITableViewHeaderFooterView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var sortButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        title.font = UIFont.openSansBold(size: 26)
        title.textColor = UIColor(rgb: K.BrandColors.black)
        if let image = UIImage(systemName: "plus") {
            plusButton.setImage(image, for: .normal)
            plusButton.setTitle("", for: .normal)
        }
        
    }

    
}
