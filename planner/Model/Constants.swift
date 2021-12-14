//
//  Constants.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/07.
//

import Foundation

struct K {
    //    static let cellIdentifier = "ReusableCell"
    //    static let cellNibName = "MessageCell"
    //    static let registerSegue = "RegisterToChat"
    //    static let loginSegue = "LoginToChat"
    //    static let appName = "⚡️FlashChat"=
    
    //EventView에서 제거키로 사용됨
    
    static let googleAdsKey = "ca-app-pub-2324283980956847/9476303337"
    
    static var appVersion = "1.0.0"
    static var devEmail = "vinieo0000@gmail.com"
    static let dailyIndexKey = "@sdc#!"
    static let dateKeyForUserDefault = "dateKeyForUserDefault"
    
    static let headerCellNibName = "TodoHeaderCell"
    static let headerCellIdentifier = "todoHeaderCell"
    static let footerCellNibName = "TodoFooterCell"
    static let footerCellIdentifier = "todoFooterCell"
    static let todoCellNibName = "TodoCell"
    static let todoCellIdentifier = "todoCell"
    
    static let memoTableHeaderCellNibName = "MemoTableHeaderCell"
    static let memoTableHeaderCellIdentifier = "memoTableHeaderCell"
    static let memoTableFooterCellNibName = "MemoTableFooterCell"
    static let memoTableFooterCellIdentifier = "memoTableFooterCell"
    static let memoTableCellNibName = "MemoTableCell"
    static let memoTableCellIdentifier = "memoTableCell"
    
    static let sectionHeaderWithAddTableViewCellNibName = "SectionHeaderWithAddTableViewCell"
    static let sectionHeaderWithAddTableViewCellIdentifier = "sectionHeaderWithAddTableViewCell"
    
    
    static let settingCellIdentifier  = "settingCell"
    static let settingHeaderCellIdentifier  = "settingHeaderCell"
    static let settingHeaderCellNibName  = "SettingHeaderCell"
    
    static let noticeCellIdentifier = "noticeTableCell"
    
    static let settingList:[SettingStr] = [
        SettingStr(title: S.premiun,
                   item:[
                    SettingItem(text:S.premiun,tag: "goToPremium")
                   ]),
        SettingStr(title: S.informationUse,
                   item:[
                    //SettingItem(text: S.notice, tag: "goToNotice"),
                    SettingItem(text: S.contactUs, tag: "copyEmail")
                   ]),
        SettingStr(title: S.etc,
                   item:[
//                    SettingItem(text: "앱 버전", tag: "version"),
                    SettingItem(text: S.appStoreReviews, tag: "goToStore"),
                    // SettingItem(text: S.license, tag: "goToLicense")
                   ]),
//        SettingStr(title: S.service,
//                   item:[
//                    SettingItem(text: S.TermsOfService, tag: "goToTermsOfUse"),
//                    SettingItem(text: S.PrivacyPolicy, tag: "goToPrivacy")
//                   ])
    ]
    
    struct BrandColors {
        static let darkBlue = 0x16253F
        static let black = 0x000000
        static let lightGray = 0xC2C9D1
        static let gray = 0xC5C5C5
    }
    
    
    
    
    
    //    struct BrandColors {
    //        static let purple = "BrandPurple"
    //        static let lightPurple = "BrandLightPurple"
    //        static let blue = "BrandBlue"
    //        static let lighBlue = "BrandLightBlue"
    //    }
    //
    //    struct FStore {
    //        static let collectionName = "messages"
    //        static let senderField = "sender"
    //        static let bodyField = "body"
    //        static let dateField = "date"
    //    }
}
