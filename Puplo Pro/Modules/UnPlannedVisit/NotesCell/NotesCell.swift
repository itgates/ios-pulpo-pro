//
//  NotesCell.swift
//  Puplo Pro
//
//  Created by Ahmed on 09/12/2025.

import UIKit

final class NotesCell: UITableViewCell {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemOrange
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = baseColor
        return label
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    
    // MARK: - Configuration
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        backgroundColor = .clear
    }
}


// MARK: - UI Setup
private extension NotesCell {
    
    func setupUI() {
        contentView.addSubview(hStack)
        setupConstraints()
    }
    
    func setupConstraints() {
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
