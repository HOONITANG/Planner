//
//  TestTableCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/19.
//

import UIKit

class TestTableCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
