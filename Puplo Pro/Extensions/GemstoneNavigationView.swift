//
//  GemstoneNavigationView.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/12/2025.
//

import Foundation
import UIKit

final class GemstoneNavigationView: UIView {

    private let containerView = UIView()
    private let backButton = UIButton(type: .system)
    private let appIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let versionLabel = UILabel()

    var onBackTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
        applyStyle()
    }

    private func setupUI() {
        backgroundColor = .clear

        containerView.backgroundColor = UIColor.white
        addSubview(containerView)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        appIconImageView.image = UIImage(named: "logo") // اسم الأيقونة
        appIconImageView.contentMode = .scaleAspectFit
        appIconImageView.clipsToBounds = true
        appIconImageView.layer.cornerRadius = 6

        titleLabel.textColor = baseColor
        titleLabel.font = .boldSystemFont(ofSize: 24)

        versionLabel.textColor = .systemGreen
        versionLabel.font = .systemFont(ofSize: 18, weight: .medium)

        containerView.addSubview(backButton)
        containerView.addSubview(appIconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(versionLabel)
    }

    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // container من أول superview
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // back button من أول الـ view
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: statusBarHeight + 8),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            appIconImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            appIconImageView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 50),
            appIconImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: appIconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            versionLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            versionLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
    private var statusBarHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        return 0
    }


    private func applyStyle() {
        containerView.layer.cornerRadius = 28
        containerView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 10
        containerView.layer.masksToBounds = false
    }

    func configure(title: String, version: String, showBack: Bool) {
        titleLabel.text = title
        versionLabel.text = version
        backButton.isHidden = !showBack
    }

    @objc private func backTapped() {
        onBackTapped?()
    }
}
