//
//  CustomTimer.swift
//  StopWatchTest
//
//  Created by Taehoon Kim on 2021/09/01.
//

import Foundation


class CustomTimer {
    typealias Update = (Int)->Void
    var timer:Timer?
    var timeInterval:Double = 1.0
    var count: Int = 0
    var update: Update?
    
    init(update:@escaping Update){
        self.update = update
    }
    func start(){
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        
    }
    func stop(){
        if let timer = timer {
            timer.invalidate()
        }
    }
    /**
     * This method must be in the public or scope
     */
    @objc func timerUpdate() {
        count += 1;
        if let update = update {
            update(count)
        }
    }
}
