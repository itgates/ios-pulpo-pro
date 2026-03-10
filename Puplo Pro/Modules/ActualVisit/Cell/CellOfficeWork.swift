//
//  CellOfficeWork.swift
//  Puplo Pro
//
//  Created by Ahmed on 09/03/2026.
//

import UIKit
import RxCocoa
import RxSwift

class CellOfficeWork: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var viewContiner: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var officeWorkLabel: UILabel!
    @IBOutlet weak var stackComment: UIStackView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var shiftTypeLabel: UILabel!

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Configure
    func configure(with model: OWSModel, viewModel: OWActivitiesViewModel) {

        dateLabel.text = model.date
        commentLabel.text = model.notes

        shiftTypeLabel.text =
        viewModel.shiftName(for: model.shift_id ?? "") ?? ""

        officeWorkLabel.text =
        viewModel.officeWorkName(for: model.ow_type_id) ?? ""
        
        stackComment.isHidden = model.notes.isEmpty
    }
}
