//
//  CellCollectionViewHome.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import UIKit
import RxCocoa
import RxSwift

// MARK: - Constants
private enum Constants {
    static let imageContainerCornerRadiusMultiplier: CGFloat = 0.5 // 50% for a perfect circle
}

class CellCollectionViewHome: UICollectionViewCell {

    // MARK: - Outlets
//    @IBOutlet private weak var viewCircelImage: UIView!
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    // MARK: - Variables
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
//        viewCircelImage.clipsToBounds = true
        cellImageView.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        viewCircelImage.layer.cornerRadius = viewCircelImage.frame.height * Constants.imageContainerCornerRadiusMultiplier
    }
    // MARK: - Configuration
    func configureCell(model: HomeModel) {
        cellImageView.image = model.image
        nameLabel.text = model.name
    }
}
