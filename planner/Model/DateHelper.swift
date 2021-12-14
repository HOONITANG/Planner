//
//  DateHelper.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/02.
//

import Foundation

struct DateHelper {
    
    let calendar = Calendar.current
    var currentDate = Date()
    let dateFormatter = DateFormatter()
    var daysCount:Int = 0
    
    func isToday(date: Date) -> Bool {
        let currentZeroDate = dateInit()
        let result = calendar.dateComponents([.day], from: currentZeroDate, to: date).day ?? 0 + 1
        if result != 0 {
            return false
        }
        return true
    }
    
    func dateToString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from:date)
        return dateStr
    }
    
    func stringToDate(date: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = dateFormatter.date(from: date) ?? Date()
        return dateObj
    }
    
    func dateInit(hour: Int = 0, minute: Int = 0, seconds: Int = 0) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        return dateFormatter.date(from: date) ?? Date()
    }
    
    //dateHelper.calculateDays(date: "2021-09-04", selectDate: 2021-09-05)
    //dateHelper.dayCount 값: 1
    mutating func calculateDays(from startDate: Date, to selectDate: Date) {
        
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let startDate: Date = dateFormatter.date(from: date) ?? Date()
        self.daysCount = days(from: startDate, to: selectDate)
        //let hundred = calendar.date(byAdding: .day, value: 100, to: startDate)
    }
    
    func days(from date: Date, to: Date) -> Int {
        return calendar.dateComponents([.day], from: date, to: to).day ?? 0 + 1
        
    }
    //MARK: - Second 출력 마스킹
    func secondsToHoursMinuteSeconds(seconds:Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600 )/60, ((seconds % 3600) % 60))
    }

    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)

        return timeString
    }
}
