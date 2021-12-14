//
//  String+Localized.swift
//  planner
//
//  Created by Taehoon Kim on 2021/11/16.
//
// 사용예시

// myLabel.text = "Hello".localized()
// myLabel.text = "My Age %d".localized(with: 26, comment: "age")
import Foundation


extension String {
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
    
}

