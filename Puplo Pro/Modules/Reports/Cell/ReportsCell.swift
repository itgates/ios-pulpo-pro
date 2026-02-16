//
//  ReportsCell.swift
//  Gemstone Pro
//
//  Created by Ahmed on 24/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
class ReportsCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var nameReportsLabel: UILabel!
    @IBOutlet weak var imageReports: UIImageView!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    // MARK: - Configuration
    func configureCell(model: HomeModel) {
        imageReports.image = model.image
        nameReportsLabel.text = model.name
    }
    func setupUI() {
        viewBackground.layer.rx.cornerRadius.onNext(10)
        
    }
}
