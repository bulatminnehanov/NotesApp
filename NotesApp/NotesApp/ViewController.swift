//
//  ViewController.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 31.03.2026.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    // Создаем таблицу
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // Тестовые данные
    let notes = [
        (emoji: "🍎", title: "Купить продукты", desc: "Молоко, хлеб, яйца"),
        (emoji: "💻", title: "Выучить Swift", desc: "Разобраться с UITableView и кастомными ячейками")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        
        // Растягиваем таблицу на весь экран
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ВАЖНО: Регистрируем ваш класс ячейки
        tableView.register(NoteCellTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        
        // Назначаем делегата и источник данных
        tableView.dataSource = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           // Достаем вашу ячейку из очереди
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCellTableViewCell else {
               return UITableViewCell()
           }
           
           // Берем данные из массива
           let note = notes[indexPath.row]
           
           // Вызываем ваш метод конфигурации
           cell.configure(emoji: note.emoji, title: note.title, description: note.desc)
           
           return cell
       }
}

