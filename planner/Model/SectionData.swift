//
//  SectionData.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/13.
//

import Foundation

struct SectionData {
    let title: String
    let data : [Todo]

    var numberOfItems: Int {
        return data.count
    }

    subscript(index: Int) -> Todo {
        return data[index]
    }
}

