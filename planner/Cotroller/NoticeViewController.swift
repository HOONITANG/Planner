//
//  NoticeViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/30.
//

import UIKit

class NoticeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.estimatedRowHeight = 100.0
    }
    
}

extension NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.noticeCellIdentifier, for: indexPath) as! NoticeTableViewCell
        cell.title.text = "ios 1.0.0 수정 내용"
        cell.date.text = "2021.11.22"
        cell.noticeLabel.text = "- ios 배포"
        return cell
    }
    
    
}
