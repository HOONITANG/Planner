//
//  SectionTodo.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/12.
//

import Foundation
import RealmSwift

class SectionTodo:Object {
    @objc dynamic var title: String = ""
    @objc dynamic var createDate: Date = Date()
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var sort: Int = 0
    let todos = List<Todo>()
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    override static func primaryKey() -> String? {
        return "_id"
    }
}


