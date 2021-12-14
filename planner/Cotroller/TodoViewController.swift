//
//  TodoViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/28.
//

import UIKit
//import Sheeeeeeeeet
import EventKit
import CalendarKit
import RealmSwift

class TodoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dateHelper = DateHelper()
    var todoAllItems:Results<Todo>?
    var todoSections:Results<SectionTodo>?
    var eventDayItems:Results<EventDay>?
    let realm = try! Realm()
    let dailyVC = DailyViewController()
    var getValueFromOtherView = Date()
    var sectionTitles:[String] = []
    //var selectedDate: Date = Date()
    @IBOutlet weak var floatNotice: UILabel!
    @IBOutlet weak var todoCount: UILabel!
    @IBOutlet weak var todoDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewInintSytle()
        tableView.delegate = self
        tableView.dataSource = self
    
        NotificationCenter.default.addObserver(self, selector: #selector(loadTodoView), name: NSNotification.Name(rawValue: "loadTodoView"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTodoTable), name: NSNotification.Name(rawValue: "reloadTodoTable"), object: nil)
        
        loadSection()
        
        //폰트 설정
//        floatNotice.font = UIFont.montserratRegular(size: 16)
//        todoCount.font = UIFont.montserratRegular(size: 16)
    }
    
    func updateData() {
        var count = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        todoSections?.forEach({ (_sectionItem) in
            let todos = loadTodo(todos: _sectionItem.todos)
            
            count += todos.filter("status != 1").count
        })
        ///let count = todoAllItems?.filter("status != 1").count ?? 0
        todoCount.text = String(count)
        todoDate.text = dateFormatter.string(from: getValueFromOtherView)
    }
    
    @objc func loadTodoView(_ notification: Notification) {
        if(notification.object != nil) {
            getValueFromOtherView = notification.object as! Date
        }
        // 필요한 todo 호출
        //self.loadTodo(date: getValueFromDaily)
        self.loadSection()
        //self.loadTodo(date: getValueFromOtherView)
        self.tableView.reloadData()
    }

    
    
}

//MARK: - TableView
extension TodoViewController: UITableViewDelegate, UITableViewDataSource{
  
    func tableViewInintSytle() {
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
    
        tableView.register(UINib(nibName: K.todoCellNibName, bundle: nil), forCellReuseIdentifier: K.todoCellIdentifier)
        tableView.register(UINib(nibName: K.headerCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.headerCellIdentifier)
        tableView.register(UINib(nibName: K.footerCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.footerCellIdentifier)
        
    }
    
    // section 갯수 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // section height 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sectionTitles.count != 0 {
            return 60
        }
        return 0
    }
    
    // section 뷰 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionTitles.count != 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.headerCellIdentifier) as! TodoHeaderCell
            header.title.text = sectionTitles[section]
//            header.backgroundColor = .white
            header.headerButton.isHidden = true
            return header
        }
        return nil
    }
    
    // section간 여백을 만들기 위한 Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if sectionTitles.count != 0 {
            return 44
        }
        return 0
    }
    
    // data의 수만큼 행이 만들어진다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        let _todos = getTodosByDate(date: getValueFromOtherView, section: section)
        return _todos?.count ?? 0
        //return todoItems?.count ?? 1 -> error
    }
    
    // 해당 셀에 들어갈 뷰와 데이터를 지정해준다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellIdentifier, for: indexPath) as! TodoCell
        let _todos = getTodosByDate(date: getValueFromOtherView, section: indexPath.section)
       
        let selectedTodo = _todos?[indexPath.row]
        let status = selectedTodo?.status ?? 0
        cell.status = status

        cell.toDoLabel.text = selectedTodo?.title ?? "No Task"
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    // Cell 클릭 이벤트 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let _todos = getTodosByDate(date: getValueFromOtherView, section: indexPath.section)
        let selectedTodo = _todos?[indexPath.row]
        let status = selectedTodo?.status
        
        showTodoModal(title: selectedTodo?.title ?? "", indexPath: indexPath, status: status ?? 99, isFix: selectedTodo?.isFix ?? false)
    }
    
}

//MARK: - Todo Modal
extension TodoViewController: TodoModalViewControllerDelegate {
    func didTapTodoStatusView(indexPath: IndexPath, value: Int) {
        // DailyView 업데이트(30분미만일 경우 30분으로 고정)
        // self.dailyVC.updateEventDay()
        let _todos = getTodosByDate(date: getValueFromOtherView, section: indexPath.section)
        guard let selectedTodo = _todos?[indexPath.row] else { return }
        // 시작일 경우
        if value == 2 {
            self.appendEventDay(selectedTodo: selectedTodo)
            self.todoStatusChange(selectedTodo: selectedTodo, value: value)
        }
        else if value == 3 {
            let isFix = selectedTodo.isFix
            self.todoFixChange(selectedTodo: selectedTodo, value: !isFix)
        }
        else if value == 5 {
            self.removeTodo(selectTodo: selectedTodo)
        }
        // 시작과 삭제 외 다른 status일 경우
        else {
            // 선택한 Todo의 모든 dailyView 중지
            self.todoAllScheduleStop(selectedTodo: selectedTodo)
            self.todoStatusChange(selectedTodo: selectedTodo, value: value)
          
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        self.updateData()
        self.tableView.reloadData()
        
    }
    
    func showTodoModal(title: String, indexPath: IndexPath, status: Int, isFix: Bool) {
        let customModal = self.storyboard?.instantiateViewController(identifier: "TodoModalViewController") as! TodoModalViewController
        customModal.delegate = self
        
        // modal Style의 종류
        customModal.modalPresentationStyle = .overCurrentContext
        // 어디까지 modal View가 덮을 것인가,
        // true속성이 발견되는 지점까지 Modal이 덮는다.
        customModal.definesPresentationContext = true
        customModal.providesPresentationContextTransitionStyle = true

        // modal을 표시하는데 사용하는 애니메이션 유형
        customModal.modalTransitionStyle = .crossDissolve
        customModal.indexPath = indexPath
        customModal.modalTitle = title
        customModal.originStatus = status
        customModal.isFix = isFix
        
        self.view.endEditing(true)
        
        self.present(customModal, animated: true, completion: nil)
    }
    
    
}

//MARK - Realm
extension TodoViewController {
    func loadSection() {
        todoSections = realm.objects(SectionTodo.self).sorted(byKeyPath: "sort", ascending: true)
        sectionTitles = todoSections?.value(forKeyPath: "title") as! [String]
//        if todoSections?.isEmpty == true {
//            let section = SectionTodo(title:"Daily")
//            try! realm.write {
//                realm.add(section)
//            }
//        }
        updateData()
        tableView.reloadData()
    }
    
    
    func appendTodo(section: Int, title: String) {
        do {
            try realm.write {
                let newTodo = Todo()
                let sectionTodo = todoSections?.filter("title == %@", sectionTitles[section])
                
                if sectionTodo?.count ?? 0 > 0 {
                    newTodo.title = title
                    newTodo.date = getValueFromOtherView
                  
                    sectionTodo?[0].todos.append(newTodo)
                    
                    realm.add(sectionTodo![0])
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        updateData()
        tableView.reloadData()
    }
    
    func removeTodo(selectTodo: Todo) {
        do {
            try realm.write {
                selectTodo.dayEvents.forEach { (item) in
                    item.activedEvent = false
                }
                realm.delete(selectTodo)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        updateData()
        tableView.reloadData()
    }
    
    func getTodosByDate (date:Date = Date(), section: Int) -> Results<Todo>? {
        guard let section = todoSections?.filter("title == %@", sectionTitles[section]) else {
            return nil
        }
        
        if section.count > 0 {
            let start = Calendar.current.startOfDay(for: date)
            let end: Date = {
                let components = DateComponents(day: 1, second: -1)
                return Calendar.current.date(byAdding: components, to: start)!
            }()
            
            let result = section[0].todos.filter("date BETWEEN %@", [start, end])
            
            return result
        }
        else {
            return nil
        }
        
    }
    
    func loadTodo(todos: List<Todo>) -> Results<Todo> {
        
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy-MM-dd"
        //        let currentDate = formatter.string(from:date)
        //    todoItems = realm.objects(Todo.self).filter("date CONTAINS[cd] %@", [date,date])
        
        
        let start = Calendar.current.startOfDay(for: getValueFromOtherView)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        //todoAllItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end])
        return todos.filter("date BETWEEN %@", [start, end])
    }
    
    
    func appendEventDay(selectedTodo:Todo) {
        do {
            try self.realm.write {
                // eventDay생성
                let newEventDay = EventDay()
                let startDate = Date()
                let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDate)
            
                newEventDay.title = selectedTodo.title
                newEventDay.startDate = Date()
                newEventDay.endDate = endDate!
                newEventDay.activedEvent = true
                // newEventDay.calendarColor = "grey"
                // newEventDay.editedEvent = false
                selectedTodo.dayEvents.append(newEventDay)
                self.realm.add(newEventDay)
            }
        }catch {
            print("Error saving context, \(error)")
        }
    }
    
    func todoAllScheduleStop(selectedTodo:Todo) {
        do {
            try self.realm.write {
                selectedTodo.dayEvents.forEach({ (eventDay) in
                    if eventDay.activedEvent {
                        // 전체 시간 업데이트
                        let totalSeconds = selectedTodo.totalSeconds
                        let differenceInSeconds = Int(eventDay.endDate.timeIntervalSince(eventDay.startDate))
                        selectedTodo.totalSeconds = totalSeconds + differenceInSeconds
                        
                        eventDay.activedEvent = false
                    }
                })
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func todoFixChange(selectedTodo: Todo, value: Bool) {
        do {
           try self.realm.write {
            selectedTodo.isFix = value
           }
       }catch {
           print("Error saving context, \(error)")
       }
    }
    
    func todoStatusChange(selectedTodo: Todo, value: Int) {
        do {
           try self.realm.write {
               selectedTodo.status = value
           }
       }catch {
           print("Error saving context, \(error)")
       }
    }
}




//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        let _todos = getTodosByDate(date: getValueFromOtherView, section: indexPath.section)
//        let selectedTodo = _todos?[indexPath.row]
//
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        // bottomSheet에서 보여지는 item 설정
//        let item1 = MenuItem(title: "미완료", value:0, image: UIImage(systemName: "square"))
//        let item2 = MenuItem(title: "완료", value:1, image: UIImage(systemName: "square.split.diagonal.2x2"))
//        let item3 = MenuItem(title: "시작", value:2, image: UIImage(systemName: "square.split.diagonal"))
//        let item4 = MenuItem(title: "중요", value:3, image: UIImage(systemName: "exclamationmark.square"))
//        let item5 = MenuItem(title: "미룸", value:4, image: UIImage(systemName: "arrow.right.square"))
//        let RemoveButton = DestructiveButton(title: "Remove")
//        let cancel = CancelButton(title: "Cancel")
//
//        let menu = Menu(title: "어떤 값으로 바꿀까요?", items: [item1, item2, item3, item4, item5, RemoveButton,cancel])
//
//        presentBottomSheet(menu: menu, selectedTodo: selectedTodo!, cell: cell)
//    }
//
//
//    func presentBottomSheet(menu: Menu, selectedTodo: Todo, cell: UITableViewCell) {
//        // action sheet button 클릭 시 호출되는 함수
//        let sheet = ActionSheet(menu: menu) { sheet, item in
//            if item is DestructiveButton {
//                self.removeTodo(selectTodo: selectedTodo)
//            }
//
//            if let value = item.value as? Int{
//                // Todo의 날짜와 현재날짜와 비교해서 오늘 날짜가 아니면 Alert 호출하기
//                // Date로 변경하면 수정해야할 부분
//                let tDate = selectedTodo.date
//                if self.dateHelper.isToday(date: tDate) == false {
//                    self.presentAlert(title: "오늘 날짜가 아닌 Task는 변경 할 수 없습니다.")
//                    return
//                }
//                // 기존 상태값을 선택 했을 경우
//                if selectedTodo.status == value {
//                    return
//                }
//
//                // 시작을 눌렀을 때
//                if value == 2 {
//                    self.appendEventDay(selectedTodo: selectedTodo)
//                }
//                // 시작이 아닐 경우 동작
//                if value != 2 {
//                    // DailyView 업데이트(30분미만일 경우 30분으로 고정)
//                    self.dailyVC.updateEventDay()
//
//                    // 선택한 Todo의 모든 dailyView 중지
//                    do {
//                        try self.realm.write {
//                            selectedTodo.dayEvents.forEach({ (eventDay) in
//                                eventDay.activedEvent = false
//                            })
//                        }
//                    } catch {
//                        print("Error saving context, \(error)")
//                    }
//                }
//                // status값 변경
//                do {
//                    try self.realm.write {
//                        selectedTodo.status = value
//                    }
//                }catch {
//                    print("Error saving context, \(error)")
//                }
//                //dayView load
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//                self.updateData()
//                self.tableView.reloadData()
//            }
//        }
//
//        // action sheet 보여지는 함수
//        sheet.present(in: self, from: cell) {
//            //print("Action sheet was presented")
//        }
//    }


//MARK: - Alert
//extension TodoViewController {
//    private func presentAlert(title: String) {
//        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//        }))
//
//        present(alert, animated: true, completion: nil)
//    }
//
//}
//
//extension TodoViewController: UITextFieldDelegate{
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.endEditing(true)
//        return true
//    }
//
//    // 유효성 검사에 사용되는 함수
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        let currentZeroDate = dateHelper.dateInit()
//        //let currentZeroDate = Calendar.current.date(byAdding: .day, value: +1, to: dateHelper.dateInit())!
//        dateHelper.calculateDays(from: currentZeroDate, to: getValueFromOtherView)
//
//        // 하루 이상 지났다면 전날 TodoList의 Status값을 변경시키고 오늘날짜로 추가한다.
//        if dateHelper.daysCount < 0 {
//            self.presentAlert(title: "오늘 날짜가 아닌 Task는 추가 할 수 없습니다.")
//            textField.text = ""
//            return false
//        }
//
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
//        print(textField.tag)
//        let section = textField.tag
//        // Use searchTextField.text to get the weather for that city.
//        if let title = textField.text {
//            self.appendTodo(section: section, title: title)
//        }
//
//        textField.text = ""
//
//    }
//}


//    @objc func imageViewTapped(_ sender:UITapGestureRecognizer){
//        print("imageview tapped")
//        let imgView = sender.view as! UIImageView
//        let tIndex = imgView.tag
//        print("your taped image view tag is : \(imgView.tag)")
//
//        if let selectedTodo = self.todoAllItems?[tIndex] {
//            print(selectedTodo)
//        }
//
//    }




//    @objc func reloadTodoTable(_ notification: Notification) {
//        print("reload 요청")
//        self.tableView.reloadData()
//    }
//
