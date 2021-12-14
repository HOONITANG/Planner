//
//  EventDay.swift
//  SheeeetTest
//
//  Created by Taehoon Kim on 2021/09/03.
//

import Foundation
import RealmSwift

class EventDay: Object {
    @objc dynamic var title: String = "New Event"
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    @objc dynamic var calendarColor: String = "grey"
    @objc dynamic var backgroundColor: String = "grey"
    @objc dynamic var editedEvent: Bool = false
    // 추후에 second로 차이 값 넣을예정
    // 지금 넣어놓을까?
    @objc dynamic var startEndDiffSecond: Int = 0
    @objc dynamic var activedEvent: Bool = false
   
    var parentTodo = LinkingObjects(fromType: Todo.self, property: "dayEvents")
}

class EventDayView {
    static var events: [EKWrapper] = []
}


