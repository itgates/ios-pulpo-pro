//
//  CellPhotos.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/01/2026.
//

import UIKit

final class CellPhotos: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var photoSlide: UIImageView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoSlide.image = nil
    }

    // MARK: - Configuration
    func configure(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        photoSlide.loadImage(url)
    }
}
