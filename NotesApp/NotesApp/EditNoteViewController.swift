//
//  EditNoteViewController.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 01.04.2026.
//

import UIKit

protocol EditNoteDelegate: AnyObject {
    func didUpdateNote(_ note: Note, at index: Int)
}

class EditNoteViewController: UIViewController {
    
    // MARK: - UI Elements
    private let emojiTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Эмодзи"
        textField.font = .systemFont(ofSize: 32)
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Заголовок"
        textField.font = .boldSystemFont(ofSize: 17)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = false  // ← ВАЖНО: отключаем прокрутку
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    weak var delegate: EditNoteDelegate?
    var note: Note
    var noteIndex: Int
    
    // MARK: - Init
    init(note: Note, index: Int) {
        self.note = note
        self.noteIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadNoteData()
        applyTheme()
        descriptionTextView.delegate = self  // ← добавить
        addDoneButtonToTextView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: Notification.Name("ThemeChanged"),
            object: nil
        )
        emojiTextField.delegate = self
        titleTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
    }
    private func addDoneButtonToTextView() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Готово",
            style: .prominent,
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbar.items = [flexibleSpace, doneButton]
        descriptionTextView.inputAccessoryView = toolbar
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)  // Скрывает клавиатуру для всех полей
    }
    @objc private func themeChanged() {
        applyTheme()
    }
    private func applyTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        let fieldBackgroundColor: UIColor = isDarkMode ? .systemGray6 : .white
        let textColor: UIColor = isDarkMode ? .white : .black
        
        emojiTextField.backgroundColor = fieldBackgroundColor
        emojiTextField.textColor = textColor
        
        titleTextField.backgroundColor = fieldBackgroundColor
        titleTextField.textColor = textColor
        
        descriptionTextView.backgroundColor = fieldBackgroundColor
        descriptionTextView.textColor = textColor
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Редактировать заметку"
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        emojiTextField.backgroundColor = .black
        titleTextField.backgroundColor = .black
        descriptionTextView.backgroundColor = .black
        
        view.addSubview(emojiTextField)
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            emojiTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emojiTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiTextField.widthAnchor.constraint(equalToConstant: 80),
            emojiTextField.heightAnchor.constraint(equalToConstant: 50),
            
            titleTextField.topAnchor.constraint(equalTo: emojiTextField.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveNote)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelEditing)
        )
    }
    
    private func loadNoteData() {
        emojiTextField.text = note.emoji
        titleTextField.text = note.title
        descriptionTextView.text = note.desc
        
        DispatchQueue.main.async {
            self.updateTextViewHeight()
        }
    }
    
    // MARK: - Actions
    @objc private func saveNote() {
        guard let emoji = emojiTextField.text, !emoji.isEmpty,
              let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Заполните эмодзи и заголовок")
            return
        }
        
        let updatedNote = Note(
            emoji: emoji,
            title: title,
            desc: descriptionTextView.text ?? ""
        )
        
        delegate?.didUpdateNote(updatedNote, at: noteIndex)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancelEditing() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func updateTextViewHeight() {
        let size = descriptionTextView.sizeThatFits(CGSize(
            width: descriptionTextView.frame.width,
            height: CGFloat.greatestFiniteMagnitude
        ))
        
        // Обновляем высоту, если она изменилась
        if descriptionTextView.frame.height != size.height {
            descriptionTextView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = size.height
                }
            }
            view.layoutIfNeeded()
        }
    }
}
extension EditNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}
extension EditNoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Скрыть клавиатуру
        return true
    }
}
