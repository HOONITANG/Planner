//
//  PremiumViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/30.
//

import UIKit

class PremiumViewController: UIViewController {

    @IBOutlet weak var benefit3: UIStackView!
    @IBOutlet weak var benefit2: UIStackView!
    @IBOutlet weak var unlockButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initStyle()
        // Do any additional setup after loading the view.
    }
    
    func initStyle() {
        benefit3.isHidden = true
        benefit2.isHidden = true
        unlockButton.layer.cornerRadius = 15
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
