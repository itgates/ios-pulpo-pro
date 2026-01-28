//
//  UnPlannedVisitModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 04/12/2025.
//

import Foundation
import UIKit

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
