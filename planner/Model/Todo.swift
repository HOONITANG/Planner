//
//  Todo.swift
//  SheeeetTest
//
//  Created by Taehoon Kim on 2021/09/03.
//

import Foundation
import RealmSwift

class Todo:Object {
    @objc dynamic var sectionTitle: String = ""
    @objc dynamic var title: String = "New Task"
    @objc dynamic var date: Date = Date()
    @objc dynamic var status: Int = 0
    @objc dynamic var sort: Int = 0
    @objc dynamic var totalSeconds: Int = 0
    @objc dynamic var isFix: Bool = false
    @objc dynamic var statusStr: String {
        switch status {
        case 0:
            return "미완료"
        case 1:
            return "완료"
        case 2:
            return "시작"
        case 3:
            return "고정"
        case 4:
            return "미룸"
        case 5:
            return "삭제"
        default:
            return "미완료"
        }
    }
    
    static func dateInit() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        return date
    }
    
    let dayEvents = List<EventDay>()
    
    var parentSection = LinkingObjects(fromType: SectionTodo.self, property: "todos")
}
//
//struct TodoSection {
//    var data: [String: [Todo]]
//}
