//
//  ViewController.swift
//  planner
//
//  Created by Taehoon Kim on 2021/08/27.
//

import UIKit
import FanMenu
import Macaw
import SideMenu

class StartController: UIViewController {
    
    @IBOutlet weak var fanMenu: FanMenu!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        // self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    @objc func imageViewTapped(_ sender:AnyObject){
        print("imageview tapped")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "circleCalendar")!
        let main = resizeImage(image: image, newWidth: CGFloat(80))
        let daily = resizeImage(image: UIImage(systemName: "d.circle")!, newWidth: CGFloat(80))
        let month = resizeImage(image: UIImage(systemName: "m.circle")!, newWidth: CGFloat(80))
        let idea = resizeImage(image: UIImage(systemName: "i.circle")!, newWidth: CGFloat(80))
        let setting = resizeImage(image: UIImage(systemName: "s.circle")!, newWidth: CGFloat(80))
        
        //Color(val: 0x7C93FE)
        fanMenu.button = FanMenuButton(id: "main", image: main, color: .clear)
     
        fanMenu.items = [
            FanMenuButton(id: "goToDaily", image: daily, color: .clear),
            FanMenuButton(id: "goToMonth", image: month, color: .clear),
            FanMenuButton(id: "goToIdea", image: idea, color: .clear),
            FanMenuButton(id: "goToSetting", image: setting, color: .clear)
        ]
        
        fanMenu.menuRadius = 130.0
        fanMenu.duration = 0.2
        fanMenu.delay = 0.05
        fanMenu.interval = (Double.pi, 2 * Double.pi)
        fanMenu.radius = 40
        
        fanMenu.menuBackground = .clear
        fanMenu.backgroundColor = .clear
        
        fanMenu.onItemDidClick = { button in
            //print("ItemDidClick: \(button.id)")
        }
        
        fanMenu.onItemWillClick = { button in
            if button.id == "goToDaily" {
                self.fanMenu.close()
                self.performSegue(withIdentifier: "goToDaily", sender: self)
            }
            if button.id == "goToMonth" {
                self.fanMenu.close()
                self.performSegue(withIdentifier: "goToMonth", sender: self)
            }
            if button.id == "goToSetting" {
                self.fanMenu.close()
                self.performSegue(withIdentifier: "goToSetting", sender: self)
            }
        }
        
    }
    @IBAction func didTapMenuButton() {
        
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

