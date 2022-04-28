//
//  ViewController.swift
//  OpenChat
//
//  Created by Thomas Park on 4/26/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let chats = ["Classic AI", "Marv the sarcastic AI", "Friendly Francis AI"]
    
    @IBOutlet var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTable.delegate = self
        myTable.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = chats[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("NAME IS \(chats[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = (chats[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }


}

