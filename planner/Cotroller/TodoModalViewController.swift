//
//  TodoModalViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/20.
//

import UIKit

protocol TodoModalViewControllerDelegate {
    func didTapTodoStatusView(indexPath: IndexPath, value: Int)
}

class TodoModalViewController:UIViewController {
    
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var titleString: UILabel!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var completeImage: UIImageView!
    @IBOutlet weak var postPoneImage: UIImageView!
    @IBOutlet weak var incompleteImage: UIImageView!
    @IBOutlet weak var fixImage: UIImageView!
    @IBOutlet weak var removeImage: UIImageView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var incompleteView: UIView!
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var fixView: UIView!
    @IBOutlet weak var postponeView: UIView!
    @IBOutlet weak var removeView: UIView!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!
    @IBOutlet weak var postPoneLabel: UILabel!
    @IBOutlet weak var incompleteLabel: UILabel!
    @IBOutlet weak var fixLabel: UILabel!
    @IBOutlet weak var removeLabel: UILabel!
    
    var modalTitle: String!
    var originStatus: Int!
    var indexPath: IndexPath!
    var isFix:Bool = false
    var delegate: TodoModalViewControllerDelegate? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view == self.view {
            dismiss(animated: true, completion: nil)
        }
        if touch?.view == self.startView || touch?.view == self.incompleteView || touch?.view == self.completeView || touch?.view == self.fixView || touch?.view == self.postponeView || touch?.view == self.removeView {
            guard let touchIdentifier = touch?.view?.accessibilityIdentifier else {
                return
            }
            
            let todoStatus = Int(touchIdentifier)!
            if todoStatus != originStatus {
                self.delegate?.didTapTodoStatusView(indexPath: indexPath, value: todoStatus)
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleString.text = modalTitle
    }
    func setUpView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        startImage.image = UIImage(systemName: "square.split.diagonal")
        completeImage.image = UIImage(systemName: "square.split.diagonal.2x2")
        postPoneImage.image = UIImage(systemName: "arrow.right.square")
        incompleteImage.image = UIImage(systemName: "square")
        fixImage.image = UIImage(systemName: "pin.fill")
        removeImage.image = UIImage(systemName: "trash.fill")
    
        incompleteView.accessibilityIdentifier = "0"
        completeView.accessibilityIdentifier = "1"
        startView.accessibilityIdentifier = "2"
        fixView.accessibilityIdentifier = "3"
        postponeView.accessibilityIdentifier = "4"
        removeView.accessibilityIdentifier = "5"
        
        startLabel.text = S.start
        completeLabel.text = S.complete
        postPoneLabel.text = S.postpone
        incompleteLabel.text = S.incomplete
        fixLabel.text = S.fix
        removeLabel.text = S.delete
        
        if isFix {
            fixImage.image = UIImage(systemName: "pin.slash.fill")
            fixLabel.text = S.unfix
        }
    }
}
