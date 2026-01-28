//
//  ReachabilityVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import RxCocoa
import RxSwift
class ReachabilityVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var retryButton: UIButton!
    
    //MARK: - empty array
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        handleUI()
        subscribeToRetrytButton()
    }
    // MARK: - handleUI
    func handleUI() {
        handleColors()
    }
    // MARK: - handleColors
    func handleColors() {
        retryButton.backgroundColor = mainColor
    }
    //MARK: - subscribe To retry
    func subscribeToRetrytButton() {
        retryButton.rx.tap.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe { [weak self] event in
                if Reachability.isConnectedToNetwork() {
                    print("done")
                }
            }.disposed(by: disposeBag)
    }
}
