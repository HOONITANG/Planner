//
//  TodoCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/19.
//

import UIKit

class TodoCell: UITableViewCell {

    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var toDoLabel: UILabel!
    
    var status = 0 {
        didSet {
            updateImage()
        }
    }
    
    // 44: 미룬 내용을 하루 지났을 때 또다시 가져오지 않기 위해서 추가함
    // 0-미완료, 1-완료=중지, 2-시작, 3-중요 4-미룸, 44- 미룸 default-대기
    func updateImage() {
        switch status {
            case 0:
                checkmarkImageView.image = UIImage(systemName: "square")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            case 1:
                checkmarkImageView.image = UIImage(systemName: "square.split.diagonal.2x2")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            case 2:
                checkmarkImageView.image = UIImage(systemName: "square.split.diagonal")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            case 3:
                checkmarkImageView.image = UIImage(systemName: "pin.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            case 4:
                checkmarkImageView.image = UIImage(systemName: "arrow.right.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            case 44:
                checkmarkImageView.image = UIImage(systemName: "arrow.right.square")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            default:
                checkmarkImageView.image = UIImage(systemName: "square")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.backgroundColor = .clear
//        self.tintColor = .clear
//        checkmarkImageView?.image?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
//        toDoLabel?.font = UIFont.montserratRegular(size: 24)
//        toDoLabel?.textColor = UIColor(rgb: K.BrandColors.darkBlue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
