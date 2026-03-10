//
//  UnPlannedVisitModel.swift
//  Gemstone Pro
//
//  Created by Ahmed on 04/12/2025.
//

import Foundation
import UIKit
struct UnPlannedVisitAResponse : Codable {
    let Status : Int?
    let Status_Message : String?
    let Data : [UnPlannedVisitAData]?
}
struct UnPlannedVisitAData: Codable {
    let planned_id: String?
    let visit_id: String?
    let offline_id: String?
    
    enum CodingKeys: String, CodingKey {
        case planned_id
        case visit_id
        case offline_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        planned_id = try? container.decode(String.self, forKey: .planned_id)
        offline_id = try? container.decode(String.self, forKey: .offline_id)
        
        if let stringValue = try? container.decode(String.self, forKey: .visit_id) {
            visit_id = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .visit_id) {
            visit_id = String(intValue)
        } else {
            visit_id = nil
        }
    }
}
// MARK: - Table Models
struct NotesRow {
    let title: String
    let value: String
}

/// Represents a section inside notes table
struct NotesSection {
    let header: String
    let rows: [NotesRow]
}

// MARK: - Collection Model
struct SelectedImage: Codable {
    let id: UUID
    let imageData: Data
    let path: String?
    
    // MARK: - Initializers
    
    /// Create from UIImage
    init(image: UIImage, path: String? = nil) {
        self.id = UUID()
        guard let data = image.pngData() else {
            fatalError("Failed to convert UIImage to Data")
        }
        self.imageData = data
        self.path = path
    }
    
    /// Create manually with id, imageData, path
    init(id: UUID, imageData: Data, path: String?) {
        self.id = id
        self.imageData = imageData
        self.path = path
    }
    
    /// Retrieve UIImage from stored Data
    var image: UIImage {
        UIImage(data: imageData) ?? UIImage()
    }
}

// MARK: - Uploaded Attachment Response
struct UploadResponse: Codable {
    let message: String
    let data: [UploadedAttachment]
}

struct UploadedAttachment: Codable {
    let id: String
    let path: String
    let url: String
}
struct VisitBaseData {
    let accountTypeID: Int
    let accountID: Int
    let planId: Int
    let divisionID: Int
    let brickID: Int
    let doctorID: Int
    let comment: String
    let lineId: Int
    let shiftTypeId: Int
    let visitTypeId: Int
    let shiftId: Int
    let latAccount: String
    let longAccount: String
}
struct ProductItem: Codable {
    var product: IdNameModel?
    var feedback: IdNameModel?
    var market: String?
    var followUp: String?
    var presentations: [Presentations]?
    var count: String
    var comment: String?
//    var payment: String?
//    var stock: String?
//    var order: String?
}
struct VisitItem: Codable {
    var date: String?
    var time: String?
    var planID: String? = "0"
    var division: IdNameModel?
    var brick: IdNameModel?
    var accountType: IdNameModel?
    var account: IdNameModel?
    var doctor: IdNameModel?
    var visitType: IdNameModel?
    var shiftType: IdNameModel?
    var comment: String?
}
extension IdNameModel: SelectableItem {
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

extension Optional where Wrapped == IdNameModel {
    var isSelected: Bool {
        return self?.id ?? "" != ""
    }
}

extension ProductItem {
    
    var isValid: Bool {
        
        let selectionsValid =
        product.isSelected &&
        feedback.isSelected
        //            market.isSelected &&
        //            followUp.isSelected
        
//        let textFieldsValid =
        //comment.isFilled &&
//        feedback.isSelected 
//        comment.isFilled &&
//        market.isFilled &&
//        followUp.isFilled //&&
        
        
        //        payment.isFilled &&
        //        stock.isFilled &&
        //        order.isFilled
        
        let countValid =
        !count.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return selectionsValid && countValid
//        return selectionsValid && textFieldsValid && countValid
    }
}
//extension VisitItem {
//    
//    var isValid: Bool {
//        
//        let masterData = LocalStorageManager.shared.getMasterData()
//        
//        let isShiftEnabled =
//        masterData?
//            .Data?
//            .settings?
//            .first(where: { $0.attribute_name == "add_shift" })?
//            .attribute_value == "1"
//        
//        if isShiftEnabled {
//            return division != nil &&
//            brick != nil &&
//            accountType != nil &&
//            account != nil &&
//            doctor != nil &&
//            visitType != nil &&
//            shiftType != nil
//        } else {
//            return division != nil &&
//            brick != nil &&
//            accountType != nil &&
//            account != nil &&
//            doctor != nil &&
//            visitType != nil &&
//            shiftType != nil
//        }
//    }
//}
extension VisitItem {
    
    var isValid: Bool {
        
        let masterData = LocalStorageManager.shared.getMasterData()
        let isShiftEnabled =
            masterData?
                .Data?
                .settings?
                .first(where: { $0.attribute_name == "add_shift" })?
                .attribute_value == "1"
        
        let requiredFields: [IdNameModel?] = [
            division,
            brick,
            accountType,
            account,
            doctor,
            visitType
        ]
        
        if isShiftEnabled {
            return requiredFields.allSatisfy { $0?.id?.isEmpty == false } &&
                   shiftType?.id?.isEmpty == false
        } else {
            return requiredFields.allSatisfy { $0?.id?.isEmpty == false }
        }
    }
}
