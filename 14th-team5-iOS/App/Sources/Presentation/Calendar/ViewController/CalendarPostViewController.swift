//
//  CalendarFeedViewController.swift
//  App
//
//  Created by 김건우 on 12/8/23.
//

import UIKit

import Core
import DesignSystem
import Domain
import FSCalendar
import Kingfisher
import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit
import Then


public final class CalendarPostViewController: BaseViewController<CalendarPostViewReactor> {
    // MARK: - Views
    private let navigationBarView: BibbiNavigationBarView = BibbiNavigationBarView()
    private let backgroundImageView: UIImageView = UIImageView()

    private let calendarView: FSCalendar = FSCalendar()
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: orthogonalCompositionalLayout
    )
    
    // MARK: - Properties
    private let imageIndexRelay: PublishRelay<Int> = PublishRelay<Int>()
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<PostListSectionModel> = prepareDatasource()
    
    // MARK: - Lifecycles
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Helpers
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(
            navigationBarView, backgroundImageView
        )
        backgroundImageView.addSubviews(
            navigationBarView, calendarView, collectionView
        )
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        navigationBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(42.0)
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom).offset(20.0)
            $0.leading.trailing.equalTo(backgroundImageView)
            $0.height.equalTo(CalendarVC.AutoLayout.calendarHeightValue)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(16.0)
            $0.leading.bottom.trailing.equalTo(backgroundImageView)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        backgroundImageView.do {
            $0.kf.setImage(with: URL(string: "https://cdn.pixabay.com/photo/2023/12/04/16/12/berlin-8429780_1280.jpg"))
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.isUserInteractionEnabled = true
        }
        
        navigationBarView.do {
            $0.navigationTitle = ""
            $0.leftBarButtonItem = .arrowLeft
        }
        
        calendarView.do {
            $0.headerHeight = 0.0
            $0.weekdayHeight = 0.0
            
            $0.today = nil
            $0.scope = .week
            $0.allowsMultipleSelection = false
            
            $0.appearance.selectionColor = UIColor.clear
            
            $0.appearance.titleFont = UIFont.pretendard(.body1Regular)
            $0.appearance.titleDefaultColor = DesignSystemAsset.white.color
            $0.appearance.titleSelectionColor = DesignSystemAsset.white.color
            
            $0.backgroundColor = UIColor.clear
            $0.register(ImageCalendarCell.self, forCellReuseIdentifier: ImageCalendarCell.id)
            $0.register(PlaceholderCalendarCell.self, forCellReuseIdentifier: PlaceholderCalendarCell.id)
            
            $0.dataSource = self
        }
        
        collectionView.do {
            $0.isScrollEnabled = false
            $0.backgroundColor = UIColor.clear
            $0.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.id)
        }
        
        setupBlurEffect()
        setupNavigationTitle(calendarView.currentPage)
    }

    public override func bind(reactor: CalendarPostViewReactor) {
        super.bind(reactor: reactor)
        bindInput(reactor: reactor)
        bindOutput(reactor: reactor)
    }
    
    private func bindInput(reactor: CalendarPostViewReactor) {
        let selectedDate: Date = reactor.currentState.selectedDate
        let previousNextMonths: [String] = reactor.currentState.selectedDate.generatePreviousNextYearMonth()
        
        Observable<Date>.just(selectedDate)
            .map { Reactor.Action.didSelectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable<String>.from(previousNextMonths)
            .map { Reactor.Action.fetchCalendarResponse($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        imageIndexRelay
            .distinctUntilChanged()
            .map { Reactor.Action.acceptBackgroundImageIndex($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        navigationBarView.rx.didTapLeftBarButton
            .withUnretained(self)
            .subscribe {
                $0.0.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        calendarView.rx.didSelect
            .distinctUntilChanged()
            .map { Reactor.Action.didSelectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        calendarView.rx.calendarCurrentPageDidChange
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe {
                $0.0.setupNavigationTitle($0.1)
            }
            .disposed(by: disposeBag)
        
        calendarView.rx.fetchCalendarResponseDidChange
            .distinctUntilChanged()
            .flatMap {
                Observable<String>.from($0)
                    .map { Reactor.Action.fetchCalendarResponse($0) }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        calendarView.rx.boundingRectWillChange
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe {
                $0.0.adjustWeeklyCalendarRect($0.1)
            }
            .disposed(by: disposeBag)
        
        navigationBarView.rx.didTapLeftBarButton
            .withUnretained(self)
            .subscribe(onNext: {
                $0.0.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(reactor: CalendarPostViewReactor) {
        reactor.state.map { $0.backgroundImageUrl }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe {
                guard let url: URL = $0.1 else { return }
                KingfisherManager.shared.retrieveImage(with: url) { [unowned self] result in
                    switch result {
                    case let .success(value):
                        UIView.transition(
                            with: self.backgroundImageView,
                            duration: 0.25,
                            options: [.transitionCrossDissolve, .allowUserInteraction]) {
                                self.backgroundImageView.image = value.image
                            }
                    case let .failure(error):
                        print("Kingfisher RetrieveImage Error")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dictCalendarResponse }
            .distinctUntilChanged(\.count)
            .withUnretained(self)
            .subscribe {
                $0.0.calendarView.reloadData()
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedDate }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe {
                $0.0.calendarView.select($0.1, scrollToDate: true)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.postListDatasource }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - Extensions
extension CalendarPostViewController {
    private var orthogonalCompositionalLayout: UICollectionViewCompositionalLayout {
        // item
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // group
        let groupSize: NSCollectionLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        // section
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { [unowned self] visibleItems, offset, environment in
            let position: CGFloat =  offset.x / collectionView.frame.width
            let floorPosition: CGFloat = floor(position)
            let fractionPart: CGFloat = position - floorPosition
            
            if fractionPart <= 0.0 {
                imageIndexRelay.accept(Int(floorPosition))
            }
        }
        
        // layout
        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

extension CalendarPostViewController {
    private func prepareDatasource() -> RxCollectionViewSectionedReloadDataSource<PostListSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<PostListSectionModel> { datasource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.id, for: indexPath) as! PostCollectionViewCell
            cell.reactor = EmojiReactor(
                emojiRepository: PostListsDIContainer().makeEmojiUseCase(),
                initialState: .init(
                    type: .calendar,
                    postId: item.postId,
                    memberId: item.author?.name ?? "",
                    imageUrl: item.imageURL
                )
            )
            return cell
        }
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 0.95
        visualEffectView.frame = view.frame
        backgroundImageView.insertSubview(visualEffectView, at: 0)
    }
    
    private func setupNavigationTitle(_ date: Date) {
        navigationBarView.navigationTitle = DateFormatter.yyyyMM.string(from: date)
    }
    
    private func adjustWeeklyCalendarRect(_ bounds: CGRect) {
        calendarView.snp.updateConstraints {
            $0.height.equalTo(bounds.height)
        }
        view.layoutIfNeeded()
    }
}

extension CalendarPostViewController: FSCalendarDataSource {
    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(
            withIdentifier: ImageCalendarCell.id,
            for: date,
            at: position
        ) as! ImageCalendarCell
        
        // 해당 일에 불러온 데이터가 없다면
        let yyyyMM: String = date.toFormatString()
        guard let currentState = reactor?.currentState,
              let dayResponse = currentState.dictCalendarResponse[yyyyMM]?.filter({ $0.date == date }).first
        else {
            let emptyResponse = CalendarResponse(
                date: date,
                representativePostId: "",
                representativeThumbnailUrl: "",
                allFamilyMemebersUploaded: false
            )
            cell.reactor = ImageCalendarCellDIContainer(
                .week,
                dayResponse: emptyResponse,
                isSelected: false
            ).makeReactor()
            return cell
        }
        
        cell.reactor = ImageCalendarCellDIContainer(
            .week,
            dayResponse: dayResponse,
            isSelected: currentState.selectedDate.isEqual(with: date)
        ).makeReactor()
        return cell
    }
}
