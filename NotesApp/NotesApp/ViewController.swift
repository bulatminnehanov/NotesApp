//
//  ViewController.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 31.03.2026.
//

import UIKit
import Foundation


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditNoteDelegate, AddNoteDelegate {
    var searchController: UISearchController?
    var filteredNotes: [Note] = []
    var isSearching: Bool = false
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var notes: [Note] = []
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
        title = "Заметки"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchTapped)
        )
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateGradient),
                name: Notification.Name("GradientChanged"),
                object: nil
            )
        
        setupTableView()
        setupAddButton()
        loadNotes()
        
        
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
            tableView.register(NoteCellTableViewCell.self, forCellReuseIdentifier: "NoteCell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            
            // Загружаем сохранённые цвета для градиента
            let startColor = loadSavedColor(key: "startColor", defaultColor: .systemBlue)
            let endColor = loadSavedColor(key: "endColor", defaultColor: .systemPurple)
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
            
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
        return isSearching ? filteredNotes.count : notes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCellTableViewCell else {
            return UITableViewCell()
        }
        
        let note = isSearching ? filteredNotes[indexPath.section] : notes[indexPath.section]
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
            if isSearching {
                let noteToDelete = filteredNotes[indexPath.section]
                if let index = notes.firstIndex(where: { $0.title == noteToDelete.title && $0.desc == noteToDelete.desc }) {
                    deleteNote(at: index)
                }
                filteredNotes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .fade)
            } else {
                deleteNote(at: indexPath.section)
            }
        }
    }
    func didUpdateNote(_ note: Note, at index: Int) {
        updateNote(note, at: index)  // ← этот метод уже делает update, reloadData и saveNotes
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NoteCellTableViewCell {
            cell.animateTap()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            let note: Note
            let index: Int
            
            if self.isSearching {
                note = self.filteredNotes[indexPath.section]
                index = self.notes.firstIndex(where: { $0.title == note.title && $0.desc == note.desc }) ?? 0
            } else {
                note = self.notes[indexPath.section]
                index = indexPath.section
            }
            
            let editVC = EditNoteViewController(note: note, index: index)
            editVC.delegate = self
            self.navigationController?.pushViewController(editVC, animated: true)
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
    
    func didAddNote(_ note: Note) {
        tableView.reloadData()
        addNote(note)
        // Прокручиваем к новой заметке
        let lastSection = notes.count - 1
        let indexPath = IndexPath(row: 0, section: lastSection)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    // MARK: - Data Persistence
    private func loadNotes() {
        let savedNotes = StorageService.shared.loadNotes()
        if savedNotes.isEmpty {
            // Первый запуск — добавляем демо-заметки
            notes = [
                Note(emoji: "🍎", title: "Купить продукты", desc: "Молоко, хлеб, яйца"),
                Note(emoji: "💻", title: "Выучить Swift", desc: "Разобраться с UITableView")
            ]
            saveNotes()
        } else {
            notes = savedNotes
        }
        tableView.reloadData()
    }
    
    private func saveNotes() {
        StorageService.shared.saveNotes(notes)
    }
    
    // MARK: - Data Operations (автосохранение)
    func addNote(_ note: Note) {
        notes.append(note)
        tableView.reloadData()
        saveNotes()
    }
    
    func updateNote(_ note: Note, at index: Int) {
        notes[index] = note
        tableView.reloadData()
        saveNotes()
    }
    
    func deleteNote(at index: Int) {
        notes.remove(at: index)
        tableView.deleteSections([index], with: .fade)
        saveNotes()
    }
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    @objc private func searchTapped() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по заметкам"
        searchController.searchBar.tintColor = .white
        
        // Настройка внешнего вида searchBar
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.backgroundImage = UIImage()
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск по заметкам",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
            )
        }
        
        self.searchController = searchController
        present(searchController, animated: true)
    }
    @objc private func updateGradient() {
        // Загружаем сохранённые цвета
        let startColor = loadSavedColor(key: "startColor", defaultColor: .systemBlue)
        let endColor = loadSavedColor(key: "endColor", defaultColor: .systemPurple)
        
        // Обновляем существующий градиент или создаём новый
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    private func loadSavedColor(key: String, defaultColor: UIColor) -> UIColor {
        if let colorData = UserDefaults.standard.data(forKey: key),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            return color
        }
        return defaultColor
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            filteredNotes = []
            tableView.reloadData()
            return
        }
        
        isSearching = true
        
        filteredNotes = notes.filter { note in
            note.title.lowercased().contains(searchText.lowercased()) ||
            note.desc.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
}


