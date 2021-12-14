//
//  SideMenu.swift
//  planner
//
//  Created by Taehoon Kim on 2021/10/18.
//

import UIKit

protocol MenuCotrollerDelegate {
    func didSelectMenu(named: SideMenuItem)
}

enum SideMenuItem: String, CaseIterable {
//    case home = "Memo"
//    case schedule = "일정관리"
    case analysis = "Analytics"
    case settings = "Setting"
}

class MenuController: UITableViewController {
    
    public var delegate: MenuCotrollerDelegate?
    
    private let menuItems: [SideMenuItem]
    private let color = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
    init(with menuItems: [SideMenuItem]) {
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(UINib(nibName: "SideTableViewCell",bundle: nil), forCellReuseIdentifier: "SideTableViewCell")
        //tableView.rowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.backgroundColor = color
        view.backgroundColor = color
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row].rawValue
        cell.textLabel?.textColor = .white
        
        cell.backgroundColor = color
        cell.contentView.backgroundColor = color
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = menuItems[indexPath.row]
        
        delegate?.didSelectMenu(named: selectedItem)
        // Relay to delegate about menu item selection
    }
    
}
