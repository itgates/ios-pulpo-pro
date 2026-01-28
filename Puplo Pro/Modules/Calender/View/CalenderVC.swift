//
//  CalenderVC.swift
//  Puplo Pro
//
//  Created by Ahmed on 27/11/2025.
//

import UIKit
import Koyomi
import RxSwift
import RxCocoa

protocol BackSelectDate {
    func selectDate(date: String)
}

final class CalenderVC: BaseView {

    // MARK: - Outlets
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var setDateButton: UIButton!
    @IBOutlet private weak var calender: Koyomi! {
        didSet {
            configureCalendar()
        }
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let formatter = DateFormatter()
    private let today = Date()
    private var selectedDate: String = ""
    var delegateDate: BackSelectDate?
    var selectAllDates: Bool = false
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureInitialDate()
        bindButtons()
    }
}

// MARK: - UI Setup
private extension CalenderVC {

    func configureUI() {
        setDateButton.rx.backgroundColor.onNext(baseColor)
        style(view: setDateButton, cornerRadius: setDateButton.frame.height / 2)
    }

    func configureCalendar() {
        calender.circularViewDiameter = 0.5
        calender.calendarDelegate = self
        calender.inset = .zero
        calender.weeks = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
        calender.style = .monotone
        calender.dayPosition = .center
        calender.selectionMode = .single(style: .background)
        calender.selectedStyleColor = baseColor
    }

    func configureInitialDate() {
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        calender.currentDateFormat = "MMMM"
        monthLabel.rx.text.onNext(calender.currentDateString())

        calender.select(date: today)
        selectedDate = formatter.string(from: today)
    }
}

// MARK: - RX Bindings
private extension CalenderVC {

    func bindButtons() {

        // Next Month
        nextButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.changeMonth(direction: .next) }
            .disposed(by: disposeBag)

        // Previous Month
        previousButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.changeMonth(direction: .previous) }
            .disposed(by: disposeBag)

        // Close
        closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.closePopUp() }
            .disposed(by: disposeBag)

        // Set Date
        setDateButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                self.delegateDate?.selectDate(date: self.selectedDate)
                self.closePopUp()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Calendar Actions
private extension CalenderVC {

    enum MonthDirection { case next, previous }

    func changeMonth(direction: MonthDirection) {
        switch direction {
        case .next: calender.display(in: .next)
        case .previous: calender.display(in: .previous)
        }
        monthLabel.rx.text.onNext(calender.currentDateString())
    }
}

// MARK: - Koyomi Delegate
extension CalenderVC: KoyomiDelegate {

//    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {
//        guard let date = date else { return }
//        
//        let selected = formatter.string(from: date)
//        let todayString = formatter.string(from: today)
//
//        // Don't allow selecting days before today
//        if selected < todayString { return }
//
//        selectedDate = selected
//        calender.selectedStyleColor = baseColor
//    }
    func koyomi(_ koyomi: Koyomi, didSelect date: Date?, forItemAt indexPath: IndexPath) {
        guard let date = date else { return }

        // لو مفعّل selectAllDates نسيب الاختيار عادي
        if selectAllDates {
            selectedDate = formatter.string(from: date)
            calender.selectedStyleColor = baseColor
            return
        }

        // المنطق القديم
        let selected = formatter.string(from: date)
        let todayString = formatter.string(from: today)

        if selected < todayString { return }

        selectedDate = selected
        calender.selectedStyleColor = baseColor
    }

//    func koyomi(_ koyomi: Koyomi,
//                shouldSelectDates date: Date?,
//                to toDate: Date?,
//                withPeriodLength length: Int) -> Bool {
//
//        guard let date = date else { return false }
//        let selected = formatter.string(from: date)
//        let todayString = formatter.string(from: today)
//
//        // Allow only today if selected before current day
//        if date < today {
//            if selected == todayString {
//                selectedDate = selected
//                return true
//            }
//            return false
//        }
//
//        selectedDate = selected
//        return true
//    }
    func koyomi(_ koyomi: Koyomi,
                shouldSelectDates date: Date?,
                to toDate: Date?,
                withPeriodLength length: Int) -> Bool {

        guard let date = date else { return false }

        // لو مفعّل selectAllDates نسمح بأي يوم
        if selectAllDates {
            selectedDate = formatter.string(from: date)
            return true
        }

        // المنطق القديم
        let selected = formatter.string(from: date)
        let todayString = formatter.string(from: today)

        if date < today {
            if selected == todayString {
                selectedDate = selected
                return true
            }
            return false
        }

        selectedDate = selected
        return true
    }

}
