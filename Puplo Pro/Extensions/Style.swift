//
//  Style.swift
//  Puplo Pro
//
//  Created by Ahmed on 21/11/2025.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: CALayer {
    
    var cornerRadius: Binder<CGFloat> {
        Binder(base) { layer, value in
            layer.cornerRadius = value
            layer.masksToBounds = true
        }
    }
    
    var borderWidth: Binder<CGFloat> {
        Binder(base) { layer, value in
            layer.borderWidth = value
        }
    }
    
    var borderColor: Binder<CGColor> {
        Binder(base) { layer, value in
            layer.borderColor = value
        }
    }
}
