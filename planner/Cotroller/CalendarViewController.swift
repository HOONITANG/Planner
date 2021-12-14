//
//  CalendarViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/09.
//

import UIKit
import FSCalendar
import RealmSwift

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarTitle: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goToDailyButton: UIButton!
    //let sectionTitle:[String] = ["미룬일", "Todo"]
    var todoSection = [SectionData]()
    var todoItems:Results<Todo>?
    var todoForEventCount:Results<Todo>?
    let realm = try! Realm()
    var dateHelper = DateHelper()
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return dateHelper.dateInit()
    }()
    var dateForDailyVC: Date?
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        calendarInitSytle()
        goToDailyButton.setTitle("Daily", for: .normal)
        goToDailyButton.titleLabel?.font = UIFont.openSansRegular(size: 16)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // custom cell
        //        self.tableView.sectionHeaderHeight = 70
        tableView.separatorStyle = .none
        self.tableView.rowHeight = 44
        tableView.register(UINib(nibName: K.headerCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.headerCellIdentifier)
       
        loadTodo(date: today)
        loadTodoStartEndDate()
        
    }
    
    @IBAction func goToDailyPressed(_ sender: UIButton) {
        print("snffldlsl")
        performSegue(withIdentifier: "goToCalendarDaily", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let daliyVC = segue.destination as! DailyViewController
        daliyVC.nvDate = dateForDailyVC
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        //df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "MMMM yyyy"
        return df
    }()
    
    func calendarInitSytle() {
        let today = dateHelper.dateInit()
        calendar.headerHeight = 0
        self.calendarTitle.text = dateFormatter.string(from: calendar.currentPage)
        self.calendarTitle.font = UIFont.openSansBold(size: 20)
        
        self.leftButton.tintColor = UIColor(rgb: K.BrandColors.darkBlue)
        self.rightButton.tintColor = UIColor(rgb: K.BrandColors.darkBlue)
        
        // weekday 폰트,색 설정
        calendar.appearance.weekdayTextColor = UIColor(rgb: K.BrandColors.black)
        calendar.appearance.weekdayFont = UIFont.montserratRegular(size: 16)
        
        // dot event 폰트,색 설정
        calendar.appearance.eventDefaultColor = UIColor(rgb: K.BrandColors.black)
        calendar.appearance.eventSelectionColor = UIColor(rgb: K.BrandColors.darkBlue)
        
        // date 폰트,색 설정
        calendar.appearance.todayColor = nil
        calendar.appearance.titleTodayColor = UIColor(rgb: K.BrandColors.black)
        calendar.appearance.titleFont = UIFont.montserratRegular(size: 16)
 
        calendar.appearance.selectionColor = UIColor(rgb: K.BrandColors.darkBlue)
        self.calendar.select(today)
    }
    
    @IBAction func prevMonthPressed(_ sender: UIButton) {
        scrollCurrentPage(isPrev: true)
    }
    @IBAction func nextMonthPressed(_ sender: UIButton) {
        scrollCurrentPage(isPrev: false)
    }
}

//MARK: - TableView
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Returns the number of sections.
    func numberOfSections(in tableView: UITableView) -> Int {
        return todoSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if todoSection.count != 0 {
            return 80
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if todoSection.count != 0  {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.headerCellIdentifier) as! TodoHeaderCell
            header.title.text = todoSection[section].title
            return header
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if todoSection.count != 0 {
            return 40
        }
        return 0
    }
    
    // Footer Background 색을 제거함.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if todoSection.count != 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            //headerView.backgroundColor = .yellow
            return headerView
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoSection[section].numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let todoData = todoItems?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! calendarItemCell
        let title = todoSection[indexPath.section][indexPath.row].title
        
        cell.label?.text  = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: - Calendar
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    // 날짜를 선택했을 때 동작하는 함ㅅ
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        loadTodo(date: date)
        dateForDailyVC = date
        print("durl")
        print(dateForDailyVC)
        tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count = 0
        // 해당하는 날짜의 Todo의 미룸의 갯수자나
        todoForEventCount?.forEach({ (item) in
            dateHelper.calculateDays(from: item.date, to: date)
            if dateHelper.daysCount == 0 {
                // if status 구문을 사용하지 않으면, Todo의 모든 갯수를 나타낸다.
                if item.status == 4 || item.status == 44 {
                    count += 1
                }
            }
        })
        return count
    }
    
    // Month를 변경했을 때 동작하는 함수
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        loadTodoStartEndDate()
        calendarTitle.text = dateFormatter.string(from: calendar.currentPage)
    }
    
    // Calendar의 Event갯수를 불러오기 위한 함수
    func loadTodoStartEndDate() {
        let startDate: Date?
        let endDate: Date?
        if self.calendar.scope == .week {
            startDate = self.calendar.currentPage
            endDate = self.calendar.gregorian.date(byAdding: .day, value: 6, to: startDate!)
        } else { // .month
            let indexPath = self.calendar.calculator.indexPath(for: self.calendar.currentPage, scope: .month)
            startDate = self.calendar.calculator.monthHead(forSection: (indexPath?.section)!)!
            endDate = self.calendar.gregorian.date(byAdding: .day, value: 41, to: startDate!)
        }
        loadTodoCount(startDate:startDate!, endDate: endDate!)
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
}

//MARK: - realm

extension CalendarViewController {
    //MARK: - Data Manipulation Methods
    func save(todo: Todo) {
        do {
            try realm.write {
                realm.add(todo)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadTodo(date: Date = Date()) {
        let start = Calendar.current.startOfDay(for: date)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        todoItems = realm.objects(Todo.self).filter("date BETWEEN %@", [start, end]).sorted(byKeyPath: "status", ascending: false)
        
        loadTodoSection()
        tableView.reloadData()
    }
    
    func loadTodoSection() {
        todoSection = [SectionData]()
        var todoArray = [Todo]()
        var postPoneArray = [Todo]()
        
        todoItems?.forEach({ (item) in
            let status = item.status
            // 0 - 미룬일, 1 - Todo
            let todoKey = status == 44 || status == 4 ? 0: 1
        
            // 미룬일
            if todoKey == 0 {
                postPoneArray.append(item)
            }
            // Todo
            else {
                todoArray.append(item)
            }
        })
        
        let section1 = SectionData(title: "미룬일", data: postPoneArray)
        let section2 = SectionData(title: "Todo", data: todoArray)

        if postPoneArray.count > 0 {
            todoSection.append(section1)
        }
        
        if todoArray.count > 0 {
            todoSection.append(section2)
        }
    }
    
    func loadTodoCount(startDate:Date, endDate:Date) {
        
        todoForEventCount = realm.objects(Todo.self).filter("date BETWEEN %@", [startDate, endDate])
        
        tableView.reloadData()
        calendar.reloadData()
    }
    
}
