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
    
    @IBAction func clearDataButton(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Clear Data", message: "Clear Conversation Data?", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.clearData()
            print("Database Cleared")
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Cancel")
        }))

        present(refreshAlert, animated: true, completion: nil)
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
    
    func clearData(){
            guard let url = URL(string: "https://www.thomasapigateway.com/clear_data") else {
                print("Url did not work.")
                return
            }
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error")
                }
                print("database cleared...")
            }

            task.resume()
        }

}

