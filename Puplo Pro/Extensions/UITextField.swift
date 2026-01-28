//
//  UITextField.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import UIKit
@IBDesignable
extension UITextField{
    
    //MARK: - Add UITextField placeHolderColor
    @IBInspectable var placeHolderColor: UIColor? {
     get {
         return self.placeHolderColor
     }
     set {
         self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
     }
 }
 //MARK: - Add UITextField padding
 func setPadding(left: CGFloat? = nil, right: CGFloat? = nil){
     if let left = left {
         let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
         self.leftView = paddingView
         self.leftViewMode = .always
     }
     
     if let right = right {
         let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
         self.rightView = paddingView
         self.rightViewMode = .always
     }
 }
 @IBInspectable var padding: CGFloat {
     get {
         return self.padding
     }
     set {
         let view = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.height))
         self.leftView = view
         self.leftViewMode = .always
         self.rightView = view
         self.rightViewMode = .always
     }
   }
}
