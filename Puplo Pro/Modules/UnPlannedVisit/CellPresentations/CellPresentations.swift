//
//  CellPresentations.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/01/2026.
//
import UIKit

final class CellPresentations: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var viewCorner: UIView!
    @IBOutlet private weak var presentationsNameLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setSelected(_ selected: Bool) {
        viewCorner.layer.borderWidth = selected ? 3 : 0
        viewCorner.layer.borderColor = selected ? UIColor.blue.cgColor : UIColor.clear.cgColor
    }
    // MARK: - UI
    private func setupUI() {
        viewCorner.layer.cornerRadius = 25
        viewCorner.backgroundColor = baseColor
        viewCorner.clipsToBounds = true
    }
    // MARK: - Configure
    func configure(name: String?) {
        presentationsNameLabel.text = name
    }
}
