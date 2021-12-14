//
//  MyFloatingPanelLayout.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/02.
//

import Foundation
import FloatingPanel

class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .top
        let initialState: FloatingPanelState = .tip

        var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 88.0, edge: .bottom, referenceGuide: .safeArea),
                //.half: FloatingPanelLayoutAnchor(absoluteInset: 216.0, edge: .top, referenceGuide: .safeArea),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 60.0, edge: .top, referenceGuide: .safeArea)
            ]
        }
}
