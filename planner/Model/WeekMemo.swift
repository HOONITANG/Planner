//
//  WeekMemo.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/27.
//

import Foundation
import RealmSwift

class WeekMemo:Object {
    @objc dynamic var title: String = "New Task"
    @objc dynamic var date: Date = Date()
    @objc dynamic var status: Int = 0
    @objc dynamic var sort: Int = 0
}
