//
//  EKWrapper.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/31.
//

import UIKit
import CalendarKit
import EventKit

public final class EKWrapper: EventDescriptor {

    public var startDate: Date {
        get {
            return ekEvent.startDate
        }
        set {
            ekEvent.startDate = newValue
        }
    }
    public var endDate: Date {
        get {
            return ekEvent.endDate
        }
        set {
            ekEvent.endDate = newValue
        }
    }
    public var isAllDay: Bool {
        get {
            return ekEvent.isAllDay
        }
        set {
            ekEvent.isAllDay = newValue
        }
    }
    public var text: String {
        get {
            return ekEvent.title
        }
        set {
            ekEvent.title = newValue
        }
    }
    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?
    
    
    public var color: UIColor {
        get {
            UIColor(cgColor: ekEvent.calendar.cgColor)
        }
    }
    //  public var color = SystemColors.systemBlue {
    //    didSet {
    //      updateColors()
    //    }
    //  }
    public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 16)
    public var userInfo: Any?
    public weak var editedEvent: EventDescriptor? {
        didSet {
            updateColors()
        }
    }
    public private(set) var ekEvent: EKEvent
    
    public init(eventKitEvent: EKEvent) {
        self.ekEvent = eventKitEvent
        updateColors()
    }
    
    // Calendar을 꾹 누르면 호출되는 코드
    public func makeEditable() -> EKWrapper {
        let cloned = Self(eventKitEvent: ekEvent)
        cloned.editedEvent = self
        return cloned
        
        // fatalError()
        //    let cloned = Event()
        //    cloned.startDate = startDate
        //    cloned.endDate = endDate
        //    cloned.isAllDay = isAllDay
        //    cloned.text = text
        //    cloned.attributedText = attributedText
        //    cloned.lineBreakMode = lineBreakMode
        //    cloned.color = color
        //    cloned.backgroundColor = backgroundColor
        //    cloned.textColor = textColor
        //    cloned.userInfo = userInfo
        //    cloned.editedEvent = self
        //    return cloned
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.startDate = startDate
        edited.endDate = endDate
    }
    
    private func updateColors() {
        (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }
    
    /// Colors used when event is not in editing mode
    private func applyStandardColors() {
        backgroundColor = dynamicStandardBackgroundColor()
        textColor = dynamicStandardTextColor()
    }
    
    /// Colors used in editing mode
    private func applyEditingColors() {
        // 색 수정함
        // backgroundColor = color.withAlphaComponent(0.95)
        backgroundColor = color.withAlphaComponent(0.3)
        textColor = .white
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardBackgroundColor() -> UIColor {
        let light = backgroundColorForLightTheme(baseColor: color)
        let dark = backgroundColorForDarkTheme(baseColor: color)
        return dynamicColor(light: light, dark: dark)
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardTextColor() -> UIColor {
        let light = textColorForLightTheme(baseColor: color)
        let dark = textColorForDarkTheme(baseColor: color)
        return dynamicColor(light: light, dark: dark)
    }
    
    private func textColorForLightTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private func textColorForDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * 0.3, brightness: b, alpha: a)
    }
    
    private func backgroundColorForLightTheme(baseColor: UIColor) -> UIColor {
        baseColor.withAlphaComponent(0.3)
    }
    
    private func backgroundColorForDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a * 0.8)
    }
    
    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                let interfaceStyle = traitCollection.userInterfaceStyle
                switch interfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            }
        } else {
            return light
        }
    }
}

