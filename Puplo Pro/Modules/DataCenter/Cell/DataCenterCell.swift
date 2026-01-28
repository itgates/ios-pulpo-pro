//
//  DataCenterCell.swift
//  Puplo Pro
//
//  Created by Ahmed on 24/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
class DataCenterCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var nameReportsLabel: UILabel!
    @IBOutlet weak var imageReports: UIImageView!
    @IBOutlet private weak var downloadButton: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Closure
    var onDownloadTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        bindActions()
    }
    // MARK: - Configuration
    func configureCell(model: HomeModel) {
        imageReports.image = model.image
        nameReportsLabel.text = model.name
    }
    func setupUI() {
        viewBackground.layer.rx.cornerRadius.onNext(10)
        
    }
    // MARK: - Bind Button
    private func bindActions() {
        downloadButton.rx.tap
            .bind { [weak self] in
                self?.onDownloadTapped?()
            }
            .disposed(by: disposeBag)
    }
}
