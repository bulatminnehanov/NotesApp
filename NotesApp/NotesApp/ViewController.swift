//
//  ViewController.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 31.03.2026.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    let tableView = UITableView()
    let arrayCell = ["First", "Second", "Third"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCell.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrayCell[indexPath.row]
        return cell
    }
}

