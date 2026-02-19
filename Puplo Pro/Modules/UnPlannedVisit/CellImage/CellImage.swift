//
//  CellImage.swift
//  Gemstone Pro
//
//  Created by Ahmed on 17/12/2025.
//

import UIKit
import RxCocoa
import RxSwift
class CellImage: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var deleteImage: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bindButtons()
    }
    func configure(image: SelectedImage) {
        imageView.image = image.image
    }
    // MARK: - Binding Buttons
    private func bindButtons() {
        deleteButton.rx.tap
            .throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .bind(with: self) { cell, _ in
                self.deleteImage?()
            }
            .disposed(by: disposeBag)
    }
}
