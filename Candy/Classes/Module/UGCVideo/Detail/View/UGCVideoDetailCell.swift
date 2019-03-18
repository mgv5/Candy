//
//  UGCVideoDetailCell.swift
//  QYNews
//
//  Created by Insect on 2018/12/12.
//  Copyright © 2018 Insect. All rights reserved.
//

import UIKit
import Jelly
import QMUIKit

class UGCVideoDetailCell: CollectionViewCell, NibReusable {

    private var animator: JellyAnimator?

    /// 是否触发了下滑手势
    public var isPanned: Bool = false {
        didSet {
            if isPanned {

                abstractLabel.isHidden = true
                userNameLabel.isHidden = true
                avatarImage.isHidden = true
                commentBtn.isHidden = true
                closeBtn.isHidden = true
            } else {

                abstractLabel.isHidden = false
                userNameLabel.isHidden = false
                avatarImage.isHidden = false
                commentBtn.isHidden = false
                closeBtn.isHidden = false
            }
        }
    }

    @IBOutlet private weak var closeBtn: Button!
    @IBOutlet private weak var abstractLabel: Label!
    @IBOutlet private weak var userNameLabel: Label!
    @IBOutlet private weak var avatarImage: ImageView! {
        didSet {
            avatarImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTap)))
        }
    }
    @IBOutlet private(set) weak var largeImage: ImageView!
    @IBOutlet private weak var commentBtn: QMUIButton! {
        didSet {
            commentBtn.imagePosition = .top
            commentBtn.spacingBetweenImageAndTitle = 15
        }
    }
    @IBOutlet private weak var shareBtn: QMUIButton! {
        didSet {
            shareBtn.imagePosition = .top
            shareBtn.spacingBetweenImageAndTitle = 15
        }
    }

    public var item: UGCVideoListModel? {

        didSet {

            guard let item = item?.video else { return }
            largeImage
            .qy_setImage(item.raw_data.video.origin_cover.url_list.first)
            abstractLabel.text = item.raw_data.title
            userNameLabel.text = item.raw_data.user.info.name
            avatarImage
            .qy_setImage(item.raw_data.user.info.avatar_url)
            commentBtn.setTitle(item.raw_data.action.commentCountString, for: .normal)
        }
    }

    // MARK: - 点击头像
    @objc private func avatarTap() {

        return
        let vc = UserPorfileViewController(userID: item?.video?.raw_data.user.info.user_id ?? "")
        let nav = NavigationController(rootViewController: vc)
        parentVC?.present(nav, animated: true, completion: nil)
    }

    // MARK: - 点击关闭
    @IBAction private func closeBtnDidClick(_ sender: Any) {
        parentVC?.dismiss(animated: true, completion: nil)
    }

    // MARK: - 点击评论
    @IBAction private func commentBtnDidClick(_ sender: Any) {

        let vc = UGCVideoCommentViewController(item: item)
        var presentation = JellySlideInPresentation()
        presentation.directionShow = .bottom
        presentation.directionDismiss = .bottom
        presentation.heightForViewController = .custom(value: ScreenHeight * 0.7)
        presentation.corners = [.topLeft, .topRight]
        presentation.cornerRadius = 12
        presentation.verticalAlignemt = .bottom
        animator = JellyAnimator(presentation: presentation)
        animator?.prepare(viewController: vc)
        parentVC?.present(vc, animated: true, completion: nil)
    }
}