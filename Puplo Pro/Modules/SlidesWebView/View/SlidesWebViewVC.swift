//
//  SlidesWebViewVC.swift
//  Gemstone Pro
//
//  Created by Ahmed on 18/01/2026.

import UIKit
import RxSwift
import RxCocoa
import WebKit
import SSZipArchive

final class SlidesWebViewVC: BaseView {
    // MARK: - IBOutlets
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var rateButton: UIButton!
    @IBOutlet private weak var slideButton: UIButton!
    @IBOutlet private weak var stackSlide: UIStackView!
    @IBOutlet private weak var stackSlideLeadingConstraint: NSLayoutConstraint!

    @IBOutlet private weak var collectionViewCountSlide: UICollectionView!
    @IBOutlet private weak var collectionViewPhotos: UICollectionView!

    // MARK: - WebView (Code-based)
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "slideHandler")

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.userContentController = contentController

        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let selectedIndex = BehaviorRelay<Int>(value: 0)
    private let slidesRelay = BehaviorRelay<[Slides]>(value: [])
    var slidesArray: [Slides] = []
    var productIndex: Int = 0
    var presentationID: Int?
    private var isSlideVisible = false
    private var webViewLeadingConstraint: NSLayoutConstraint!

    private var htmlCache: [Int: URL] = [:]
    private var currentSlideStartDate: Date?
    private var currentSlideIndex: Int?
    private lazy var timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    // MARK: - Helpers
    private func resolvedCurrentIndex() -> Int? {
        var idx = selectedIndex.value
        if let explicit = currentSlideIndex { idx = explicit }
        guard idx >= 0, idx < slidesArray.count else { return nil }
        return idx
    }
    private func apiBaseURL() -> String { LocalStorageManager.shared.getAPIPath() ?? "" }

    // MARK: - Rating UI
    private func updateRateButtonAppearance() {
        guard let currentIdx = resolvedCurrentIndex() else { return }

        // Load current saved products to check if this slide is rated
        guard let list = LocalStorageManager.shared.getProductsData(),
              productIndex >= 0, productIndex < list.count,
              let presentations = list[productIndex].presentations, !presentations.isEmpty else {
            // default to not rated
            rateButton.setImage(UIImage(systemName: "star"), for: .normal)
            rateButton.tintColor = baseColor
            return
        }

        var targetIndex = 0
        if let pid = presentationID, let idx = presentations.firstIndex(where: { Int($0.presentation_id ?? "") == pid }) {
            targetIndex = idx
        }
        let slideID = slidesArray[currentIdx].slide_id
        let ratings = presentations[targetIndex].ratings ?? []
        let isRated: Bool
        if let sid = slideID {
            isRated = ratings.contains(where: { $0.slide_id == sid })
        } else {
            isRated = !ratings.isEmpty
        }

        if isRated {
            rateButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            rateButton.tintColor = .systemYellow
        } else {
            rateButton.setImage(UIImage(systemName: "star"), for: .normal)
            rateButton.tintColor = baseColor
        }
    }

    // MARK: - Setup
    private func initialSetup() {
        setupWebView()
        configureViews()
        setupUI()
        setupCollectionViews()
        setupBindings()
        bindSlides()
        observeSelectedIndex()
        bringStacksToFront()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        slidesRelay.accept(slidesArray)
        saveSlidesIntoProducts()
        preloadHTMLSlides()
        applyInitialSlideState()
        updateRateButtonAppearance()
        stackSlideLeadingConstraint.constant = -100
        webViewLeadingConstraint.constant = 0
        
        print("slidesArray >>\(slidesArray)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configurePhotosLayout()
        collectionViewPhotos.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Orientation
extension SlidesWebViewVC {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
}

// MARK: - Initial State
private extension SlidesWebViewVC {
    /// Applies the first slide and starts timing.
    func applyInitialSlideState() {
        guard let firstSlide = slidesRelay.value.first else { return }
        selectedIndex.accept(0)
        commitTimingAndStartNew(for: 0)

        if firstSlide.slide_type == "image" {
            showImageSlide(at: 0)
        } else if firstSlide.slide_type == "html" {
            showHTMLSlide(firstSlide, at: 0)
        }
    }
}

// MARK: - UI Setup
private extension SlidesWebViewVC {
    func configureViews() {
        view.backgroundColor = .white
        webView.backgroundColor = .white
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }

    func setupUI() {
        style(view: closeButton, cornerRadius: 20)
        style(view: rateButton, cornerRadius: 20)
        style(view: slideButton, cornerRadius: 20)
        closeButton.backgroundColor = baseColor

        rateButton.setImage(UIImage(systemName: "star"), for: .normal)
        rateButton.tintColor = baseColor
    }

    func setupCollectionViews() {
        collectionViewCountSlide.registerCell(cellClass: CellPresentations.self)
        collectionViewPhotos.registerCell(cellClass: CellPhotos.self)

        collectionViewCountSlide.rx.setDelegate(self).disposed(by: disposeBag)
        collectionViewPhotos.rx.setDelegate(self).disposed(by: disposeBag)
    }

    func setupWebView() {
        view.insertSubview(webView, belowSubview: stackSlide)

        webViewLeadingConstraint = webView.leadingAnchor.constraint(equalTo: stackSlide.trailingAnchor)

        NSLayoutConstraint.activate([
            webViewLeadingConstraint,
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bringStacksToFront() { view.bringSubviewToFront(stackSlide) }

    func configurePhotosLayout() {
        guard let layout = collectionViewPhotos.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionViewPhotos.isPagingEnabled = true
        collectionViewPhotos.showsVerticalScrollIndicator = false
    }
}

// MARK: - Rx Bindings
private extension SlidesWebViewVC {
    func setupBindings() {
        closeButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
                // End timing for the current slide and persist
                self.commitTimingAndStartNew(for: nil)
                self.navigationController?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        slideButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.toggleSlideMenu() }
            .disposed(by: disposeBag)

        rateButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { [weak self] in self?.presentRating() }
            .disposed(by: disposeBag)
    }

    /// Shows/hides the slide menu panel with animation.
    func toggleSlideMenu() {
        isSlideVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.stackSlideLeadingConstraint.constant = self.isSlideVisible ? 0 : -100
            self.view.layoutIfNeeded()
        }
    }

    func bindSlides() { bindCountSlides(); bindPhotos() }

    func bindCountSlides() {
        slidesRelay
            .bind(to: collectionViewCountSlide.rx.items(
                cellIdentifier: String(describing: CellPresentations.self),
                cellType: CellPresentations.self
            )) { [weak self] index, _, cell in
                cell.configure(name: "\(index + 1)")
                cell.setSelected(index == self?.selectedIndex.value)
            }
            .disposed(by: disposeBag)

        collectionViewCountSlide.rx.itemSelected
            .withLatestFrom(slidesRelay) { ($0.item, $1[$0.item]) }
            .bind { [weak self] index, slide in
                guard let self = self else { return }
                self.selectedIndex.accept(index)
                // Commit previous and start new timing
                self.commitTimingAndStartNew(for: index)
                slide.slide_type == "image" ? self.showImageSlide(at: index) : self.showHTMLSlide(slide, at: index)
                self.updateRateButtonAppearance()
            }
            .disposed(by: disposeBag)
    }

    func bindPhotos() {
        slidesRelay
            .bind(to: collectionViewPhotos.rx.items(
                cellIdentifier: String(describing: CellPhotos.self),
                cellType: CellPhotos.self
            )) { [self] _, model, cell in
                cell.configure(with: apiBaseURL() + (model.slide_path ?? ""))
            }
            .disposed(by: disposeBag)
    }

    func observeSelectedIndex() {
        selectedIndex
            .distinctUntilChanged()
            .withLatestFrom(slidesRelay) { ($0, $1.count) }
            .subscribe(onNext: { [weak self] index, count in
                guard let self = self, index < count else { return }
                self.collectionViewCountSlide.reloadItems(at: self.collectionViewCountSlide.indexPathsForVisibleItems)
                self.collectionViewCountSlide.selectItem(
                    at: IndexPath(item: index, section: 0),
                    animated: true,
                    scrollPosition: .centeredHorizontally
                )
                self.updateRateButtonAppearance()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Slides Display
private extension SlidesWebViewVC {
    func showImageSlide(at index: Int) {
        webView.isHidden = true
        collectionViewPhotos.isHidden = false
        collectionViewPhotos.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredVertically,
            animated: true
        )
    }

    func showHTMLSlide(_ slide: Slides, at index: Int) {
        collectionViewPhotos.isHidden = true
        webView.isHidden = false
        view.bringSubviewToFront(stackSlide)
        startLoading()

        if let cachedURL = htmlCache[index] {
            loadIndexHTML(from: cachedURL)
            return
        }
        guard let path = slide.slide_path else { return }
        let zipURLString = apiBaseURL() + path
        guard let zipURL = URL(string: zipURLString) else { return }
        print("zipURL >>>\(zipURL)")
        downloadAndLoadHTML(from: zipURL, index: index)
    }

    func loadIndexHTML(from folderURL: URL) {
        let indexURL = folderURL.appendingPathComponent("index.html")
        guard var htmlString = try? String(contentsOf: indexURL, encoding: .utf8) else { return }
        if !htmlString.contains("<base") {
            htmlString = htmlString.replacingOccurrences(of: "<head>", with: "<head><base href=\"\(folderURL.absoluteString)\">")
        }
        let jsHandler = """
            <script>
            document.querySelectorAll('a').forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    window.webkit.messageHandlers.slideHandler.postMessage(this.getAttribute('href'));
                });
            });
            </script>
            """
        htmlString += jsHandler
        DispatchQueue.main.async { self.webView.loadHTMLString(htmlString, baseURL: folderURL) }
    }
}

// MARK: - HTML ZIP Handling
private extension SlidesWebViewVC {
    func preloadHTMLSlides() {
        for (index, slide) in slidesArray.enumerated() {
            guard slide.slide_type == "html", let path = slide.slide_path else { continue }
            guard let zipURL = URL(string: apiBaseURL() + path) else { continue }
            downloadAndUnzip(zipURL: zipURL, index: index)
        }
    }

    func downloadAndUnzip(zipURL: URL, index: Int) {
        URLSession.shared.downloadTask(with: zipURL) { [weak self] tempURL, _, _ in
            guard let self = self, let tempURL = tempURL else { return }
            let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("slides_html_\(index)")
            try? FileManager.default.removeItem(at: destination)
            try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
            if SSZipArchive.unzipFile(atPath: tempURL.path, toDestination: destination.path) {
                self.htmlCache[index] = destination
            }
        }.resume()
    }

    func downloadAndLoadHTML(from zipURL: URL, index: Int) {
        URLSession.shared.downloadTask(with: zipURL) { [weak self] tempURL, _, _ in
            guard let self = self, let tempURL = tempURL else { return }
            let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("slides_html_\(index)")
            try? FileManager.default.removeItem(at: destination)
            try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
            if SSZipArchive.unzipFile(atPath: tempURL.path, toDestination: destination.path) {
                self.htmlCache[index] = destination
                self.loadIndexHTML(from: destination)
            } else {
                print("❌ Unzip failed")
            }
        }.resume()
    }
}

// MARK: - UIScrollViewDelegate
extension SlidesWebViewVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collectionViewPhotos else { return }
        let index = Int(round(scrollView.contentOffset.y / scrollView.frame.height))
        selectedIndex.accept(index)
        commitTimingAndStartNew(for: index)
        updateRateButtonAppearance()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SlidesWebViewVC: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView == collectionViewPhotos ? collectionView.bounds.size : CGSize(width: 50, height: 50)
    }
}

// MARK: - WKScriptMessageHandler
extension SlidesWebViewVC: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "slideHandler", let href = message.body as? String else { return }
        print("Internal link clicked: \(href)")
        let folderFromHref = href
            .components(separatedBy: "/")
            .filter { !$0.isEmpty && $0.lowercased() != "index.html" && $0 != "." && $0 != ".." }
            .last ?? ""
        print("Folder from href: \(folderFromHref)")
        if let idx = slidesArray.firstIndex(where: { slide in
            guard let path = slide.slide_path else { return false }
            let fileName = (path as NSString).lastPathComponent
            let slideID = fileName
                .components(separatedBy: "_")
                .prefix(2)
                .joined(separator: "_")
            print("Comparing slide folder: \(slideID) with href folder: \(folderFromHref)")
            return slideID.caseInsensitiveCompare(folderFromHref) == .orderedSame
        }) {
            print("Found slide at index: \(idx)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.selectedIndex.accept(idx)
                let slide = self.slidesArray[idx]
                slide.slide_type == "image" ? self.showImageSlide(at: idx) : self.showHTMLSlide(slide, at: idx)
            }
        } else {
            print("No matching slide found for href: \(href)")
        }
    }
}

// MARK: - WKNavigationDelegate
extension SlidesWebViewVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { endLoading() }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { endLoading() }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { endLoading() }
}

// MARK: - Persistence helpers
private extension SlidesWebViewVC {
    func saveSlidesIntoProducts() {
        guard var list = LocalStorageManager.shared.getProductsData() else { return }
        guard productIndex >= 0, productIndex < list.count else { return }
        guard var presentations = list[productIndex].presentations, !presentations.isEmpty else { return }
        if let pid = presentationID {
            if let idx = presentations.firstIndex(where: { Int($0.presentation_id ?? "") == pid }) {
                presentations[idx].slides = slidesArray
            } else {
                presentations[0].slides = slidesArray
            }
        } else {
            presentations[0].slides = slidesArray
        }
        list[productIndex].presentations = presentations
        LocalStorageManager.shared.saveProductsData(list)
    }
}

// MARK: - Timing helpers
private extension SlidesWebViewVC {
    /// Commits timing for the previous slide and optionally starts timing for a new slide.
    func commitTimingAndStartNew(for newIndex: Int?) {
        if let prevIndex = currentSlideIndex, prevIndex >= 0, prevIndex < slidesArray.count {
            let end = Date()
            if slidesArray[prevIndex].start_time == nil, let start = currentSlideStartDate {
                slidesArray[prevIndex].start_time = timeFormatter.string(from: start)
            }
            slidesArray[prevIndex].end_time = timeFormatter.string(from: end)
        }
        if let idx = newIndex {
            currentSlideIndex = idx
            currentSlideStartDate = Date()
        } else {
            currentSlideIndex = nil
            currentSlideStartDate = nil
        }
        saveSlidesIntoProducts()
        slidesRelay.accept(slidesArray)
    }
}

// MARK: - Rating helpers
private extension SlidesWebViewVC {
    /// Presents rating action sheet for the current slide.
    func presentRating() {
        let alert = UIAlertController(title: "Rate this slide", message: nil, preferredStyle: .actionSheet)
        for stars in (1...5).reversed() {
            let title = String(repeating: "★", count: stars)
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.saveRating(stars: stars)
            }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let pop = alert.popoverPresentationController {
            pop.sourceView = rateButton
            pop.sourceRect = rateButton.bounds
        }
        present(alert, animated: true)
    }
    func saveRating(stars: Int) {
        guard var list = LocalStorageManager.shared.getProductsData() else { return }
        guard productIndex >= 0, productIndex < list.count else { return }
        guard var presentations = list[productIndex].presentations, !presentations.isEmpty else { return }
        var targetIndex = 0
        if let pid = presentationID, let idx = presentations.firstIndex(where: { Int($0.presentation_id ?? "") == pid }) { targetIndex = idx }
        var currentIdx = selectedIndex.value
        if let explicit = currentSlideIndex { currentIdx = explicit }
        let slideID = (currentIdx >= 0 && currentIdx < slidesArray.count) ? slidesArray[currentIdx].slide_id : nil
        let newRating = RatingPresentations(rating: "\(stars)", slide_id: slideID)
        var ratings = presentations[targetIndex].ratings ?? []
        ratings.append(newRating)
        presentations[targetIndex].ratings = ratings
        list[productIndex].presentations = presentations
        LocalStorageManager.shared.saveProductsData(list)
        updateRateButtonAppearance()
    }
}

