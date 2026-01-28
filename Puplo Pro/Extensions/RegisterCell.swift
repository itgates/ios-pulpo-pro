//
//  RegisterCell.swift
//  Puplo Pro
//
//  Created by Ahmed on 18/11/2025.
//

import Foundation
import UIKit
//MARK: - Generic Register UITableViewCell
extension UITableView {
    func registerCellNib<Cell: UITableViewCell>(cellClass: Cell.Type){
        self.register(UINib(nibName: String(describing: Cell.self), bundle: nil), forCellReuseIdentifier: String(describing: Cell.self))
    }
}
//MARK: -  Generic Register UICollectionViewCell
extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(cellClass: Cell.Type){
        self.register(UINib(nibName: String(describing: Cell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: Cell.self))
    }
}
