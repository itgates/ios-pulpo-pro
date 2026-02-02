//
//  MasterDataModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 25/11/2025.
//

import Foundation
struct MasterDataModel : Codable {
    let Data : MasterData?
}
struct MasterData : Codable {
    let bricks : [Lines]?
    let visitFeedBack : [Lines]?
    let marketFeedbacks : [Lines]?
    let followUps : [Lines]?
    let account_types : [Lines]?
    let lines : [Lines]?
    let specialties : [Lines]?
    let divisions : [Lines]?
    let giveaways : [Lines]?
    let office_work_types : [Lines]?
    let products : [Lines]?
    let managers : [Lines]?
    let classes : [Lines]?
    let settings : [Settingss]?
    let forms : [Lines]?
    let actions : [Lines]?
    let comments : [Lines]?
    let vacation_types : [Lines]?
}
struct Settingss : Codable {
    let id : String?
    let attribute_name : String?
    let attribute_value : String?
}

//struct Lines: Codable {
//    var id: String?
//    var name: String?
//    var line_id: Int? = 0
//    var line_division_id: Int? = 0
//    var shift_id: Int? = 1
//    var team_id: String?
//    var ter_id: String?
//    var count: String? = ""
//    var ll: String? = ""
//    var lg: String? = ""
//}
struct Lines: Codable {
    var id: String?
    var name: String?
    var team_id: String?
    var ter_id: String?
    
    var line_id: Int? = 0
    var line_division_id: Int? = 0
    var shift_id: Int? = 1
    var count: String? = ""
    var ll: String? = ""
    var lg: String? = ""
    // other optional properties
}
struct VisitItem: Codable {
    var date: String?
    var time: String?
    var planID: Int?
    var division: Lines?
    var brick: Lines?
    var accountType: Lines?
    var account: Lines?
    var doctor: Lines?
    var visitType: Lines?
    var shiftType: Lines?
    var comment: String?
}
struct ProductItem: Codable {
    var product: Lines?
    var feedback: Lines?
    var market: Lines?
    var followUp: Lines?
    var presentations: [Presentations]?
    var count: String
    var comment: String?
    var payment: String?
    var stock: String?
    var order: String?
}
extension Lines: SelectableItem {
    var idValue: String {
        return id ?? ""
    }
}

extension Optional where Wrapped == String {
    var isFilled: Bool {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return false
        }
        return !value.isEmpty
    }
}

extension Optional where Wrapped == Lines {
    var isSelected: Bool {
        return self?.id ?? "" != ""
    }
}

extension ProductItem {

    var isValid: Bool {

        let selectionsValid =
            product.isSelected &&
            feedback.isSelected &&
            market.isSelected &&
            followUp.isSelected

        let textFieldsValid =
            //comment.isFilled &&
            payment.isFilled &&
            stock.isFilled &&
            order.isFilled

        let countValid =
            !count.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return selectionsValid && textFieldsValid && countValid
    }
}
extension VisitItem {

    var isValid: Bool {

        let selectionsValid =
        division.isSelected &&
        brick.isSelected &&
        accountType.isSelected &&
        account.isSelected &&
        doctor.isSelected &&
        visitType.isSelected &&
        shiftType.isSelected

//        let textFieldsValid =
//            date.isFilled &&
//            time.isFilled &&
//            comment.isFilled

        return selectionsValid //&& textFieldsValid
    }
}
