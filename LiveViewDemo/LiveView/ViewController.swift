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
            Row(title: "DSLR live view (portrait right)", action: {
                let vc = SimpleDemoViewController()
                vc.orientation = .right
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR live view (portrait left)", action: {
                let vc = SimpleDemoViewController()
                vc.orientation = .left
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR through random GPUImage filters", action: {
                let vc = GPUImageDemoViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR through random GPUImage filters (portrait left)", action: {
                let vc = GPUImageDemoViewController()
                vc.orientation = .left
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR through random GPUImage filters (portrait right)", action: {
                let vc = GPUImageDemoViewController()
                vc.orientation = .right
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            Row(title: "DSLR through false color GPUImage filters", action: {
                let vc = GPUImageDemoViewController()
                vc.filters = randomFalseColorFilters()
                self.navigationController?.pushViewController(vc, animated: true)
            }),
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

func randomFalseColorFilters() -> [GPUImageFilter] {
    var colors: [((Float, Float, Float), (Float, Float, Float))] = [
        ((0.5, 0.5, 0.5), (0, 0, 0)),
        ((0.75, 0.75, 0.75), (0, 0, 0)),
        ((0.75, 0.75, 0.75), (0.1, 0.1, 0.1)),
        ((0.8, 0.8, 0.8), (0.3, 0.3, 0.3)),
        ((0.8, 0.8, 0.8), (0.5, 0.5, 0.5)),
        ((0.9, 0.9, 0.9), (0.8, 0.8, 0.8)),
    ]
    
    colors.append(contentsOf: colors.reversed())
    
    let filter1 = GPUImageFalseColorFilter()
    filter1.firstColor = GPUVector4(one: 0.5, two: 0.5, three: 0.5, four: 1.0)
    filter1.secondColor = GPUVector4(one: 0, two: 0, three: 0, four: 1.0)
    
    return colors.map({ (color) -> GPUImageFilter in
        let filter = GPUImageFalseColorFilter()
        filter.firstColor = GPUVector4(one: color.0.0, two: color.0.1, three: color.0.2, four: 1.0)
        filter.secondColor = GPUVector4(one: color.1.0, two: color.1.1, three: color.1.2, four: 1.0)
        return filter
    })
}
