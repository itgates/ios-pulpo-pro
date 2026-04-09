//
//  ForceUpdateVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 08/04/2026.
//

import UIKit
import RxCocoa
import RxSwift
class ForceUpdateVC: BaseView {

    //MARK: - out lets
    @IBOutlet weak var viewContinerCornerRadius: UIView!
    @IBOutlet weak var forceUpdateButton: UIButton!
    
    // MARK: - Variables
    private let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyles()
        setupBindings()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        forceUpdateButton.layer.cornerRadius = forceUpdateButton.frame.height / 2
        forceUpdateButton.layer.masksToBounds = true
    }

}
extension ForceUpdateVC {
    
    // MARK: - Styles
    private func setupStyles() {
        forceUpdateButton.backgroundColor = baseColor
        style(view: viewContinerCornerRadius, cornerRadius: 15)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        
        forceUpdateButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                openLink(Link: "https://apps.apple.com/eg/app/puplo-pro/id6758396660")
            })
            .disposed(by: disposeBag)
    }
}
