//
//  NoteDetail.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 01.04.2026.
//

import UIKit

class NoteDetailViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.isEditable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    var note: Note
    var noteIndex: Int
    weak var delegate: EditNoteDelegate?
    
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
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)

        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
         
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Заметка"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveNote)
        )
    }
    
    private func loadNoteData() {
        titleLabel.text = "\(note.emoji) \(note.title)"
        textView.text = note.desc
    }
    
    // MARK: - Actions
    @objc private func saveNote() {
        let updatedNote = Note(
            emoji: note.emoji,
            title: note.title,
            desc: textView.text
        )
        
        delegate?.didUpdateNote(updatedNote, at: noteIndex)
        navigationController?.popViewController(animated: true)
    }
}
