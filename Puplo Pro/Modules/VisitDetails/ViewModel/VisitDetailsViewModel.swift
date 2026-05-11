//
//  VisitDetailsViewModel.swift
//  Puplo Pro
//
//  Created by Ahmed on 11/05/2026.
//

import Foundation
import RxSwift
import RxCocoa

struct VisitDetailsSection {
    let header: String
    var items: [(title: String, value: String)]
}

final class VisitDetailsViewModel {

    // MARK: - Properties

    private let sectionsSubject = BehaviorRelay<[VisitDetailsSection]>(value: [])

    var sectionsObservable: Observable<[VisitDetailsSection]> {
        sectionsSubject.asObservable()
    }

    private(set) var visitModel: ActualVisitModel?

    // MARK: - Configure

    func configure(with model: ActualVisitModel) {

        self.visitModel = model

        var sections: [VisitDetailsSection] = []

        // MARK: - Basic Info
        sections.append(
            VisitDetailsSection(
                header: "Basic Info",
                items: [
                    ("Visit ID", model.id),
                    ("Offline ID", "\(model.offline_id ?? "")"),
                    ("Online ID", model.online_id ?? "-"),
                    ("Uploaded", model.isUploaded ? "Yes" : "No")
                ]
            )
        )

        // MARK: - Account Info
        sections.append(
            VisitDetailsSection(
                header: "Account Info",
                items: [
                    ("Account",
                     "Name: \(model.account_name ?? "-")  (ID: \(model.accountID ?? ""))"),

                    ("Doctor",
                     "Name: \(model.doctor_name ?? "-")  (ID: \(model.doctorID ?? ""))"),

                    ("Division",
                     "Name: \(model.division_name ?? "-")  (ID: \(model.divisionID ?? ""))"),

                    ("Brick",
                     "Name: \(model.brick_name ?? "-")  (ID: \(model.brickID ?? ""))"),

                    ("Account Type",
                     "Name: \(model.account_type ?? "-")  (ID: \(model.accountTypeID ?? ""))"),

                    ("Line ID", "\(model.lineId ?? "")"),
                    ("Plan ID", "\(model.palnID ?? "")")
                ]
            )
        )

        // MARK: - Visit Info
        sections.append(
            VisitDetailsSection(
                header: "Visit Info",
                items: [
                    ("Visit Type", "Name: \(model.visit_type ?? "-")  (ID: \(model.visitTypeId ?? ""))"),
                    ("Shift Type", "Name: \(model.shift_type ?? "-")  (ID: \(model.shiftTypeId ?? ""))"),
                    ("Visit Date", model.visit_date ?? "-"),
                    ("Visit Time", model.visit_time ?? "-"),
                    ("Comment", model.comment ?? "-")
                ]
            )
        )

        // MARK: - Location
        sections.append(
            VisitDetailsSection(
                header: "Location",
                items: [
                    ("Latitude", model.llAcccount),
                    ("Longitude", model.lgAcccount),
                    ("End Latitude", model.endLat ?? "-"),
                    ("End Longitude", model.endLong ?? "-")
                ]
            )
        )

        // MARK: - Products
        if let products = model.productVisit,
           !products.isEmpty {

            let rows: [(String, String)] = products.map { product in

                let presentationsText = product.presentations?.map { presentation in

                    let ratingsText = presentation.ratings?.map {
                        "rating: \($0.rating ?? "-"), slide_id: \($0.slide_id ?? "-")"
                    }.joined(separator: "\n") ?? "-"

                    let slidesText = presentation.slides?.map {
                        """
                        slide_id: \($0.id ?? "-")
                        title: \($0.title ?? "-")
                        description: \($0.description ?? "-")
                        rating: \($0.rating ?? 0)
                        start_time: \($0.start_time ?? "-")
                        end_time: \($0.end_time ?? "-")
                        """
                    }.joined(separator: "\n\n") ?? "-"

                    return """
                    Presentation ID: \(presentation.presentation_id ?? "-")
                    Product ID: \(presentation.product_id ?? "-")

                    Ratings:
                    \(ratingsText)

                    Slides:
                    \(slidesText)
                    """
                }.joined(separator: "\n\n-----------------\n\n") ?? "-"

                let details = """
                Product ID: \(product.productId)
                Name: \(product.name)
                Count: \(product.count)
                Comment: \(product.comment)
                Followup ID: \(product.follow_ups ?? "-")
                Market Feedback: \(product.market_feedback ?? "-")

                Presentations:
                \(presentationsText)
                """

                return (product.name, details)
            }

            sections.append(
                VisitDetailsSection(
                    header: "Products",
                    items: rows
                )
            )
        }

        // MARK: - Gifts
        if let gifts = model.giftVisit,
           !gifts.isEmpty {

            let rows = gifts.map {

                (
                    $0.name ?? "-",
                    """
                    Gift ID: \($0.giftId ?? "")
                    Count: \($0.count ?? 0)
                    """
                )
            }

            sections.append(
                VisitDetailsSection(
                    header: "Gifts",
                    items: rows
                )
            )
        }

        // MARK: - Managers
        if let managers = model.managerVisit,
           !managers.isEmpty {

            let rows = managers.map {

                (
                    $0.name,
                    "Employee ID: \($0.empId)"
                )
            }

            sections.append(
                VisitDetailsSection(
                    header: "Managers",
                    items: rows
                )
            )
        }

        // MARK: - Images
        if let images = model.imageVisit,
           !images.isEmpty {

            let rows = images.map {

                (
                    "Image",
                    $0.path
                )
            }

            sections.append(
                VisitDetailsSection(
                    header: "Images",
                    items: rows
                )
            )
        }

        sectionsSubject.accept(sections)
    }
}
