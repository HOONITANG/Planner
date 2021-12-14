//
//  Strings.swift
//  planner
//
//  Created by Taehoon Kim on 2021/11/16.
//

//%@ - string
//%d - int
//%f - float
//%ld - long

import Foundation


struct S {
    
    static let test = "Hello".localized()
    static let test2 = "My Age %d".localized(with: 26, comment: "age")
    // Home
    static let homeWeekGoal = "HomeWeekGoal".localized()
    static let homeDeleteButton = "HomeDeleteButton".localized()
    static let pleaseAddTag = "PleaseAddTag".localized()
    
    // TAG
    static let tagTitle = "TagTitle".localized()
    static let tagModifyButton = "TagModifyButton".localized()
    static let tagDeleteButton = "TagDeleteButton".localized()
    
    static let modalAddTitle = "ModalAddTitle".localized()
    static let modalAddDescription = "ModalAddDescription".localized()
    static let modalModifyDescription = "ModalModifyDescription".localized()
    static let modalDeleteDescription = "ModalDeleteDescription".localized()
    
    // StatusModal
    static let start = "start".localized()
    static let complete = "complete".localized()
    static let postpone = "postpone".localized()
    static let incomplete = "Incomplete".localized()
    static let fix = "fix".localized()
    static let unfix = "unfix".localized()
    static let delete = "delete".localized()
    
    //Daily
    static let dailyStopAlert = "DailyStopAlert".localized()
    static let dailyDeleteAlert = "DailyDeleteAlert".localized()
    
    //Static
    static let noData = "Nodata".localized()
    static let noResult = "NoResult".localized()
    static let staticFilterTitle = "StaticFilterTitle".localized()
    static let staticToday = "StaticToday".localized()
    static let staticTodayDescription = "StaticTodayDescription".localized()
    static let staticWeek = "StaticWeek".localized()
    
    static func monthDescription(with argument: [Double] = []) -> String {
        return String(format: NSLocalizedString("StaticMonthDescription", comment: ""), String(argument[0]),String(argument[1]))
    }
    
    static func weekDescription(with argument: [Double] = []) -> String {
        return String(format: NSLocalizedString("StaticWeekDescription", comment: ""), String(argument[0]),String(argument[1]))
    }
    static let staticWeekDescription = "StaticWeekDescription".localized()
    static let staticMonth = "StaticMonth".localized()
    static let staticMonthDescription = "StaticMonthDescription".localized()
    static let staticCustomButton = "StaticCustomButton".localized()
    
    //CustomStatic
    static func customStaticTagTitle(with argument: [String] = []) -> String {
        return String(format: NSLocalizedString("CustomStaticTagTitle", comment: ""), String(argument[0]))
    }
    static func customStaticTaskTitle(with argument: [String] = []) -> String {
        return String(format: NSLocalizedString("CustomStaticTaskTitle", comment: ""), String(argument[0]))
    }
    static let customStaticNoData = "CustomStaticNoData".localized()
    static let customStaticChartNoData = "CustomStaticChartNoData".localized()
    static let customStaticMonth = "CustomStaticMonth".localized()
    static let customStaicMonthDetail = "CustomStaicMonthDetail".localized()
    
    //settingside
    static let statics = "Static".localized()
    static let settings = "Setting".localized()
    
    //Setting
    static let premiun = "Premium".localized()
    static let informationUse = "InformationUse".localized()
    static let notice = "Notice".localized()
    static let contactUs = "ContactUs".localized()
    static let etc = "Etc".localized()
    static let appStoreReviews = "AppStoreReviews".localized()
    static let license = "License".localized()
    static let service = "Service".localized()
    static let TermsOfService = "TermsOfService".localized()
    static let PrivacyPolicy = "PrivacyPolicy".localized()
}
