//
//   VideoListViewModel.swift
//  QYNews
//
//  Created by Insect on 2018/12/5.
//  Copyright © 2018 Insect. All rights reserved.
//

import Foundation
import RxOptional

final class VideoListViewModel: RefreshViewModel {

    struct Input {
        /// 视频分类
        let category: String
    }

    struct Output {

        /// 数据源
        let items: Driver<[NewsListModel]>
        /// 所有需要播放的视频 URL
        let videoURLs: Driver<[URL?]>
    }
}

extension VideoListViewModel: ViewModelable {

    func transform(input: VideoListViewModel.Input) -> VideoListViewModel.Output {

        let elements = BehaviorRelay<[NewsListModel]>(value: [])

        // 所有需要播放的视频 URL
        let videoURLs = BehaviorRelay<[URL?]>(value: [])

        let output = Output(items: elements.asDriver(),
                            videoURLs: videoURLs.asDriver())

        // 加载最新视频
        let loadNew = refreshOutput
        .headerRefreshing
        .flatMapLatest { [unowned self] in
            self.request(category: input.category)
        }

        // 加载更多视频
        let loadMore = refreshOutput
        .footerRefreshing
        .flatMapLatest { [unowned self] in
            self.request(category: input.category)
        }

        // 数据源
        loadNew
        .drive(elements)
        .disposed(by: disposeBag)

        loadNew
        .map {
            $0.map {
                URL(string: $0.content.video_play_info.video_list.video_1.mainURL)
            }
        }
        .drive(videoURLs)
        .disposed(by: disposeBag)

        loadMore
        .map { elements.value + $0 }
        .drive(elements)
        .disposed(by: disposeBag)

        loadMore
        .map {
            $0.map {
                URL(string: $0.content.video_play_info.video_list.video_1.mainURL)
            }
        }
        .map {
            videoURLs.value + $0
        }
        .drive(videoURLs)
        .disposed(by: disposeBag)

        // success 下的刷新状态
        loadNew
        .map { _ in false }
        .drive(refreshInput.headerRefreshState)
        .disposed(by: disposeBag)

        Driver.merge(
            loadNew.map { _ in
                RxMJRefreshFooterState.default
            },
            loadMore.map { _ in
                RxMJRefreshFooterState.default
            }
        )
        .startWith(.hidden)
        .drive(refreshInput.footerRefreshState)
        .disposed(by: disposeBag)
        return output
    }
}

extension VideoListViewModel {

    /// 加载视频
    func request(category: String) -> Driver<[NewsListModel]> {

        return  VideoApi.list(category)
                .request()
                .mapObject([NewsListModel].self)
                .map {
                    $0.filter {
                        !($0.content.label).contains("广告")
                    }
                }
                .trackActivity(loading)
                .trackError(refreshError)
                .asDriverOnErrorJustComplete()
    }
}
