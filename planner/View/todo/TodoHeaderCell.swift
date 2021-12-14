//
//  TodoHeaderCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/19.
//

import UIKit

protocol TodoHeaderCellDelegate {
    func didTapSettingButton(_ sender: UIButton, section: Int?)
}

class TodoHeaderCell: UITableViewHeaderFooterView {
//    @IBOutlet weak var titleWrapperView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var headerButton: UIButton!
    var section: Int?
    var delegate: TodoHeaderCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        titleWrapperView.layer.cornerRadius = 15
//        titleWrapperView.backgroundColor = .systemGray6
  
        //title.font = UIFont.openSansBold(size: 17)
        //title.textColor = UIColor(rgb: K.BrandColors.black)
    }
    
    @IBAction func didTapSettingButton(_ sender: UIButton) {
        delegate?.didTapSettingButton(sender, section: section)
    }
}
