//
//  NoticeTableViewCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/11/22.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var noticeContent: UIStackView!
    @IBOutlet weak var noticeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
