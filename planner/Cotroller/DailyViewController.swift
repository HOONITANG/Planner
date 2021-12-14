//
//  ViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/27.
//

import UIKit
import RealmSwift
import CalendarKit
import EventKit
import FloatingPanel

class DailyViewController: DayViewController, FloatingPanelControllerDelegate {
    
    var todoItems:Results<Todo>?
    var eventDayItems:Results<EventDay>?
    var prevEventDayItems:Results<EventDay>?
    var updateDailyItems:Results<EventDay>?
    let realm = try! Realm()
    let eventStore = EKEventStore()
    var fpc: FloatingPanelController!
    var dateHelper = DateHelper()
    var selectedDailyViewForEdit: EventDay?
    
    
    public var nvDate: Date?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let desiredDate = nvDate {
            dayView.state?.move(to: desiredDate)
            loadEventDay(date: desiredDate)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadTodoView"), object: desiredDate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
       

        dayView.dayHeaderView.isHidden = true
        dayView.dayHeaderView.heightAnchor.constraint(equalToConstant: 0).isActive = true
      
        print("DailyViewDidLoad")
        //        if let nvDate = nvDate {
        //            calendar.date(from: nvDate)
        //            dayView = DayView(calendar: calendar)
        //            view = dayView
        //        }
        //
        
        
        self.navigationItem.title = "Daily"
        // 캘린더 권한 요청
        requestAccessToCalendar()
        
        // DayView-reload Notification 등록
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        fpc?.removePanelFromParent(animated: true, completion: nil)
        fpc = nil
        
        // FloatingPannel 설정
        fpc = FloatingPanelController()
        
        fpc.delegate = self // Optional
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 6.0
        fpc.surfaceView.appearance = appearance
        fpc.layout = MyFloatingPanelLayout()
        fpc.changePanelStyle()
        
        // Set a content view controller.
        guard let contentVC = storyboard?.instantiateViewController(identifier: "fpc_content") as? TodoViewController else {
            return
        }  
        fpc.set(contentViewController: contentVC)
        
        fpc.track(scrollView: contentVC.tableView)
        
        fpc.addPanel(toParent: self)
        
        // DailyView Update Timer 동작
        // 앱이 꺼지기 전까지, 중지가 없다.
        // 우선은 이렇게 해놓고 생각을 해봐야겠다.
        let timer = CustomTimer { (seconds) in
           // self.updateEventDay()
            self.reloadData()
        }
        timer.timeInterval = 60 * 1 // 1분
        timer.start()
        
    }
    
    // 캘린더 권한 요청
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { (success, error) in
            
        }
    }
    
    //FloatingPannel 숨기는 함수
    func hideFloatingPannel() {
        // Inform the panel controller that it will be removed from the hierarchy.
        fpc.willMove(toParent: nil)
        
        // Hide the floating panel.
        fpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            self.fpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            self.fpc.removeFromParent()
        }
    }
    
    //FloatingPannel 나타내는 함수
    func showFloatingPannel() {
        self.view.addSubview(fpc.view)
        // REQUIRED. It makes the floating panel view have the same size as the controller's view.
        fpc.view.frame = self.view.bounds
        fpc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fpc.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
            fpc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
            fpc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0),
            fpc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
        ])
        self.addChild(fpc)
        // 급작스럽게 내려감.
        fpc.show(animated: true) {
            self.fpc.didMove(toParent: self)
        }
    }
    
    // Calendar에 추가되었을 때 데이터를 가져오는 함수
    // ** 필요한지 살펴보아야함 **
    //    func subscribeToNotifications() {
    //        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
    //    }
    
    @objc func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    //일정 리스트를 가져오는 함수
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        
        var tempDayViewArray:[EKWrapper] = []
        print("update!!")
        //self.updateEventDay()
        self.prevLoadEventDay(date: date)
        // statusChanged()
        
        // indexKey 추가, 날짜 30분 미만인 Date 컨트롤
        prevEventDayItems?.enumerated().forEach {
            let tempDayView = self.initDayView(eventDay: $0.1, index: $0.0)
            tempDayViewArray.append(tempDayView)
        }
        
        
        EventDayView.events = tempDayViewArray
       
        
        return EventDayView.events
    }
    
    func initDayView(eventDay: EventDay, index: Int) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var oneHourComponents = DateComponents()
        oneHourComponents.minute = 30
        
        //let endDate = calendar.date(byAdding: oneHourComponents, to: Date())
        
        
        
        newEKEvent.startDate = eventDay.startDate
        newEKEvent.endDate = eventDay.endDate
        newEKEvent.title = "\(K.dailyIndexKey)\(index)$\(eventDay.title)"
        //newEKEvent.ekId = index
        let black = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        let red = UIColor(red: 200.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        //print(newEKEvent.calendar) // nil -> 캘린더 권한 없을 시 나오는 에러
        newEKEvent.calendar.cgColor = black.cgColor
        
        if eventDay.calendarColor == "red" {
            
        }
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.backgroundColor = UIColor.clear
        newEKWrapper.textColor = .black
        // 시작중일 때
        if eventDay.activedEvent {
            newEKWrapper.backgroundColor = .white
            newEKEvent.calendar.cgColor = red.cgColor
        }
        
        return newEKWrapper
    }
    
    
    //DayView를 클릭 시 동작하는 함수
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        
        let selectedIndex = findEventViewIndex(eventDayView: ckEvent)
        
        
        if selectedIndex != -1, eventDayItems?.count ?? 0 > 0, let selectEventDay = eventDayItems?[selectedIndex] {
            if selectEventDay.activedEvent == true {
                presentAlert(title: S.dailyStopAlert, mesasge: "", cancel: true){
                    self.stopDayView(eventDay: selectEventDay)
                    self.reloadData()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadTodoView"), object: nil)
                }
                return
            }
            else {
                presentAlert(title: S.dailyDeleteAlert, mesasge: "", cancel: true){
                    self.removeDayView(eventDay: selectEventDay)
                    self.reloadData()
                }
                return
            }
        }
        
        
        //let ekEvent = ckEvent.ekEvent
        //presentAlert(title: "현재 Event를 정지하시겠습니까?", mesasge: "최소 기록은 30분으로 설정됩니다.", cancel: true)
        //self.performSegue(withIdentifier: "goToDailyEditView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DailyEditViewController
        destinationVC.selectedEventDay = selectedDailyViewForEdit
    }
    
    //해당 event가 실행중일 경우 중지 alert을 요청함
    private func presentAlert(title:String, mesasge:String, cancel:Bool, completion: @escaping () -> Void ) {
        let alert = UIAlertController(title: title, message: mesasge, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            completion()
        }))
        if cancel == true {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    func findEventViewIndex (eventDayView: EKWrapper) -> Int {
        let title = eventDayView.text
        
        
        // @sdc#!과 $사이의 index값을 찾기위해 사용
        // 예시)
        // @sdc#!12$Todo -> [@sdc#!,12$Todo] -> [12,Todo] -> 12
        // @sdc#!12$$$Todo$$ -> [@sdc#!,12$$$Todo$$] -> [12,"","","",Todo,"",""]

        
        //@sdc#!1$ㅇㅇ
        let seperateTitle = title.components(separatedBy: K.dailyIndexKey)
        let seperateForIndex = seperateTitle[1].components(separatedBy: "$")
        let selectedIndex = seperateForIndex[0]
        
        print("에러대응 findIndex:: ")
        print("selectdIndex::: \(selectedIndex)")
        print(seperateTitle )
        if let ekIdx = Int(selectedIndex) {
            return ekIdx
        }
        return -1
    }
    
    // dayView를 오랫동안 누르고 있을 때 동작하는 함수
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        
        let selectedIndex = findEventViewIndex(eventDayView: ckEvent)
        
        if selectedIndex != -1 {
            if eventDayItems?[selectedIndex].activedEvent == true {
                presentAlert(title: "시작중인 Task는 수정 할 수 없습니다.", mesasge: "", cancel: false){}
                return
            }
        }
        
        //시간 수정
        // ckEvent를 전달해야한다.
//        updateDayViewTime(eventDay: eventDayItems?[selectedIndex], ckEvent: ckEvent)
        
        
        beginEditing(event: ckEvent, animated: true)
    }
    
    // day view를 오랫동안 누른 후 손을 떼었을 때 동작하는 함수
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        // dayView가 시작중이면 아무런 행동을 막는다.
        
        
        guard let editingEvent = event as? EKWrapper else { return }
        
        let selectedIndex = findEventViewIndex(eventDayView: editingEvent)
        
        print("에러대응 클릭::")
       
        print("selectdIndex::: \(selectedIndex)")
        if selectedIndex != -1 {
            updateDayViewTime(eventDay: eventDayItems?[selectedIndex], ckEvent: editingEvent)
//            do {
//                try self.realm.write {
//                    eventDayItems?[selectedIndex].startDate = editingEvent.startDate
//                    eventDayItems?[selectedIndex].endDate = editingEvent.endDate
//
//                }
//            } catch {
//                print("Error saving context, \(error)")
//            }
        }
        
        //        guard let editingEvent = event as? EKWrapper else { return }
        //        if let originalEvent = event.editedEvent {
        //            event.commitEditing()
        //
        //            // 꾹 눌렀을 때 생성했을경우
        //            if originalEvent === editingEvent {
        //                //Event creation flow
        //                presentEditingViewForEvent(editingEvent.ekEvent)
        //            } else {
        //                // Editing Flow
        //                //try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
        //            }
        //
        //        }
        
        reloadData()
    }
    
    //DayHeader의 날짜를 클릭했을 때 동작하는 함수
    override func dayView(dayView: DayView, didMoveTo date: Date) {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSection"), object: date)
    }
    override func dayView(dayView: DayView, willMoveTo date: Date) {
        nvDate = date
        
        loadEventDay(date: date)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadTodoView"), object: date)
        endEventEditing()
    }
    
    // TimeLine 클릭 시 동작하는 함수
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    
    // 좌우로 날짜이동시 동작하는 함수
    // eventForDate가 자동으로 호출되어 TodoLoad를 호출하지 않는다.
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    // TimeLine을 꾹 눌렀을 때 동작하는 함수
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        showFloatingPannel()
        print("didLongPressTimelineAt 동작")
    }
    
    
    func save(todo: Todo) {
        do {
            try realm.write {
                realm.add(todo)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func prevLoadEventDay(date: Date) {
        let start = Calendar.current.startOfDay(for: date)
        let end: Date = {
            let components = DateComponents(day: 1, second: -1)
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        
        prevEventDayItems = realm.objects(EventDay.self).filter("startDate BETWEEN %@ OR endDate BETWEEN %@", [start, end], [start, end])
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
    
    // viewDidLoad, Timer 5분에서 사용
    // 종료를 클릭시에 사용
    
    // updateEventDay 없어도 된다.
    func updateEventDay() {
        print("eventDayItems")
        eventDayItems?.forEach({ (item) in
            do {
                try realm.write {
                    if(item.parentTodo.count > 0) {
                        
                     
                        
                        // 1-완료, 2-시작
                        // 시작중이고 시작시간과 현재시간이 30분 미만이라면 30분으로 설정한다.
                        // 30분이 초과했다면 현지시간을 end시간으로 설정한다.
                        if item.activedEvent {
                            if  Date().minutes(from: item.startDate) <= 30 {
                                item.endDate = Calendar.current.date(byAdding: .minute, value: 30, to: item.startDate)!
                            } else {
                                item.endDate = Date()
                            }
                        }
                        
                        // 업데이트 시 무언갈 여기서 해야한다!!!!
//                        // 기존의 전체 시간에서 해당되는 시간제거
//                        var differenceInSeconds = Int(item.endDate.timeIntervalSince(item.startDate))
//                        var totalSeconds = item.parentTodo[0].totalSeconds
//                        totalSeconds =  totalSeconds - differenceInSeconds
//
//                        // 전체 시간 업데이트
//                        differenceInSeconds = Int(item.endDate.timeIntervalSince(item.startDate))
//                        item.parentTodo[0].totalSeconds = totalSeconds + differenceInSeconds
                    }
                }
            } catch {
                print("Error saving context, \(error)")
            }
        })
    }
    
    func removeDayView(eventDay: EventDay) {
        do {
            try realm.write {
                if eventDay.parentTodo.count > 0 {
                    // 전체 시간 업데이트
                    let totalSeconds = eventDay.parentTodo[0].totalSeconds
                    let differenceInSeconds = Int(eventDay.endDate.timeIntervalSince(eventDay.startDate))
                    eventDay.parentTodo[0].totalSeconds = totalSeconds - differenceInSeconds
                }
                realm.delete(eventDay)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func updateDayViewTime(eventDay:EventDay?,ckEvent: EKWrapper) {
        do {
            try self.realm.write {
                guard let eventDay = eventDay else {
                    return
                }
                
                // ckEvent.endDate
                
                if eventDay.parentTodo.count > 0 {
                  
                    // 기존 시간 제거
                    let totalSeconds = eventDay.parentTodo[0].totalSeconds
                    let differenceInSeconds = Int(eventDay.endDate.timeIntervalSince(eventDay.startDate))
                    if totalSeconds >= differenceInSeconds {
                        eventDay.parentTodo[0].totalSeconds = totalSeconds - differenceInSeconds
                    }
                    eventDay.activedEvent = false
                    
                    // 수정된 시간으로 변경
                    eventDay.startDate = ckEvent.startDate
                    eventDay.endDate = ckEvent.endDate
                    let newDifferenceInSeconds = Int(ckEvent.endDate.timeIntervalSince(ckEvent.startDate))
            
                    eventDay.parentTodo[0].totalSeconds = eventDay.parentTodo[0].totalSeconds + newDifferenceInSeconds
                    
                    print("totalSeconds:: \(eventDay.parentTodo[0].totalSeconds)")
                    print("newDifferenceInSeconds:: \(newDifferenceInSeconds)")
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func stopDayView(eventDay: EventDay) {
        do {
            try realm.write {
                eventDay.parentTodo.first?.status = 1
                if eventDay.activedEvent && eventDay.parentTodo.count > 0 {
                    // 전체 시간 업데이트
                    let differenceInSeconds = Int(eventDay.endDate.timeIntervalSince(eventDay.startDate))
                    eventDay.activedEvent = false
                    eventDay.parentTodo[0].totalSeconds = eventDay.parentTodo[0].totalSeconds + differenceInSeconds
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
    } 
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 15.0
        surfaceView.appearance = appearance
    }
}
