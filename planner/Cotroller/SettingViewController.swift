//
//  SettingViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/29.
//

import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let settingList = K.settingList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: K.settingHeaderCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.settingHeaderCellIdentifier)
        
        // Do any additional setup after loading the view.
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

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if settingList.count != 0 {
            return 44
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if settingList.count != 0  {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.settingHeaderCellIdentifier) as! SettingHeaderCell
            header.title.text = settingList[section].title
            return header
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if settingList.count != 0 {
            return 44
        }
        return 0
    }
    
    // Footer Background 색을 제거함.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if settingList.count != 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            //headerView.backgroundColor = .yellow
            return headerView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList[section].item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: K.settingCellIdentifier, for: indexPath) as! SettingCell
        
        let sectionData = settingList[indexPath.section]
        let sectionItem = sectionData.item[indexPath.row]

        cell = setViewForSetting(cell: cell, sectionItem: sectionItem)
        //cell.accessoryType = .disclosureIndicator
        
        cell.label?.text  = sectionItem.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setClickForSetting(indexPath: indexPath)
    }
}

extension SettingViewController {
    // 화면 설정
    func setViewForSetting(cell:SettingCell, sectionItem: SettingItem) -> SettingCell {
        switch sectionItem.tag {
        case "goToPremium":
            cell.accessoryType = .disclosureIndicator
        case "goToNotice":
            cell.accessoryType = .disclosureIndicator
        case "goToStore":
            cell.accessoryType = .disclosureIndicator
        case "goToLicense":
            cell.accessoryType = .disclosureIndicator
        case "goToTermsOfUse":
            cell.accessoryType = .disclosureIndicator
        case "goToPrivacy":
            cell.accessoryType = .disclosureIndicator
        
        case "version":
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:40,height:20))
            label.text = K.appVersion
            cell.accessoryView = label
        default:
            return cell
        }
        
        return cell
    }
    
    // 클릭 이동 설정
    func setClickForSetting(indexPath: IndexPath) {
        let sectionData = settingList[indexPath.section]
        let sectionItem = sectionData.item[indexPath.row]
    
        if sectionItem.tag == "goToPremium" {
            self.performSegue(withIdentifier: "goToPremium", sender: self)
        }
        else if sectionItem.tag == "goToNotice" {
            self.performSegue(withIdentifier: "goToNotice", sender: self)
        }
        else if sectionItem.tag == "goToLicense" {
            self.performSegue(withIdentifier: "goToLicense", sender: self)
        }
        else if sectionItem.tag == "goToTermsOfUse" {
            self.performSegue(withIdentifier: "goToTermsOfUse", sender: self)
        }
        else if sectionItem.tag == "goToPrivacy" {
            self.performSegue(withIdentifier: "goToPrivacy", sender: self)
        }
        else if sectionItem.tag == "goToStore" {
            print("goToAppStore")
        }
        else if sectionItem.tag == "copyEmail" {
            print("copyEmail")
            UIPasteboard.general.string = K.devEmail
            
            self.toastMessage("email copied Successfully")
        }
        
    }
}

extension SettingViewController {
    func toastMessage(_ message: String){
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let window = keyWindow else {return}
        
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 16)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)

        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)

        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

        UIView.animate(withDuration: 1, animations: {
            messageLbl.alpha = 0
        }) { (_) in
            messageLbl.removeFromSuperview()
        }
        }
    }
}
