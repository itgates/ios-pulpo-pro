//
//  VisitDetailsVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 11/05/2026.
//

import UIKit
import RxSwift
import RxCocoa

final class VisitDetailsVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var viewBackgroundHeader: UIView!
    @IBOutlet private weak var appVersionLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var buttonBack: UIButton!
    @IBOutlet weak var userIDLabel: UILabel!
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    // MARK: - Properties
    var visitModel: ActualVisitModel?

    private let disposeBag = DisposeBag()
    private let viewModel = VisitDetailsViewModel()
    private var sections: [VisitDetailsSection] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindTableView()
        bindActions()
        if let model = visitModel {
            viewModel.configure(with: model)
        }
    }
}
// MARK: - Setup
private extension VisitDetailsVC {

    func setupUI() {

        view.backgroundColor = .systemBackground

        drawRoundedCorners(for: viewBackgroundHeader,
                           cornerRadius: 20,
                           direction: .bottom)

        shadowView(viewBackgroundHeader)

        appVersionLabel.text = displayAppVersion()
        appVersionLabel.textColor = .green

        companyNameLabel.rx.text.onNext("I. \(user?.company_name ?? "")")
        userIDLabel.rx.text.onNext("ID.\(user?.user_id ?? "")")
        
        // MARK: - TableView
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(
                equalTo: viewBackgroundHeader.bottomAnchor,
                constant: 25
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])

        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    func bindTableView() {

        viewModel.sectionsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] sections in

                self?.sections = sections
                self?.tableView.reloadData()

            })
            .disposed(by: disposeBag)
    }
    
    func bindActions() {
        
        buttonBack.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.dismiss() }
            .disposed(by: disposeBag)
        
    }
}
// MARK: - TableView
extension VisitDetailsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        sections[section].items.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {

        sections[section].header
    }

    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {

        if let header = view as? UITableViewHeaderFooterView {

            header.textLabel?.font = .boldSystemFont(ofSize: 18)
            header.textLabel?.textColor = .systemBlue
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )

        let item = sections[indexPath.section].items[indexPath.row]

        var config = cell.defaultContentConfiguration()

        config.text = item.title
        config.secondaryText = item.value

        config.textProperties.font = .boldSystemFont(ofSize: 15)

        config.secondaryTextProperties.font = .systemFont(ofSize: 14)

        config.secondaryTextProperties.numberOfLines = 0

        cell.contentConfiguration = config
        cell.selectionStyle = .none

        return cell
    }
}
