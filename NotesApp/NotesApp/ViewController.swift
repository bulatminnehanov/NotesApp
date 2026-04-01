//
//  ViewController.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 31.03.2026.
//

import UIKit
import Foundation

struct Notes {
    let emoji: String
    let title: String
    let desc: String
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditNoteDelegate, AddNoteDelegate {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var notes: [Notes] = [
        Notes(emoji: "🍎", title: "Купить продукты", desc: "Молоко, хлеб, яйца"),
        Notes(emoji: "💻", title: "Выучить Swift", desc: "Разобраться с UITableView и кастомными ячейками")
    ]
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupAddButton()
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.register(NoteCellTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.dataSource = self
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCellTableViewCell else {
            return UITableViewCell()
        }
        
        let note = notes[indexPath.section]
        cell.configure(emoji: note.emoji, title: note.title, description: note.desc)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        return header
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.section)
            
            tableView.deleteSections([indexPath.section], with: .fade)
        }
    }
    func didUpdateNote(_ note: Notes, at index: Int) {
        notes[index] = note
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let cell = tableView.cellForRow(at: indexPath) as? NoteCellTableViewCell {
            cell.animateTap()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let note = self.notes[indexPath.section]
            let detailVC = NoteDetailViewController(note: note, index: indexPath.section)
            detailVC.delegate = self
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            let note = self.notes[indexPath.section]
            let editVC = EditNoteViewController(note: note, index: indexPath.section)
            editVC.delegate = self
            self.navigationController?.pushViewController(editVC, animated: true)
            
            completion(true)
        }
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    private func setupAddButton() {
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addButton.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
    }
    @objc private func addNoteTapped() {
            let addVC = AddNoteViewController()
            addVC.delegate = self
            navigationController?.pushViewController(addVC, animated: true)
        }
        
        func didAddNote(_ note: Notes) {
            notes.append(note)
            tableView.reloadData()
            
            // Прокручиваем к новой заметке
            let lastSection = notes.count - 1
            let indexPath = IndexPath(row: 0, section: lastSection)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
}


