//
//  UserManager.swift
//  SSDispatch
//
//  Created by insect_qy on 2018/7/27.
//  Copyright © 2018年 insect_qy. All rights reserved.
//

import UIKit
import DefaultsKit

let userManager = UserManager.default

final class UserManager {

    static let `default` = UserManager()

    public var userInfo: UserInfoModel? {
        getUserInfo()
    }

    // MARK: - 判断是否登录
    public func isLogin() -> Bool {
        Defaults().has(.userKey)
    }

    // MARK: - 登录成功
    public func loginSuccess(userInfo: UserInfoModel) {
        saveUserInfo(userInfo)
    }

    // MARK: - 退出登录
    public func exitLogin() {
        clearUserInfo()
    }
}

extension UserManager {

    // MARK: - 从本地获取用户信息
    private func getUserInfo() -> UserInfoModel? {
        Defaults().get(for: .userKey)
    }

    // MARK: - 保存用户信息
    private func saveUserInfo(_ userInfo: UserInfoModel) {
        Defaults().set(userInfo, for: .userKey)
    }

    // MARK: - 清除用户信息
    private func clearUserInfo() {
        Defaults().clear(.userKey)
    }
}

extension UserManager: ReactiveCompatible {}

extension Reactive where Base: UserManager {

    var loginSuccess: Binder<UserInfoModel> {
        Binder(base) { this, result in
            this.loginSuccess(userInfo: result)
        }
    }
}
