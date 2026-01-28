//
//  AnimationLottie..swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//


import Foundation
import UIKit
import Lottie

extension UIViewController {
    func startAnimationPin(view: LottieAnimationView, delay: TimeInterval) {
        view.isHidden = false
        let path = Bundle.main.path(forResource: "pin_lottie", ofType: "json") ?? ""
        view.animation = LottieAnimation.filepath(path)
        view.loopMode = .loop
        view.animationSpeed = 1.2
        view.play()
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            view.stop()
//        }
    }
}
