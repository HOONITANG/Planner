//
//  HomeViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/18.
//

import UIKit
import SideMenu
import FSCalendar
import RealmSwift
import EventKit
import GoogleMobileAds

class HomeViewController: BaseViewController, MenuCotrollerDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    private var sideMenu: SideMenuNavigationController?
    var dateHelper = DateHelper()
    var selectedDate: Date?
    var sectionTitles:[String] = []
    let eventStore = EKEventStore()
    let realm = try! Realm()
    var eventDayItems:Results<EventDay>?
    var todoSections:Results<SectionTodo>?
    var weekMemo:Results<WeekMemo>?
    var showFooterSection: Int?
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeaderLabel: UILabel!
    private var currentPage: Date?
    
    
    @IBOutlet weak var memoTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var calendarHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var calendarWrapperView: UIView!
    //@IBOutlet weak var memoView: UIView!
    @IBOutlet weak var calendarHeaderView: UIView!
    @IBOutlet weak var tableWrapperView: UIView!
    @IBOutlet weak var memoTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Storage.statusChanged()
        
        // Section Sort수정후
        self.loadSection()
        
        // 처음 설치했을 때, 기본데이터 삽입
        if(!appDelegate.hasAlreadyLaunched){
            //set hasAlreadyLaunched to false
            appDelegate.sethasAlreadyLaunched()
            //display user agreement license
            insertDataForFirstInstall()
        }
        
        if selectedDate == nil {
            selectedDate = dateHelper.dateInit()
        }
        calendarInitSytle()
        tableViewInitStyle()
        calendar.scope = .week
        // memoView.layer.cornerRadius = 15
        memoTableView.layer.cornerRadius = 15
        memoTableView.rowHeight = UITableView.automaticDimension
        memoTableView.estimatedRowHeight = 40
        
        calendarWrapperView.layer.cornerRadius = 15
        calendarHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableWrapperView.layer.cornerRadius = 15
        todoTableView.layer.cornerRadius = 15
        
        todoTableView.rowHeight = UITableView.automaticDimension
        todoTableView.estimatedRowHeight = 40
        
        memoTableView.reloadData()
        todoTableView.reloadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.contentInset.bottom = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBannerViewToBottom()
        requestAccessToCalendar()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        //backBarButtonItem.tintColor = .gray
        navigationItem.backBarButtonItem = backBarButtonItem
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        self.containerView.addGestureRecognizer(tap)
        // Data 호출
        loadSection()
        if selectedDate == nil {
            selectedDate = dateHelper.dateInit()
        }
        loadEventDay(date: selectedDate!)
        loadWeekMemo(date: selectedDate!)
        
        memoTableView.delegate = self
        memoTableView.dataSource = self
        todoTableView.delegate = self
        todoTableView.dataSource = self
        
        // scroll 방지
        memoTableView.alwaysBounceVertical = false
        todoTableView.alwaysBounceVertical = false
        calendar.dataSource = self;
        calendar.delegate = self;
        
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.todoTableView.contentSize.height
            self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
        }
        
        let menu = MenuController(with: SideMenuItem.allCases)
        
        menu.delegate = self
        
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        
        sideMenu?.leftSide = false
        sideMenu?.presentationStyle = .menuSlideIn
        
        SideMenuManager.default.rightMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        view.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(didTapScheduleButton), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeLoadView), name: NSNotification.Name(rawValue: "homeLoadView"), object: nil)
        
        
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    // 캘린더 권한 요청
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { (success, error) in
            
        }
    }
    
    // 처음 설치시 기본 데이터 삽입
    func insertDataForFirstInstall() {
        self.appendWeekMemo(title: "Weekly Sample1")
        self.appendSection(title: "Daily")
        self.loadSection()
        self.appendTodo(section: 0, title: "Sample 1")
    }
    
    @IBAction func tapDidTodayButton(_ sender: UIButton) {
        let today = dateHelper.dateInit()
        calendar.select(today)
        selectedDate = today
        
        self.loadSection()
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.todoTableView.contentSize.height
            self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
            
        }
        self.todoTableView.reloadData()
        self.memoTableView.reloadData()
    }
    
    @objc func homeLoadView(_ notification: Notification) {
        
        self.loadSection()
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.todoTableView.contentSize.height
            self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
            
        }
        self.todoTableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        floatingButton.frame = CGRect(x: view.frame.size.width - 70, y: view.frame.size.height - 160, width: 60, height: 60)
        // Enable scrolling based on content height
        todoTableView.isScrollEnabled = todoTableView.contentSize.height > todoTableView.frame.size.height
        todoTableView.alwaysBounceVertical = false
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "MMMM yyyy"
        return df
    }()
    
    @IBAction func didTapCalendarSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            calendar.scope = .week
        }
        else {
            calendar.scope = .month
        }
    }
    func didSelectMenu(named: SideMenuItem) {
        sideMenu?.dismiss(animated: true, completion: nil)
        
        switch named {
        case .settings:
            self.performSegue(withIdentifier: "goToSetting", sender: self)
            
        case .analysis:
            self.performSegue(withIdentifier: "goToAnalysis", sender: self)
        }
        
    }
    
    @IBAction func didTapMenuButton() {
        //        let vc = storyboard?.instantiateViewController(identifier: "DailyScheduleView") as! DailyViewController
        //        vc.modalPresentationStyle = .fullScreen
        //        vc.nvDate = selectedDate
        
        //performSegue(withIdentifier: "goToDaily", sender: self)
        present(sideMenu!, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDaily" {
            let daliyVC = segue.destination as! DailyViewController
            daliyVC.nvDate = selectedDate
        }
    }
    
    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        button.backgroundColor = .systemPink
        
        let image = UIImage(systemName: "arrow.up.and.down",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.4
        
        // Corner Radius
        // button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        
        return button
    }()
    
    @objc private func didTapScheduleButton() {
        //        let alert = UIAlertController(title: "Add Something",
        //                                      message: "Floating button tapped",
        //                                      preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        //        present(alert, animated: true)
        
        self.performSegue(withIdentifier: "goToDaily", sender: self)
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfWeeksInMonth(_ date: Date) -> Int {
        
        let test = Calendar.current.currentWeekNumber(for: date)
        
        print(Calendar.current.weekBoundary(for: date))
        
        return test
        
    }
    
}

extension Calendar {
    /*
     Week boundary is considered the start of
     the first day of the week and the end of
     the last day of the week
     
     iso8601 달력을 사용하면 월요일을 첫날로 지정하거나 달력 자체의 첫 번째 요일 속성을 설정하여 요일이 첫 번째 요일임을 지정할 수 있습니다.
     Calendar(identifier: .iso8601) 또는 yourCalendar.firstWeekday = 2
     
     */
    typealias WeekBoundary = (startOfWeek: Date?, endOfWeek: Date?)
    typealias MonthBoundary = (startOfMonth: Date?, endOfMonth: Date?)
    
    func currentWeekNumber(for date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfMonth, from: date)
    }
    
    func currentWeekBoundary() -> WeekBoundary? {
        return weekBoundary(for: Date())
    }
    
    func weekBoundary(for date: Date) -> WeekBoundary? {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        guard let startOfWeek = self.date(from: components) else {
            return nil
        }
        
        let endOfWeekOffset = weekdaySymbols.count - 1
        let endOfWeekComponents = DateComponents(day: endOfWeekOffset, hour: 23, minute: 59, second: 59)
        guard let endOfWeek = self.date(byAdding: endOfWeekComponents, to: startOfWeek) else {
            return nil
        }
        
        return (startOfWeek, endOfWeek)
    }
    func monthBoundary (for date: Date) -> MonthBoundary? {
        let components = dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = self.date(from: components) else {
            return nil
        }
        var endOfMonthComponents = DateComponents()
        endOfMonthComponents.month = 1
        endOfMonthComponents.second = -1
        
        guard let endOfMonth = self.date(byAdding: endOfMonthComponents, to: startOfMonth) else {
            return nil
        }
        
        return (startOfMonth, endOfMonth)
    }
}

//MARK: - UIGestureRecognizer Tap
extension HomeViewController: UIGestureRecognizerDelegate {
    
    // subView 클릭 가능하게 하는 함수
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: calendar) == true || touch.view?.isDescendant(of: todoTableView) == true {
            return false
        }
        //return true
        return false
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
}

//MARK: - TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource, TodoHeaderCellDelegate {
    
    func didTapSettingButton(_ sender: UIButton, section: Int?) {
        self.performSegue(withIdentifier: "goToSectionManage", sender: self)
        
        //        guard let section = section else {
        //            return
        //        }
        
        // todoTableView.refreshFooter(inSection: section, isHidden: false)
    }
    
    
    func tableViewInitStyle() {
        memoTableView.separatorStyle = .none
        
        memoTableView.register(UINib(nibName: K.memoTableCellNibName, bundle: nil), forCellReuseIdentifier: K.memoTableCellIdentifier)
        memoTableView.register(UINib(nibName: K.memoTableHeaderCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.memoTableHeaderCellIdentifier)
        memoTableView.register(UINib(nibName: K.memoTableFooterCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.memoTableFooterCellIdentifier)
        
        todoTableView.separatorStyle = .none
        todoTableView.register(UINib(nibName: K.todoCellNibName, bundle: nil), forCellReuseIdentifier: K.todoCellIdentifier)
        todoTableView.register(UINib(nibName: K.headerCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.headerCellIdentifier)
        todoTableView.register(UINib(nibName: K.footerCellNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: K.footerCellIdentifier)
        
    }
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return 100
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        return UITableViewCell()
    //    }
    
    
    
    // Header Section Count 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == todoTableView {
            if sectionTitles.count > 0 {
                return sectionTitles.count
            }
            
            return 1
        }
        // Memo Table
        else {
            return 1
        }
        
    }
    
    // Header Section  height 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
        //        if tableView == todoTableView {
        //            if sectionTitles.count != 0 {
        //                return 60
        //            }
        //            return 60
        //        }
        //        // Memo Table
        //        else {
        //            return 60
        //        }
        
    }
    
    // section 뷰 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == todoTableView {
            if sectionTitles.count != 0 {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.headerCellIdentifier) as! TodoHeaderCell
                header.title.text = sectionTitles[section]
                //header.backgroundColor = .white
                header.section = section
                header.delegate = self
                return header
            }
            else {
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.headerCellIdentifier) as! TodoHeaderCell
                header.title.text = S.pleaseAddTag
                
                header.section = section
                header.delegate = self
                
                return header
            }
            
        }
        else {
            let header = memoTableView.dequeueReusableHeaderFooterView(withIdentifier: K.memoTableHeaderCellIdentifier) as! MemoTableHeaderCell
            header.title.text = S.homeWeekGoal
            
            return header
        }
    }
    
    // section간 여백을 만들기 위한 Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == todoTableView {
            if sectionTitles.count != 0 {
                return 72
            }
            return 0
        }
        else {
            return 72
        }
    }
    
    // Footer Background 색을 제거함.
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if tableView == todoTableView {
            if sectionTitles.count != 0 {
                let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.footerCellIdentifier) as! TodoFooterCell
                
                footer.textField.delegate = self
                footer.textField.tag = section
                
                return footer
            }
            return nil
        }
        else {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.memoTableFooterCellIdentifier) as! MemoTableFooterCell
            footer.textField.delegate = self
            
            return footer
        }
        
    }
    
    // data의 수만큼 행이 만들어진다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == todoTableView {
            let _todos = getTodosByDate(date: selectedDate!, section: section)
            return _todos?.count ?? 0
            //return todoItems?.count ?? 1 -> error
        }
        else {
            return weekMemo?.count ?? 0
        }
        
    }
    
    // 해당 셀에 들어갈 뷰와 데이터를 지정해준다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == todoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.todoCellIdentifier, for: indexPath) as! TodoCell
            let _todos = getTodosByDate(date: selectedDate!, section: indexPath.section)
            let selectedTodo = _todos?[indexPath.row]
            
            let status = selectedTodo?.status ?? 0
            cell.status = status
            
            cell.toDoLabel.text = selectedTodo?.title ?? "No Task"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.memoTableCellIdentifier, for: indexPath) as! MemoTableCell
            cell.title.text = weekMemo?[indexPath.row].title
            cell.status = weekMemo?[indexPath.row].status ?? 0
            cell.removeButton.setTitle(S.delete, for: .normal)
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        }
    }
    
    //    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    //        if tableView == todoTableView {
    //            let selectedFooter = view as! TodoFooterCell
    //
    //            guard let showFooterSection = showFooterSection else {
    //                return
    //            }
    //
    //            if showFooterSection == section {
    //                //selectedFooter.textField.becomeFirstResponder()
    //            }
    //            return
    //        } else {
    //            return
    //        }
    //    }
    
    // Cell 클릭 이벤트 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == todoTableView {
            // guard let cell = tableView.cellForRow(at: indexPath) else { return }
            tableView.deselectRow(at: indexPath, animated: true)
            
            let _todos = getTodosByDate(date: selectedDate!, section: indexPath.section)
            let selectedTodo = _todos?[indexPath.row]
            let status = selectedTodo?.status
            
            showTodoModal(title: selectedTodo?.title ?? "", indexPath: indexPath, status: status ?? 99, isFix: selectedTodo?.isFix ?? false)
        } else {
            
            guard let selectedWeekMemo = weekMemo?[indexPath.row] else {
                return
            }
            if selectedWeekMemo.status == 0 {
                self.changeWeekMemoStatus(selectWeekMemo: selectedWeekMemo, value: 1)
            } else {
                self.changeWeekMemoStatus(selectWeekMemo: selectedWeekMemo, value: 0)
            }
            tableView.reloadData()
            
        }
    }
    
    func getTodosByDate (date:Date = Date(), section: Int) -> Results<Todo>? {
        
        if sectionTitles.count <= 0 {
            return nil
        }
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
    
    // 첫 상태 Footer가 모두 안보이는 처리 상태
    // ViewWillFooter에서 Hidden 설정
    // Add버튼을 누른후, focusing
    // ViewWillFooter에서 설정
    
    // 입력 버튼 눌러도 focusing
    // TextField에서 설정
    
    // 다른 View을 누르거나, 다른 Add Button을 누르면 포커싱 해제 및 Hidden 처리
    // refreshFooter을 설정
    // 포커싱은 무조건하나다.
    
    
}

extension UITableView {
    //    func refreshFooter(inSection section: Int, isHidden: Bool) {
    //            UIView.setAnimationsEnabled(false)
    //            beginUpdates()
    //            let footerView = self.footerView(forSection: section) as! TodoFooterCell
    //
    //            if isHidden {
    //                footerView.isHidden = isHidden
    //                footerView.textField.resignFirstResponder()
    //            }
    //            else {
    //                footerView.isHidden = isHidden
    //                footerView.textField.becomeFirstResponder()
    //            }
    //
    //            endUpdates()
    //            UIView.setAnimationsEnabled(true)
    //        }
}


//MARK: - WeekMemoTableCell Delegate
extension HomeViewController: MemoTableCellDelegate {
    func didTapWeekMemoRemoveButton(_ cell: MemoTableCell) {
        
        let index = cell.tag
        
        guard let selectWeekMemo = weekMemo?[index] else {
            return
        }
        removeWeekMemo(selectWeekMemo: selectWeekMemo)
        memoTableView.reloadData()
        DispatchQueue.main.async {
            self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
        }
        
    }
    
}

//MARK: - Calendar
extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    // calender 초기 스타일 설정
    private func calendarInitSytle() {
        calendar.layer.cornerRadius = 15
        calendar.headerHeight = 0
        self.calendarHeaderLabel.text = dateFormatter.string(from: calendar.currentPage)
        //self.calendarHeaderLabel.font = UIFont.openSansBold(size: 20)
        
        //self.leftButton.tintColor = UIColor(rgb: K.BrandColors.darkBlue)
        //self.rightButton.tintColor = UIColor(rgb: K.BrandColors.darkBlue)
        
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
        self.calendar.select(selectedDate)
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.selectedDate!)
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
    }
    
    @IBAction func didTapCalendarLeftButton(_ sender: UIButton) {
        scrollCurrentPage(isPrev: true)
    }
    
    @IBAction func didTapCalendarRightButton(_ sender: UIButton) {
        scrollCurrentPage(isPrev: false)
    }
    
    // Month를 변경했을 때 동작하는 함수
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //loadTodoStartEndDate()
        calendarHeaderLabel.text = dateFormatter.string(from: calendar.currentPage)
    }
    
    // 날짜를 선택했을 때 동작하는 함수
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        print("calenderDate :: \(date)" )
        
        let weekCount = numberOfWeeksInMonth(date)
        print("weekCount::: \(weekCount)")
        
        loadSection()
        loadEventDay(date: date)
        loadWeekMemo(date: date)
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.todoTableView.contentSize.height
            self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
            
        }
        self.todoTableView.reloadData()
        self.memoTableView.reloadData()
    }
    
    // Week,Month에 따라 달력의 Height를 변경하는 함수
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        if calendar.scope == .month {
            calendarHeaderHeight.constant = 34
            //            self.calendarHeaderView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            self.calendarHeaderView.isHidden = false
        }
        else {
            calendarHeaderHeight.constant = 0
            //            self.calendarHeaderView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.calendarHeaderView.isHidden = true
        }
        //            if calendar.scope == .month {
        //                if calendar.headerHeight != 25 {
        //                    calendar.headerHeight = 25
        //                    calendar.appearance.headerTitleColor = UIColor.black
        //                    self.calendarHeight.constant = bounds.height + 24
        //                    self.view.layoutIfNeeded()
        //                    return
        //                }
        //            }else {
        //                if calendar.headerHeight != 1 {
        //                    calendar.headerHeight = 1
        //                    calendar.appearance.headerTitleColor = UIColor.clear
        //                    self.calendarHeight.constant = bounds.height - 24
        //                    self.view.layoutIfNeeded()
        //                    return
        //                }
        //            }
        self.calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

//MARK: TextField Delegate
extension HomeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("did")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // 공백 검사
        if textField.text != "" {
            if textField.accessibilityLabel == "memoView" {
                textField.becomeFirstResponder()
                
                if let title = textField.text {
                    self.appendWeekMemo(title: title)
                }
                
                textField.text = ""
                textField.endEditing(true)
                memoTableView.reloadData()
                
                DispatchQueue.main.async {
                    self.memoTableViewHeight.constant = self.memoTableView.contentSize.height
                }
                
                return true
            }
            else {
                textField.becomeFirstResponder()
                
                let section = textField.tag
                //showFooterSection = section
                
                // Use searchTextField.text to get the weather for that city.
                if let title = textField.text {
                    self.appendTodo(section: section, title: title)
                }
                
                textField.text = ""
                textField.endEditing(true)
                
                
                todoTableView.reloadData()
                
                DispatchQueue.main.async {
                    self.tableViewHeight.constant = self.todoTableView.contentSize.height
                }
                
                return true
            }
        }
        else {
            textField.endEditing(true)
            return false
        }
    }
    
    
    // 유효성 검사에 사용되는 함수
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
        //        print("유효성검사")
        //        if textField.text != "" {
        //            return true
        //        } else {
        //            textField.endEditing(true)
        //            return false
        //        }
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
    }
    
    
    // 엔터눌렀을 때 동작하는 함수
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField 종료")
    }
}





//MARK: - Realm Data Manipulation Methods
extension HomeViewController {
    func loadSection() {
        todoSections = realm.objects(SectionTodo.self).sorted(byKeyPath: "sort", ascending: true)
        sectionTitles = todoSections?.value(forKeyPath: "title") as! [String]
        //        if todoSections?.isEmpty == true {
        //            let section = SectionTodo(title:"Daily")
        //            try! realm.write {
        //                realm.add(section)
        //            }
        //        }
        todoTableView.reloadData()
    }
    
    
    func appendTodo(section: Int, title: String) {
        do {
            try realm.write {
                let newTodo = Todo()
                let sectionTodo = todoSections?.filter("title == %@", sectionTitles[section])
                
                if sectionTodo?.count ?? 0 > 0 {
                    newTodo.title = title
                    newTodo.date = selectedDate!
                    
                    sectionTodo?[0].todos.append(newTodo)
                    
                    realm.add(sectionTodo![0])
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
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
        todoTableView.reloadData()
    }
    
    func loadTodo(todos: List<Todo>) -> Results<Todo> {
        let start = Calendar.current.startOfDay(for: selectedDate!)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        return todos.filter("date BETWEEN %@", [start, end])
    }
    
    func appendEventDay(selectedTodo:Todo) {
        do {
            try self.realm.write {
                // eventDay생성
                let newEventDay = EventDay()
                let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
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
    
    func loadEventDay(date: Date) {
        
        let start = Calendar.current.startOfDay(for: date)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        
        // 호출을 해야 에러가 안생김
        //        print(date)
        //        print(start)
        //        print(end)
        
        eventDayItems = realm.objects(EventDay.self).filter("startDate BETWEEN %@ OR endDate BETWEEN %@", [start, end], [start, end])
    }
    
    
    //
    
    // viewDidLoad, Timer 5분에서 사용
    // 종료를 클릭시에 사용
    func updateEventDay() {
        print("eventDayItems")
        
        eventDayItems?.forEach({ (item) in
            do {
                try realm.write {
                    
                    // 1-완료, 2-시작
                    // 시작중이고 시작시간과 현재시간이 30분 미만이라면 30분으로 설정한다.
                    // 30분이 초과했다면 현지시간을 end시간으로 설정한다.
                    if item.activedEvent {
                        if(item.parentTodo.count > 0) {
                            // 기존의 전체 시간에서 해당되는 시간제거
                            //                            var differenceInSeconds = Int(item.endDate.timeIntervalSince(item.startDate))
                            //                            var totalSeconds = item.parentTodo[0].totalSeconds
                            //                            totalSeconds =  totalSeconds - differenceInSeconds
                            
                            // Daily 업데이트
                            if  Date().minutes(from: item.startDate) <= 30 {
                                item.endDate = Calendar.current.date(byAdding: .minute, value: 30, to: item.startDate)!
                            } else {
                                item.endDate = Date()
                            }
                        }
                    }
                }
            } catch {
                print("Error saving context, \(error)")
            }
        })
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
    func todoStatusChange(selectedTodo: Todo, value: Int) {
        do {
            try self.realm.write {
                selectedTodo.status = value
            }
        }catch {
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
    
    func loadWeekMemo(date: Date) {
        
        let start = Calendar.current.weekBoundary(for: date)!.startOfWeek!
        let end = Calendar.current.weekBoundary(for: date)!.endOfWeek!
        
        weekMemo = realm.objects(WeekMemo.self).filter("date BETWEEN %@", [start, end])
        
    }
    func appendWeekMemo(title: String) {
        do {
            try self.realm.write {
                // eventDay생성
                let newWeekMemo = WeekMemo()
                newWeekMemo.date = selectedDate!
                newWeekMemo.title = title
                self.realm.add(newWeekMemo)
            }
        }catch {
            print("Error saving context, \(error)")
        }
    }
    func removeWeekMemo(selectWeekMemo: WeekMemo ) {
        do {
            try realm.write {
                realm.delete(selectWeekMemo)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func changeWeekMemoStatus(selectWeekMemo: WeekMemo, value: Int) {
        do {
            try self.realm.write {
                selectWeekMemo.status = value
            }
        }catch {
            print("Error saving context, \(error)")
        }
    }
    
    func appendSection(title: String) {
        do {
            try realm.write {
                let newSectionTodo = SectionTodo()
                newSectionTodo.title = title
                realm.add(newSectionTodo)
            }
        } catch let error as NSError {
            print("error - \(error.localizedDescription)")
        }
    }
    
}

//MARK: - Todo Modal
extension HomeViewController: TodoModalViewControllerDelegate {
    func didTapTodoStatusView(indexPath: IndexPath, value: Int) {
        // DailyView 업데이트(30분미만일 경우 30분으로 고정)
        // self.dailyVC.updateEventDay()
        let _todos = getTodosByDate(date: selectedDate!, section: indexPath.section)
        guard let selectedTodo = _todos?[indexPath.row] else { return }
        // 시작일 경우
        if value == 2 {
            self.appendEventDay(selectedTodo: selectedTodo)
            self.todoStatusChange(selectedTodo: selectedTodo, value: value)
            self.todoTableView.reloadData()
            return
        }
        else if value == 3 {
            let isFix = selectedTodo.isFix
            self.todoFixChange(selectedTodo: selectedTodo, value: !isFix)
            return
        }
        if value == 5 {
            self.removeTodo(selectTodo: selectedTodo)
            self.todoTableView.reloadData()
            DispatchQueue.main.async {
                self.tableViewHeight.constant = self.todoTableView.contentSize.height
            }
            return
        }
        // 시작과 삭제 외 다른 status일 경우
        else {
            // 선택한 Todo의 모든 dailyView 중지
            self.updateEventDay()
            self.todoAllScheduleStop(selectedTodo: selectedTodo)
            self.todoStatusChange(selectedTodo: selectedTodo, value: value)
            self.todoTableView.reloadData()
            return
        }
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
