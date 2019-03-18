//
//  VideoHallViewController.swift
//  QYNews
//
//  Created by Insect on 2018/12/18.
//  Copyright © 2018 Insect. All rights reserved.
//

import UIKit

class VideoHallViewController: CollectionViewController {

    fileprivate var topH: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.height ?? 0)
    }

    // MARK: - Lazyload
    fileprivate lazy var topView = TopView(frame: CGRect(x: 0, y: topH, width: ScreenWidth, height: 44))

    /// 搜索框
    private lazy var titleView = SearchTitleView(frame: CGRect(x: SearchTitleView.x, y: SearchTitleView.y, width: SearchTitleView.width, height: SearchTitleView.height))

    /// 添加到 collectionView 上的
    private lazy var filterView: FilterView = {

        let filterView = FilterView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: FilterView.height))
        filterView.delegate = self
        return filterView
    }()

    /// 添加到 view 上的
    fileprivate lazy var animateFilterView: FilterView = {

        let animateFilterView = FilterView(frame: CGRect(x: 0, y: -FilterView.height, width: ScreenWidth, height: FilterView.height))
        animateFilterView.isHidden = true
        animateFilterView.delegate = self
        return animateFilterView
    }()

    private lazy var viewModel = VideoHallViewModel()

    init() {
        super.init(collectionViewLayout: VideoHallFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func makeUI() {

        super.makeUI()

        navigationItem.titleView = titleView
        emptyDataSetDescription = R.string.localizable.videoHallFilterResultEmptyPlaceholder()

        collectionView.register(cellType: VideoHallListCell.self)
        collectionView.refreshFooter = RefreshFooter()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: FilterView.height, left: 0, bottom: 0, right: 0)
        view.addSubview(topView)
        view.addSubview(animateFilterView)
        collectionView.addSubview(filterView)
    }

    override func bindViewModel() {
        super.bindViewModel()

        let input = VideoHallViewModel.Input(searchTap: titleView.beginEdit.asObserver(),
                                             footerRefresh: collectionView.refreshFooter.rx.refreshing.asDriver(),
                                             selection: collectionView.rx.modelSelected(VideoHallList.self))
        let output = viewModel.transform(input: input)

        // 加载失败
        viewModel.error
        .drive(rx.showError)
        .disposed(by: rx.disposeBag)

        // 是否正在加载
        viewModel.loading
        .drive(isLoading)
        .disposed(by: rx.disposeBag)

        // 是否显示占位图
        viewModel.loading
        .drive(onNext: { [weak self] _ in
            self?.collectionView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)

        // 尾部刷新状态
        output.endFooterRefresh
        .drive(collectionView.refreshFooter.rx.refreshFooterState)
        .disposed(by: rx.disposeBag)

        // 数据源
        output.items.drive(collectionView.rx.items(cellIdentifier: VideoHallListCell.ID, cellType: VideoHallListCell.self)) { collectionView, item, cell in
            cell.item = item
        }.disposed(by: rx.disposeBag)

        // 点击了筛选
        topView.rx.tap
        .bind(to: rx.filterTap)
        .disposed(by: rx.disposeBag)

        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
    }
}

// MARK: - FilterViewProtocol
extension VideoHallViewController: FilterViewProtocol {

    func filterView(_ filterView: FilterView, row: Int, item: Int) {

        if filterView == self.filterView {
            animateFilterView.selItem(row: row, item: item)
        } else {
            self.filterView.selItem(row: row, item: item)
        }
    }

    func key(_ key: String) {
        viewModel.searchKey.onNext(key)
    }
}

// MARK: - UICollectionViewDelegate
extension VideoHallViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let contentOffsetY = scrollView.contentOffset.y + FilterView.height + topH
        filterView.frame = CGRect(x: 0, y: -FilterView.height + contentOffsetY - contentOffsetY * 0.3, width: ScreenWidth, height: FilterView.height)
        topView.alpha = scrollView.contentOffset.y <= (-FilterView.height - topH) ? 0 : scrollView.contentOffset.y / contentOffsetY * 2
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        animateFilterView.isHidden = true
        animateFilterView.frame = CGRect(x: 0, y: -FilterView.height, width: ScreenWidth, height: FilterView.height)
    }
}

// MARK: - Reactive-extension
extension Reactive where Base: VideoHallViewController {

    var filterTap: Binder<Void> {

        return Binder(base) { vc, _ in

            vc.animateFilterView.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {

                vc.topView.alpha = 0
                vc.animateFilterView.frame = CGRect(x: 0, y: vc.topH, width: ScreenWidth, height: FilterView.height)
            })
        }
    }
}