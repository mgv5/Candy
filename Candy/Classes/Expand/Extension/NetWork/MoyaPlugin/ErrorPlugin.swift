//
//  ErrorPlugin.swift
//  SSDispatch
//
//  Created by Insect on 2018/10/22.
//  Copyright © 2018 insect_qy. All rights reserved.
//

import Foundation
import Moya
import Result
import CleanJSON

/// 自定义插件
struct ErrorPlugin: PluginType {

    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {

        var result = result

        // 判断是否成功
        if (try? result.value?.filterSuccessfulStatusCodes()) == nil {
            return Result<Moya.Response, MoyaError>(error: MoyaError.statusCode(result.value!))
        }

        switch result {

        case let .success(response):

            /// 阳光宽频网/微信登录的数据结构不适用
            if target.baseURL.absoluteString == YangGuangIP || target.path == "video/openapi/v1/" || target.baseURL.absoluteString == WeChatIP {break}

            let res = try? CleanJSONDecoder().decode(Model<String>.self, from: response.data)
            let msg = res?.message == .success ? res?.message.rawValue : "抱歉~好像出错了哟~"
            if res?.message != .success {

                result = Result<Moya.Response, MoyaError>(error: MoyaError.objectMapping(LightError(code: 0, reason: msg ?? ""), response))
            }
        case let .failure(error):
            result = Result<Moya.Response, MoyaError>(error: error)
        }

        return result
    }
}