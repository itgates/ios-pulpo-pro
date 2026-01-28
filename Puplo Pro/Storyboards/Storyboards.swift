//
//  Storyboards.swift
//  Puplo Pro
//
//  Created by Ahmed on 17/11/2025.
//

import Foundation
import UIKit

// MARK: - Storyboards
enum storyboards: String {
    case login
}

func currentStoryboard(_ storyboard: storyboards) -> UIStoryboard {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil)
}
