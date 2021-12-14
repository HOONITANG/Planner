//
//  Storage.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/07.
//

import Foundation
import RealmSwift

public class Storage {
    
   static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "dateKeyForUserDefault") == nil {
            let dateHelper = DateHelper()
            defaults.set( dateHelper.dateInit(), forKey:"dateKeyForUserDefault")
            return true
        } else {
            return false
        }
    }
    
    static func statusChanged()  {
        // 하루가 지나면 현재 날짜 이전에 있는 모든 완료가 아닌 Todo의 값을 미룸으로 변경한다.
        // 시작중인 dayView는 종료한다.
        // Todo의 값을 오늘날짜에 모두 추가한다.
        if Storage.isFirstTime() == false {
            var dateHelper = DateHelper()
            let realm = try! Realm()
            let loadDate = UserDefaults.standard.object(forKey: K.dateKeyForUserDefault) as! Date
            let currentZeroDate = dateHelper.dateInit()
            //let currentZeroDate = Calendar.current.date(byAdding: .day, value: +1, to: dateHelper.dateInit())!
            dateHelper.calculateDays(from: loadDate, to: currentZeroDate)
            // 하루 이상 지났다면 전날 TodoList의 Status값을 변경시키고 오늘날짜로 추가한다.
         
            if dateHelper.daysCount != 0 {
                
                UserDefaults.standard.set(currentZeroDate, forKey: K.dateKeyForUserDefault)
//                let updateTodoItems:Results<Todo> = realm.objects(Todo.self).filter("date < %@ AND status != 1 AND status != 44",currentZeroDate)
                
                let updateTodoItems:Results<Todo> = realm.objects(Todo.self).filter("date < %@ AND status != 1",currentZeroDate).filter("status != 44")
                
                let updateFixItems:Results<Todo> = realm.objects(Todo.self).filter("isFix == true AND date < %@ AND status == 1",currentZeroDate)
                
                do {
                    try realm.write {
                        updateTodoItems.forEach { (item) in
                            // 완료를 하지 않았을 경우
                            if item.status != 1 && item.parentSection.count > 0 {
                                item.status = 44
                                let newTodo = Todo()
                                newTodo.title = item.title
                                newTodo.isFix = item.isFix
                                newTodo.status = 4
                                newTodo.date = currentZeroDate
                                item.parentSection[0].todos.append(newTodo)
                                
                                
                                realm.add(newTodo)
                                // 해당하는 Section에 Append
                            }
                        }
                        updateFixItems.forEach { (item) in
                            // Fix일 경우
                            if item.status == 1 && item.isFix && item.parentSection.count > 0 {
                                item.isFix = false
                                let newTodo = Todo()
                                newTodo.title = item.title
                                newTodo.status = 0
                                newTodo.isFix = true
                                newTodo.date = currentZeroDate
                                item.parentSection[0].todos.append(newTodo)
                                realm.add(newTodo)
                            }
                        }
                    }
                } catch {
                    print("Error saving context, \(error)")
                }
            }
        }
    }
}
