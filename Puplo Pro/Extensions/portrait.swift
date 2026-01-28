//
//  portrait.swift
//  Puplo Pro
//
//  Created by Ahmed on 19/01/2026.
//

import Foundation
import UIKit
final class OrientationNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }
}
