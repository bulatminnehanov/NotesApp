//
//  NoteCellTableViewCell.swift
//  NotesApp
//
//  Created by Булат Миннеханов on 31.03.2026.
//

import UIKit

class NoteCellTableViewCell: UITableViewCell {
    let emojiLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 32)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = .gray
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            backgroundColor = .clear
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.3
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 12
            layer.masksToBounds = false
            
            contentView.addSubview(emojiLabel)
            contentView.addSubview(titleLabel)
            contentView.addSubview(descriptionLabel)
            
            NSLayoutConstraint.activate([
                emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                emojiLabel.widthAnchor.constraint(equalToConstant: 40),
                emojiLabel.heightAnchor.constraint(equalToConstant: 40),
                
                titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                
                descriptionLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
                descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ])
        }
        func configure(emoji: String, title: String, description: String) {
            emojiLabel.text = emoji
            titleLabel.text = title
            descriptionLabel.text = description
        }
}
