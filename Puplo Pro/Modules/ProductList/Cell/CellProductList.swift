//
//  CellProductList.swift
//  Gemstone Pro
//
//  Created by Ahmed on 05/01/2026.
//

import UIKit
import RxCocoa
import RxSwift
class CellProductList: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // MARK: - Configuration
    func configureCell(model: IdNameModel) {
        productNameLabel.text = model.name ?? ""
        idLabel.text = "\(model.id ?? "")"
    }
}
