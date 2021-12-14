//
//  SectionManageController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/13.
//

import UIKit
import RealmSwift

class SectionManageController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var todoSections:Results<SectionTodo>?
    let realm = try! Realm()
    var sectionTitles:[String] = [S.tagTitle]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        self.tableView.rowHeight = 44
        tableView.register(UINib(nibName: K.sectionHeaderWithAddTableViewCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.sectionHeaderWithAddTableViewCellIdentifier)
        
        loadSection()
    }
    
    @objc func didTapSortButton() {
        if tableView.isEditing {
            tableView.isEditing = false
        }
        else {
            tableView.isEditing = true
        }
    }
}

extension SectionManageController: UITableViewDelegate,UITableViewDataSource {
    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionTitles.count != 0 {
            return 80
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionTitles.count != 0  {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.sectionHeaderWithAddTableViewCellIdentifier) as! SectionHeaderWithAddTableViewCell
            header.title.text = sectionTitles[section]
            header.plusButton.addTarget(self, action: #selector(showAddCustomModalForTextField), for: .touchUpInside)
            header.sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)
            return header
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if sectionTitles.count != 0 {
            return 40
        }
        return 0
    }
    
    // Footer Background 색을 제거함.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if sectionTitles.count != 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            //headerView.backgroundColor = .yellow
            return headerView
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoSections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let todoData = todoItems?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionManageCell", for: indexPath) as! SectionManageCell
        cell.delegate = self
        
        let title = todoSections?[indexPath.row].title
        cell.tag = indexPath.row
        cell.title?.text  = title
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        swapSection(source: sourceIndexPath.row, destination: destinationIndexPath.row)
        //loadSection()
        //todoSections.swapA
        print("sourceIndexPath.row::  \(sourceIndexPath.row)")
        print("destinationIndexPath.row::  \(destinationIndexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension SectionManageController {
    func loadSection() {
//        todoSections = realm.objects(SectionTodo.self).sorted(byKeyPath: "createDate", ascending: true)
        todoSections = realm.objects(SectionTodo.self).sorted(byKeyPath: "sort", ascending: true)
        
        do {
            try realm.write {
                todoSections?.forEach({ (item) in
                    item.sort = todoSections?.index(of: item) ?? 0
                    
                })
            }
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
        
        todoSections = realm.objects(SectionTodo.self).sorted(byKeyPath: "sort", ascending: true)
        
        tableView.reloadData()
    }
    
    func removeSection(index: Int) {
        do {
            if let obj = todoSections?[index] {
                try realm.write {
                    realm.delete(obj)
                }
            }
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
    }
    
    func modifySection(index: Int, title: String) {
        do {
            if let obj = todoSections?[index] {
                try realm.write {
                    obj.title = title
                }
            }
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
    }
    
    func appendSection(title: String) {
        do {
            try realm.write {
                let newSectionTodo = SectionTodo()
                newSectionTodo.title = title
                newSectionTodo.sort = todoSections?.count ?? 0
                realm.add(newSectionTodo)
            }
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
    }
    func swapSection(source: Int, destination: Int) {
        do {
            if let obj = todoSections?[source], let obj2 = todoSections?[destination]  {
                try realm.write {
                    obj.sort = destination
                    obj2.sort = source
                }
            }
                
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
    }
}

extension SectionManageController: SectionManageCellDelegate {
    func didTapRemoveButtonInCell(_ cell: SectionManageCell) {
        
        let title = todoSections?[cell.tag].title ?? ""
        showCancelCustomModalForTextField(title: title, descriotion: S.modalDeleteDescription, idx: cell.tag)
        
        //removeSection(index: cell.tag)
        //tableView.reloadData()
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSection"), object: nil)
    }
    func didTapModifyButtonInCell(_ cell: SectionManageCell) {
        let title = todoSections?[cell.tag].title ?? ""
        showCustomModalForTextField(title: title, descriotion: S.modalModifyDescription, idx: cell.tag)
    }
}

extension SectionManageController: BasicModalViewControllerDelegate {
    func okButtonTappedForBasic(idx: Int) {
        removeSection(index: idx)
        tableView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeLoadView"), object: nil)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSection"), object: nil)
    }
    
    func cancelButtonTappedForBasic() {
        
    }
    
    func showCancelCustomModalForTextField(title: String, descriotion: String, idx: Int) {
        let customModal = self.storyboard?.instantiateViewController(identifier: "BasicModalViewController") as! BasicModalViewController
        customModal.delegate = self
        
        // modal Style의 종류
        customModal.modalPresentationStyle = .overCurrentContext
        // 어디까지 modal View가 덮을 것인가,
        // true속성이 발견되는 지점까지 Modal이 덮는다.
        customModal.definesPresentationContext = true
        customModal.providesPresentationContextTransitionStyle = true

        // modal을 표시하는데 사용하는 애니메이션 유형
        customModal.modalTransitionStyle = .crossDissolve
        customModal.modalTitle = title
        customModal.modalDescription = descriotion
        customModal.idxForSection = idx
        self.present(customModal, animated: true, completion: nil)
    }
    
    
}

extension SectionManageController: CustomModalForTextFieldDelegate {
    
    
    @objc func showAddCustomModalForTextField() {
        let customModal = self.storyboard?.instantiateViewController(identifier: "CustomModalForTextField") as! CustomModalForTextField
        customModal.delegate = self
        
        // modal Style의 종류
        customModal.modalPresentationStyle = .overCurrentContext
        // 어디까지 modal View가 덮을 것인가,
        // true속성이 발견되는 지점까지 Modal이 덮는다.
        customModal.definesPresentationContext = true
        customModal.providesPresentationContextTransitionStyle = true

        // modal을 표시하는데 사용하는 애니메이션 유형
        customModal.modalTransitionStyle = .crossDissolve
        customModal.modalTitle = S.modalAddTitle
        customModal.modalDescription = S.modalAddDescription
        customModal.isModify = false
    
        self.present(customModal, animated: true, completion: nil)
    }
    
    func okButtonAddTapped(textFieldValue: String) {
        if textFieldValue != "" {
            appendSection(title: textFieldValue)
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeLoadView"), object: nil)
        }
    }
    
    // 유효성검사
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // 엔터시 동작하는 함수
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("Enter!")
        
    }
    
 
    // return 버튼을 탭했을 때 동작하는 함수
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 엔터시 키보드 사라짐
        textField.resignFirstResponder()
        textField.endEditing(true)
        print("retrun Key")
        guard let action = textField.accessibilityLabel else {
            return true
        }
        
        if action == "add" {
            okButtonAddTapped(textFieldValue: textField.text!)
        }
        else if action == "modify" {
            let idx = Int(textField.accessibilityIdentifier!)!
            okButtonTapped(idx: idx, textFieldValue: textField.text!)
        }
        
       
        dismiss(animated: true, completion: nil)
        return true
    }
    
    func okButtonTapped(idx: Int, textFieldValue: String) {
        if textFieldValue != "" {
            modifySection(index: idx, title: textFieldValue)
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homeLoadView"), object: nil)
        
        }
    }
    
    func cancelButtonTapped() {
    }
    
    
    func showCustomModalForTextField(title: String, descriotion: String, idx: Int) {
        let customModal = self.storyboard?.instantiateViewController(identifier: "CustomModalForTextField") as! CustomModalForTextField
        customModal.delegate = self
        
        // modal Style의 종류
        customModal.modalPresentationStyle = .overCurrentContext
        // 어디까지 modal View가 덮을 것인가,
        // true속성이 발견되는 지점까지 Modal이 덮는다.
        customModal.definesPresentationContext = true
        customModal.providesPresentationContextTransitionStyle = true

        // modal을 표시하는데 사용하는 애니메이션 유형
        customModal.modalTransitionStyle = .crossDissolve
        customModal.modalTitle = title
        customModal.modalDescription = descriotion
        customModal.idxForSection = idx
        
            
        self.present(customModal, animated: true, completion: nil)
    }
}

//extension SectionManageController: UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.endEditing(true)
//        return true
//    }
//
//    // 유효성 검사에 사용되는 함수
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else {
//            textField.placeholder = "Type something"
//            return false
//        }
//    }
//
//    // 엔터눌렀을 때 동작하는 함수
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("enter 입력 확인 테스트")
//        // section
////        print(textField.tag)
////        let section = textField.tag
////        // Use searchTextField.text to get the weather for that city.
////        if let title = textField.text {
////            self.appendTodo(section: section, title: title)
////        }
////
////        textField.text = ""
//    }
//}
