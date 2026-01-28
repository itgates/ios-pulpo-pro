//
//  Loading.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import UIKit
import Lottie

private var globalLoadingView: LottieAnimationView?
private var globalBackgroundView: UIView?
private var globalContainerView: UIView?

private var globalLoadingLabel: UILabel?

extension UIViewController {
    func startLoading(withText text: String = "") {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.activeKeyWindow else { return }
            if globalBackgroundView != nil { return }
            
            let bgView = UIView(frame: window.bounds)
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            window.addSubview(bgView)
            globalBackgroundView = bgView
            
            let container = UIView()
            container.backgroundColor = .white
            container.layer.cornerRadius = 12
            container.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(container)
            
            // اختر ارتفاع مختلف حسب النص
            let containerHeight: CGFloat = text.isEmpty ? 110 : 140
            
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
                container.widthAnchor.constraint(equalToConstant: 120),
                container.heightAnchor.constraint(equalToConstant: containerHeight)
            ])
            globalContainerView = container
            
            let animationView = LottieAnimationView()
            if let path = Bundle.main.path(forResource: "Loader", ofType: "json"),
               let animation = LottieAnimation.filepath(path) {
                animationView.animation = animation
            }
            
            let colorProvider = ColorValueProvider(baseColor.lottieColorValue)
            animationView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Color"))
            animationView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Fill.Color"))
            animationView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: "**.Stroke.Color"))
            
            animationView.loopMode = .loop
            animationView.animationSpeed = 1.1
            animationView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(animationView)
            
            NSLayoutConstraint.activate([
                animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                animationView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
                animationView.widthAnchor.constraint(equalToConstant: 90),
                animationView.heightAnchor.constraint(equalToConstant: 90)
            ])
            animationView.play()
            globalLoadingView = animationView
            
            // ===== label =====
            let label = UILabel()
            label.text = text
            label.textColor = secondaryColor
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            
            if !text.isEmpty {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 5),
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 5),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
                    label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5)
                ])
            }
            
            globalLoadingLabel = label
        }
    }
    
    func updateLoadingText(_ text: String) {
        DispatchQueue.main.async {
            globalLoadingLabel?.textColor = secondaryColor
            globalLoadingLabel?.text = text
            
        }
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            globalLoadingView?.stop()
            globalLoadingView?.removeFromSuperview()
            globalContainerView?.removeFromSuperview()
            globalBackgroundView?.removeFromSuperview()
            globalLoadingLabel?.removeFromSuperview()
            
            globalLoadingView = nil
            globalContainerView = nil
            globalBackgroundView = nil
            globalLoadingLabel = nil
        }
    }
}


extension UIApplication {
    var activeKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
