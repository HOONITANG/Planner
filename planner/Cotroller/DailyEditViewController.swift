//
//  DailyEditViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/08.
//

import Foundation

import UIKit
import RealmSwift

class DailyEditViewController: UIViewController {
  
    var eventDayItems:Results<EventDay>?
    let realm = try! Realm()
    @IBOutlet weak var removeButton: UIButton!
    
    var selectedEventDay: EventDay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeButton.setTitle("RemoveButton", for: .normal)
    }
    
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        self.removeDayView(eventDay: selectedEventDay!)
        //dayView load
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    func removeDayView(eventDay: EventDay) {
        do {
            try realm.write {
                realm.delete(eventDay)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
}
