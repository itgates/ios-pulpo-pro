//
//  ImagePickerManager.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/12/2025.
//

import Foundation
import UIKit
import PhotosUI
import RxSwift
import RxCocoa

final class ImagePickerManager: NSObject {
    
    static let shared = ImagePickerManager()
    
    private var completion: (([SelectedImage]) -> Void)?
    
    func presentImagePicker(from viewController: UIViewController,
                            selectionLimit: Int = 5,
                            completion: @escaping ([SelectedImage]) -> Void) {
        self.completion = completion
        
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
}

extension ImagePickerManager: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else {
            completion?([])
            return
        }
        
        var selectedImages: [SelectedImage] = []
        let group = DispatchGroup()
        
        results.forEach { result in
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                defer { group.leave() }
                if let image = object as? UIImage {
                    selectedImages.append(SelectedImage(image: image))
                }
            }
        }
        
        group.notify(queue: .main) {
            self.completion?(selectedImages)
        }
    }
}
