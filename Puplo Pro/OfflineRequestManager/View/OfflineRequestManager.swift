//
//  OfflineRequestManagerVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import CoreLocation

class OfflineRequestManager {
    
    // MARK: - Properties
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    let alertBehavior = PublishSubject<String>()
    
    
}
