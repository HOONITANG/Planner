//
//  MemoTableCell.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/26.
//

import UIKit

protocol MemoTableCellDelegate {
    func didTapWeekMemoRemoveButton(_ cell: MemoTableCell)
}

class MemoTableCell: UITableViewCell {

    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    var delegate:MemoTableCellDelegate?
    
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
                checkImage.image = UIImage(systemName: "square")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            case 1:
                checkImage.image = UIImage(systemName: "square.split.diagonal.2x2")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            default:
                checkImage.image = UIImage(systemName: "square")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapWeekMemoRemoveButton(_ sender: UIButton) {
        delegate?.didTapWeekMemoRemoveButton(self)
    }
}
