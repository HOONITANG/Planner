////
////  TodoViewController.swift
////  planner
////
////  Created by Taehoon Kim on 2021/08/28.
////
//
//import UIKit
//import Sheeeeeeeeet
//import EventKit
//import CalendarKit
//import RealmSwift
//
//class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var addTextField: UITextField!
//    var todoItems:Results<Todo>?
//    var eventDayItems:Results<EventDay>?
//    let realm = try! Realm()
//    let dailyVC = DailyViewController()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorStyle = .none
//        addTextField.delegate = self
//        self.tableView.rowHeight = 44
//        
//        addTextField.addBottomBorder()
//        
//        addTextField.placeholder = "New Task"
//        NotificationCenter.default.addObserver(self, selector: #selector(todoLoad), name: NSNotification.Name(rawValue: "TodoLoad"), object: nil)
//        loadTodo()
//    }
//    
//    @objc func todoLoad(_ notification: Notification) {
//        let getValue = notification.object as! Date
//        
//        // 필요한 todo 호출
//        self.loadTodo(date: getValue)
//        // var dateHelper = DateHelper()
//        // dateHelper.calculateDays(date: item.date, selectDate: getValue)
//        
//        
//        self.tableView.reloadData()
//    }
//    
//    // data의 수만큼 행이 만들어진다.
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return todoItems?.count ?? 1
//    }
//    
//    // 해당 셀에 들어갈 데이터를 지정해준다.
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! ToDoItemCell
//        let todoData = todoItems?[indexPath.row]
//        let status = todoData?.status ?? 0
//        
//        // 0-미완료, 1-완료=중지, 2-시작, 3-중요 4-미룸, default-대기
//        switch status {
//        case 0:
//            cell.checkmarkImageView.image = UIImage(systemName: "square")
//        case 1:
//            cell.checkmarkImageView.image = UIImage(systemName: "square.split.diagonal.2x2")
//        case 2:
//            cell.checkmarkImageView.image = UIImage(systemName: "square.split.diagonal")
//        case 3:
//            cell.checkmarkImageView.image = UIImage(systemName: "exclamationmark.square")
//        case 4:
//            cell.checkmarkImageView.image = UIImage(systemName: "arrow.right.square")
//        default:
//            cell.checkmarkImageView.image = UIImage(systemName: "square")
//        }
//        
//        cell.toDoLabel.text = todoData?.title ?? "No Task"
//        
//        return cell
//    }
//    
//    //MARK: - TableView Delegate Methods
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        // bottomSheet에서 보여지는 item 설정
//        let item1 = MenuItem(title: "미완료", value:0, image: UIImage(systemName: "square"))
//        let item2 = MenuItem(title: "완료", value:1, image: UIImage(systemName: "square.split.diagonal.2x2"))
//        let item3 = MenuItem(title: "시작", value:2, image: UIImage(systemName: "square.split.diagonal"))
//        let item4 = MenuItem(title: "중요", value:3, image: UIImage(systemName: "exclamationmark.square"))
//        let item5 = MenuItem(title: "미룸", value:4, image: UIImage(systemName: "arrow.right.square"))
//        let cancel = CancelButton(title: "Cancel")
//        
//        let menu = Menu(title: "어떤 값으로 바꿀까요?", items: [item1, item2, item3, item4, item5, cancel])
//        
//        // action sheet button 클릭 시 호출되는 함수
//        let sheet = ActionSheet(menu: menu) { sheet, item in
//            if let value = item.value as? Int, let todoData = self.todoItems?[indexPath.row]  {
//                
//                if todoData.status == value {
//                    return
//                }
//                
//                var dateHelper = DateHelper()
//                let currentDate = dateHelper.dateInit()
//                dateHelper.calculateDays(date: todoData.date, selectDate: currentDate)
//                if(dateHelper.daysCount != 0) {
//                    print("날짜가 다른날에는 시작할 수 없습니다.")
//                    return
//                }
//                do {
//                    try self.realm.write {
//                        todoData.status = value
//                    }
//                }catch {
//                    print("Error saving context, \(error)")
//                }
//                
//                // 시작을 눌렀을 때
//                if value == 2 {
//                    do {
//                        try self.realm.write {
//                            // eventDay생성
//                            let newEventDay = EventDay()
//                            let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
//                            newEventDay.title = todoData.title
//                            newEventDay.startDate = Date()
//                            newEventDay.endDate = endDate!
//                            newEventDay.activedEvent = true
//                            // newEventDay.calendarColor = "grey"
//                            // newEventDay.backgroundColor = "grey"
//                            // newEventDay.editedEvent = false
//                            self.todoItems?[indexPath.row].dayEvents.append(newEventDay)
//                            self.realm.add(newEventDay)
//                        }
//                    }catch {
//                        print("Error saving context, \(error)")
//                    }
//                    //dayView load
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//                }
//                
//                // 시작이 아닐 경우 동작
//                if value != 2 {
//                    //let lastEventIndex = self.todoItems?[indexPath.row].dayEvents.count ?? 0
//                    
//                    self.dailyVC.updateEventDay()
//                    do {
//                        try self.realm.write {
//                            self.todoItems?[indexPath.row].dayEvents.forEach({ (eventDay) in
//                                eventDay.activedEvent = false
//                            })
//                        }
//                    } catch {
//                        print("Error saving context, \(error)")
//                    }
//                    
//                }
//                self.tableView.reloadData()
//            }
//        }
//        
//        // action sheet 보여지는 함수
//        sheet.present(in: self, from: cell) {
//            //print("Action sheet was presented")
//        }
//    }
//    
//    func secondsToHoursMinuteSeconds(seconds:Int) -> (Int, Int, Int) {
//        return (seconds / 3600, (seconds % 3600 )/60, ((seconds % 3600) % 60))
//    }
//    
//    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
//        var timeString = ""
//        timeString += String(format: "%02d", hours)
//        timeString += " : "
//        timeString += String(format: "%02d", minutes)
//        timeString += " : "
//        timeString += String(format: "%02d", seconds)
//        
//        return timeString
//    }
//    
//    
//    // day를 비교하여 0보다 작을 경우
//    // 시작,미룸,종료 이외에 모두 미룸으로 변경
//    // 시작의 경우 2일이 차이 날경우, timer를 종료하고 완료로 변경
//    func changeStatus() {
//        
//    }
//    
//    // 선택한 todo 지우기
//    // timer가 timer 진행중이라고 알려주고 삭제 alert 요청
//    // 진행 중이 아닐 경우엔 바로 삭제
//    func deleateTodo() {
//        
//    }
//    
//    //MARK: - Data Manipulation Methods
//    func save(todo: Todo) {
//        do {
//            try realm.write {
//                realm.add(todo)
//            }
//        } catch {
//            print("Error saving context, \(error)")
//        }
//        tableView.reloadData()
//    }
//    
//    func loadTodo(date: Date = Date()) {
//        var currentDate = Todo.dateInit()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        currentDate = formatter.string(from:date)
//        
//        todoItems = realm.objects(Todo.self).filter("date CONTAINS[cd] %@", currentDate)
//        tableView.reloadData()
//    }
//    
//    func saveEventDay(eventDay: EventDay) {
//        do {
//            try realm.write {
//                realm.add(eventDay)
//            }
//        } catch {
//            print("Error saving context, \(error)")
//        }
//        tableView.reloadData()
//    }
//    
//}
//
//extension UITextField {
//    func addBottomBorder(){
//        let bottomLine = CALayer()
//        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
//        bottomLine.backgroundColor = UIColor.white.cgColor
//        borderStyle = .none
//        layer.addSublayer(bottomLine)
//    }
//}
//extension TodoViewController: UITextFieldDelegate{
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        addTextField.endEditing(true)
//        return true
//    }
//    
//    // 유효성 검사에 유용함.
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else {
//            textField.placeholder = "Type something"
//            return false
//        }
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        // Use searchTextField.text to get the weather for that city.
//        if let title = addTextField.text {
//            let newTodo = Todo()
//            newTodo.title = title
//            self.save(todo: newTodo)
//            //addTextField.fetchWeather(cityName: city)
//        }
//        
//        addTextField.text = ""
//        
//    }
//}
