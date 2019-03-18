//
//  EpisodeListFlowLayout.swift
//  QYNews
//
//  Created by Insect on 2019/1/10.
//  Copyright © 2019 Insect. All rights reserved.
//

import UIKit

class EpisodeListFlowLayout: UICollectionViewFlowLayout {

    /// 间距
    private let kMargin: CGFloat = 8
    /// 每行最大列数
    private let kMaxCol: CGFloat = 6
    /// cell 宽度
    private var kItemW: CGFloat {
        return (ScreenWidth - 20 - (kMaxCol - 1) * kMargin) / kMaxCol
    }

    override init() {
        super.init()
        scrollDirection = .vertical
        itemSize = CGSize(width: kItemW, height: kItemW)
        minimumLineSpacing = kMargin
        minimumInteritemSpacing = kMargin
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}