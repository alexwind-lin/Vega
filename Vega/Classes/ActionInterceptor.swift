//
//  ActionInterceptor.swift
//  TestN
//
//  Created by kensou on 2021/4/19.
//

import Foundation

public protocol RequestInterceptor {
    func process<Input, Output>(model: ActionModel<Input, Output>, requestData: RequestData) -> RequestData
}

public protocol ResponseInterceptor {
    func process<Input, Output>(model: ActionModel<Input, Output>, responseData: ResponseData) -> ResponseData
}

public typealias ActionInterceptor = RequestInterceptor & ResponseInterceptor
