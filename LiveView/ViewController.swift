//
//  ViewController.swift
//  LiveView
//
//  Created by Lacy Rhoades on 7/6/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UITableViewController {
    struct Row {
        var title: String
        var action: () -> ()
    }
    
    var rows: [Row] = []
    
    override func viewDidLoad() {
        self.rows = [
            Row(title: "DSLR live view", action: {
                let vc = SimpleDemoViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR through GPUImage filters", action: {
                let vc = GPUImageDemoViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
        ]
        
        self.tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")!
        
        guard indexPath.row < self.rows.count else {
            return cell
        }
        
        let row = self.rows[indexPath.row]
        cell.textLabel?.text = row.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.rows.count else {
            return
        }
        
        self.rows[indexPath.row].action()
    }
}

class MenuCell: UITableViewCell { }
