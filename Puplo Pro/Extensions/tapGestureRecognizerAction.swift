//
//  tapGestureRecognizerAction.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/11/2025.
//

import UIKit

private var tapGestureKey: UInt8 = 0

extension UIView {

    // MARK: - Stored Closure
    private var tapAction: (() -> Void)? {
        get { objc_getAssociatedObject(self, &tapGestureKey) as? (() -> Void) }
        set { objc_setAssociatedObject(self, &tapGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Add Tap Gesture
    func onTap(_ action: @escaping () -> Void) {
        isUserInteractionEnabled = true
        tapAction = action

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tap)
    }

    @objc private func didTapView() {
        tapAction?()
    }
}
