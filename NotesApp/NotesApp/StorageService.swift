//
//  StorageService.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 02.04.2026.
//

import Foundation

class StorageService {
    
    // MARK: - Singleton
    static let shared = StorageService()
    private init() {}
    
    // MARK: - Private Properties
    private let fileName = "notes.json"
    
    // MARK: - URL для файла
    private var fileURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - Save Notes
    func saveNotes(_ notes: [Note]) {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: url)
            print("✅ Заметки сохранены")
        } catch {
            print("❌ Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Notes
    func loadNotes() -> [Note] {
        guard let url = fileURL else { return [] }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let notes = try decoder.decode([Note].self, from: data)
            print("✅ Заметки загружены: \(notes.count) шт.")
            return notes
        } catch {
            print("❌ Ошибка загрузки: \(error.localizedDescription)")
            return []
        }
    }
}
